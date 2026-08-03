import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import 'offline_first_repository.dart';

/// The item kinds the recently-viewed cache holds. The database value is
/// fixed independently of the enum name so stored rows survive renames.
enum RecentlyViewedType {
  issue('issue'),
  mergeRequest('merge_request'),
  pipeline('pipeline');

  const RecentlyViewedType(this.dbValue);

  final String dbValue;
}

/// The E14.1 bounded, account-scoped read cache of recently viewed items,
/// backed by [AppDatabase.recentlyViewedItems].
///
/// Bound and eviction policy: at most [maxEntriesPerType] rows per item type
/// per account, evicting the least recently viewed first. Fifty detail
/// payloads per type (a few KB of JSON each) keeps the cache well under a
/// megabyte per account while comfortably covering a session's worth of
/// browsing; every view bumps [RecentlyViewedItem.lastViewedAt], so items the
/// user keeps returning to stay cached even offline.
class RecentlyViewedCache {
  RecentlyViewedCache({
    required this.database,
    required this.account,
    this.maxEntriesPerType = 50,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase database;
  final AccountKey account;
  final int maxEntriesPerType;
  final DateTime Function() _now;

  /// The reactive account-scoped read of one item's cached JSON payload.
  Stream<String?> watchPayload(
    RecentlyViewedType type,
    int projectId,
    int itemId,
  ) {
    final query = database.select(database.recentlyViewedItems)
      ..where((t) => _itemScope(t, type, projectId, itemId));
    return query.watchSingleOrNull().map((row) => row?.payload);
  }

  /// Writes an item's payload through, marks it viewed now, and evicts the
  /// least recently viewed rows past [maxEntriesPerType] for its type.
  Future<void> put(
    RecentlyViewedType type,
    int projectId,
    int itemId,
    String payload,
  ) async {
    await putIf(type, projectId, itemId, payload, shouldReplace: (_) => true);
  }

  Future<bool> putIf(
    RecentlyViewedType type,
    int projectId,
    int itemId,
    String payload, {
    required bool Function(String? existingPayload) shouldReplace,
  }) {
    return database.transaction(() async {
      final existing =
          await (database.select(database.recentlyViewedItems)
                ..where((t) => _itemScope(t, type, projectId, itemId)))
              .getSingleOrNull();
      if (!shouldReplace(existing?.payload)) return false;
      await database
          .into(database.recentlyViewedItems)
          .insertOnConflictUpdate(
            RecentlyViewedItemsCompanion.insert(
              instanceHost: account.instanceHost,
              accountId: account.accountId,
              itemType: type.dbValue,
              projectId: projectId,
              itemId: itemId,
              payload: payload,
              lastViewedAt: _now(),
            ),
          );
      await _evict(type);
      return true;
    });
  }

  /// Marks an already cached item viewed now (no-op when it is not cached),
  /// so an offline read still protects the item from eviction.
  Future<void> touch(RecentlyViewedType type, int projectId, int itemId) {
    final statement = database.update(database.recentlyViewedItems)
      ..where((t) => _itemScope(t, type, projectId, itemId));
    return statement.write(
      RecentlyViewedItemsCompanion(lastViewedAt: Value(_now())),
    );
  }

  Future<void> remove(
    RecentlyViewedType type,
    int projectId,
    int itemId,
  ) async {
    await (database.delete(
      database.recentlyViewedItems,
    )..where((t) => _itemScope(t, type, projectId, itemId))).go();
  }

  Future<void> _evict(RecentlyViewedType type) async {
    final query = database.select(database.recentlyViewedItems)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId) &
            t.itemType.equals(type.dbValue),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.lastViewedAt),
        (t) => OrderingTerm.desc(t.itemId),
      ]);
    final rows = await query.get();
    for (final row in rows.skip(maxEntriesPerType)) {
      await (database.delete(
        database.recentlyViewedItems,
      )..where((t) => _itemScope(t, type, row.projectId, row.itemId))).go();
    }
  }

  Expression<bool> _itemScope(
    $RecentlyViewedItemsTable t,
    RecentlyViewedType type,
    int projectId,
    int itemId,
  ) {
    return t.instanceHost.equals(account.instanceHost) &
        t.accountId.equals(account.accountId) &
        t.itemType.equals(type.dbValue) &
        t.projectId.equals(projectId) &
        t.itemId.equals(itemId);
  }
}

/// One recently viewed item's stale-while-revalidate seam over
/// [RecentlyViewedCache]: [watch] serves the cached payload reactively and
/// [refresh] fetches from the network and writes through, re-emitting.
///
/// The fetch, encode, and decode legs are injected so this stays free of
/// feature imports; each feature's detail surface constructs one per viewed
/// item with its own repository call and model JSON round-trip.
class RecentItemRepository<T> implements OfflineFirstRepository<T?> {
  RecentItemRepository({
    required this.cache,
    required this.type,
    required this.projectId,
    required this.itemId,
    required this._fetch,
    required this._decode,
    required this._encode,
    required this._updatedAt,
  });

  final RecentlyViewedCache cache;
  final RecentlyViewedType type;
  final int projectId;
  final int itemId;
  final Future<T> Function() _fetch;
  final T Function(Map<String, dynamic> json) _decode;
  final Map<String, dynamic> Function(T item) _encode;
  final DateTime Function(T item) _updatedAt;

  @override
  Stream<T?> watch() {
    return cache
        .watchPayload(type, projectId, itemId)
        .map(
          (payload) => payload == null
              ? null
              : _decode(jsonDecode(payload) as Map<String, dynamic>),
        );
  }

  @override
  Future<void> refresh() async {
    try {
      await load();
    } on DioException {
      return;
    }
  }

  /// Fetches the item and writes it through to the cache, rethrowing network
  /// failures so an imperative caller can fall back to [readCached].
  Future<T> load() async {
    final item = await _fetch();
    await writeThrough(item);
    return item;
  }

  Future<void> writeThrough(T item) async {
    try {
      await cache.putIf(
        type,
        projectId,
        itemId,
        jsonEncode(_encode(item)),
        shouldReplace: (payload) {
          if (payload == null) return true;
          final existing = _decode(jsonDecode(payload) as Map<String, dynamic>);
          return !_updatedAt(item).isBefore(_updatedAt(existing));
        },
      );
    } on Object catch (error, stackTrace) {
      log(
        'Unable to persist recently viewed item',
        name: 'gitsune.recently_viewed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// One-shot cached read that also records the view, keeping an item the
  /// user opens offline protected from least-recently-viewed eviction.
  Future<T?> readCached() async {
    try {
      await cache.touch(type, projectId, itemId);
    } on Object catch (error, stackTrace) {
      log(
        'Unable to touch recently viewed item',
        name: 'gitsune.recently_viewed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      return await watch().first;
    } on Object catch (error, stackTrace) {
      log(
        'Unable to read recently viewed item',
        name: 'gitsune.recently_viewed',
        error: error,
        stackTrace: stackTrace,
      );
      try {
        await cache.remove(type, projectId, itemId);
      } on Object catch (removeError, removeStackTrace) {
        log(
          'Unable to remove invalid recently viewed item',
          name: 'gitsune.recently_viewed',
          error: removeError,
          stackTrace: removeStackTrace,
        );
      }
      return null;
    }
  }
}
