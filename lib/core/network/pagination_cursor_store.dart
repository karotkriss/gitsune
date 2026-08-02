import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'account_key.dart';

/// Reads and writes a [KeysetPaginator]'s resume token (see
/// `keyset_paginator.dart`) in the account-scoped `PaginationCursors` table,
/// so an interrupted listing can resume across app restarts.
class PaginationCursorStore {
  PaginationCursorStore(this._db);

  final AppDatabase _db;

  Future<String?> read(AccountKey account, String collectionKey) async {
    final row =
        await (_db.select(_db.paginationCursors)..where(
              (t) =>
                  t.instanceHost.equals(account.instanceHost) &
                  t.accountId.equals(account.accountId) &
                  t.collectionKey.equals(collectionKey),
            ))
            .getSingleOrNull();
    return row?.cursorUri;
  }

  Future<void> save(
    AccountKey account,
    String collectionKey,
    String cursorUri,
  ) {
    return _db
        .into(_db.paginationCursors)
        .insertOnConflictUpdate(
          PaginationCursorsCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            collectionKey: collectionKey,
            cursorUri: cursorUri,
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Clears the resume token, e.g. once a listing reaches its last page.
  Future<void> clear(AccountKey account, String collectionKey) {
    return (_db.delete(_db.paginationCursors)..where(
          (t) =>
              t.instanceHost.equals(account.instanceHost) &
              t.accountId.equals(account.accountId) &
              t.collectionKey.equals(collectionKey),
        ))
        .go();
  }
}
