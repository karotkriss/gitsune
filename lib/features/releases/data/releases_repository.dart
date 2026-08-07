import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/account_key.dart';
import '../../../core/network/keyset_paginator.dart';

/// Read seam consumed by the release screens, offline-first per the E3.3
/// seam: [watchReleases] and [watchRelease] are reactive database reads of a
/// project's cached releases; [refreshReleases] fetches the project's
/// releases from the network and writes through, swallowing network failures
/// so the streams keep serving the cache. [downloadAsset] (E11.2) is
/// network-only, since a downloaded file has no cache row to write through.
abstract interface class ReleasesRepository {
  Stream<List<ReleaseEntry>> watchReleases(int projectId);

  Stream<ReleaseEntry?> watchRelease(int projectId, String tagName);

  Future<void> refreshReleases(int projectId);

  /// Downloads [asset] to [destinationPath], authenticated via the account's
  /// client so a private project's assets work. Reports progress through
  /// [onProgress] as `(received, total)` bytes; `total` is `-1` when the
  /// server response omits `Content-Length`.
  Future<void> downloadAsset(
    ReleaseAssetLink asset,
    String destinationPath, {
    void Function(int received, int total)? onProgress,
  });
}

/// GitLab releases reader (`GET /projects/:id/releases`), account-scoped and
/// cached in drift.
///
/// A refresh follows every pagination `Link` header via the E3.4 paginator,
/// then replaces the project's cached rows in one transaction, preserving
/// GitLab's server-side ordering (newest release first) through the
/// `position` column.
class GitLabReleasesRepository implements ReleasesRepository {
  GitLabReleasesRepository({
    required this.database,
    required this.client,
    required this.account,
  });

  final AppDatabase database;
  final Dio client;
  final AccountKey account;
  final _inFlightRefreshes = <int, Future<void>>{};

  @override
  Stream<List<ReleaseEntry>> watchReleases(int projectId) {
    final query = database.select(database.releaseEntries)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId) &
            t.projectId.equals(projectId),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    return query.watch();
  }

  @override
  Stream<ReleaseEntry?> watchRelease(int projectId, String tagName) {
    final query = database.select(database.releaseEntries)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId) &
            t.projectId.equals(projectId) &
            t.tagName.equals(tagName),
      );
    return query.watchSingleOrNull();
  }

  @override
  Future<void> refreshReleases(int projectId) {
    final inFlight = _inFlightRefreshes[projectId];
    if (inFlight != null) return inFlight;

    final refresh = _performRefresh(projectId);
    _inFlightRefreshes[projectId] = refresh;
    return refresh.whenComplete(() => _inFlightRefreshes.remove(projectId));
  }

  Future<void> _performRefresh(int projectId) async {
    var position = 0;
    final paginator = KeysetPaginator<ReleaseEntriesCompanion>(
      dio: client,
      initialUri: _releasesUri(projectId),
      decode: (json) => _decodeRelease(json, projectId, position++),
    );

    final rows = <ReleaseEntriesCompanion>[];
    try {
      while (paginator.hasMore) {
        rows.addAll((await paginator.loadNext()).items);
      }
    } on DioException {
      return;
    }

    await database.transaction(() async {
      await (database.delete(database.releaseEntries)..where(
            (t) =>
                t.instanceHost.equals(account.instanceHost) &
                t.accountId.equals(account.accountId) &
                t.projectId.equals(projectId),
          ))
          .go();
      await database.batch(
        (batch) => batch.insertAll(database.releaseEntries, rows),
      );
    });
  }

  @override
  Future<void> downloadAsset(
    ReleaseAssetLink asset,
    String destinationPath, {
    void Function(int received, int total)? onProgress,
  }) async {
    await client.downloadUri(
      Uri.parse(asset.url),
      destinationPath,
      onReceiveProgress: onProgress,
    );
  }

  Uri _releasesUri(int projectId) {
    final base = client.options.baseUrl.endsWith('/')
        ? client.options.baseUrl
        : '${client.options.baseUrl}/';
    return Uri.parse(base)
        .resolve('projects/$projectId/releases')
        .replace(queryParameters: {'page': '1', 'per_page': '100'});
  }

  ReleaseEntriesCompanion _decodeRelease(
    Map<String, dynamic> json,
    int projectId,
    int position,
  ) {
    final tagName = json['tag_name'] as String;
    final author = json['author'] as Map<String, dynamic>?;
    return ReleaseEntriesCompanion.insert(
      instanceHost: account.instanceHost,
      accountId: account.accountId,
      projectId: projectId,
      tagName: tagName,
      name: json['name'] as String? ?? tagName,
      description: json['description'] as String? ?? '',
      // released_at may be absent on a draft-style release; created_at is
      // always present.
      releasedAt: DateTime.parse(
        (json['released_at'] ?? json['created_at']) as String,
      ),
      authorName: Value(author?['name'] as String?),
      assetsJson: jsonEncode(json['assets'] ?? const <String, dynamic>{}),
      position: position,
    );
  }
}

/// One downloadable entry of a release's assets: a custom link or an
/// auto-generated source archive.
class ReleaseAssetLink {
  const ReleaseAssetLink({required this.name, required this.url});

  final String name;
  final String url;
}

/// Flattens a cached release's `assets` object into a display list: custom
/// links first (as GitLab orders them), then the auto-generated source
/// archives. Entries missing a URL are dropped.
List<ReleaseAssetLink> releaseAssetLinks(ReleaseEntry release) {
  final assets = jsonDecode(release.assetsJson);
  if (assets is! Map<String, dynamic>) return const [];
  final links = <ReleaseAssetLink>[
    for (final link in assets['links'] as List? ?? const [])
      if (link is Map<String, dynamic>)
        ReleaseAssetLink(
          name: link['name'] as String? ?? '',
          url: (link['direct_asset_url'] ?? link['url']) as String? ?? '',
        ),
    for (final source in assets['sources'] as List? ?? const [])
      if (source is Map<String, dynamic>)
        ReleaseAssetLink(
          name: 'Source code (${source['format']})',
          url: source['url'] as String? ?? '',
        ),
  ];
  return links.where((link) => link.url.isNotEmpty).toList(growable: false);
}
