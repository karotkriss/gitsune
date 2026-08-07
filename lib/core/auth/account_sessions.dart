import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';

/// The multi-account, multi-instance session registry (E2.6), over the
/// account-scoped `Accounts` table: each signed-in session is one row keyed
/// by the composite key (`instanceHost` + `accountId`), so any number of
/// accounts across any number of instances coexist and one account's state
/// never touches another's.
///
/// Tokens themselves stay in `TokenStore` under the same composite key; this
/// registry owns which sessions exist and whether each needs
/// re-authentication.
class AccountSessions {
  AccountSessions(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  /// Registers a completed sign-in. Signing in an already-registered account
  /// (re-auth) clears its [Account.needsReauth] mark and keeps its original
  /// [Account.addedAt] switcher position.
  Future<void> signedIn(AccountKey account) => _database.transaction(() async {
    final latest =
        await (_database.select(_database.accounts)
              ..orderBy([(row) => OrderingTerm.desc(row.addedAt)])
              ..limit(1))
            .getSingleOrNull();
    final now = _now();
    final addedAt = latest == null || now.isAfter(latest.addedAt)
        ? now
        : latest.addedAt.add(const Duration(microseconds: 1));

    await _database
        .into(_database.accounts)
        .insert(
          AccountsCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            addedAt: addedAt,
          ),
          onConflict: DoUpdate(
            (_) => const AccountsCompanion(needsReauth: Value(false)),
          ),
        );
  });

  /// Marks only [account] as needing re-authentication after its instance
  /// rejected a token refresh. The row stays registered - the switcher keeps
  /// listing it - and every other account is untouched. Wire this into
  /// `TokenRefreshCoordinator.onReauthRequired`.
  Future<void> markNeedsReauth(AccountKey account) =>
      (_database.update(_database.accounts)..where(
            (row) =>
                row.instanceHost.equals(account.instanceHost) &
                row.accountId.equals(account.accountId),
          ))
          .write(const AccountsCompanion(needsReauth: Value(true)));

  /// All signed-in accounts in sign-in order, re-auth-marked ones included.
  Stream<List<Account>> watchAll() =>
      (_database.select(_database.accounts)..orderBy([
            (row) => OrderingTerm.asc(row.addedAt),
            (row) => OrderingTerm.asc(row.instanceHost),
            (row) => OrderingTerm.asc(row.accountId),
          ]))
          .watch();

  /// [watchAll] joined with each account's cached `CurrentUserProfiles` row
  /// (null until `CurrentUserRepository` caches one), for surfaces that show
  /// avatar and username per session (E13.2).
  Stream<List<AccountWithProfile>> watchAllWithProfiles() {
    final accounts = _database.accounts;
    final profiles = _database.currentUserProfiles;
    final query =
        _database.select(accounts).join([
          leftOuterJoin(
            profiles,
            profiles.instanceHost.equalsExp(accounts.instanceHost) &
                profiles.accountId.equalsExp(accounts.accountId),
          ),
        ])..orderBy([
          OrderingTerm.asc(accounts.addedAt),
          OrderingTerm.asc(accounts.instanceHost),
          OrderingTerm.asc(accounts.accountId),
        ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            account: row.readTable(accounts),
            profile: row.readTableOrNull(profiles),
          ),
      ],
    );
  }

  /// Rewrites switcher positions so [watchAll] lists accounts in [order],
  /// which must be a permutation of every registered account. The existing
  /// [Account.addedAt] values are reassigned in the new order, so positions
  /// stay unique and a later [signedIn] still appends to the end.
  Future<void> reorder(List<AccountKey> order) =>
      _database.transaction(() async {
        final slots =
            (await (_database.select(
                  _database.accounts,
                )..orderBy([(row) => OrderingTerm.asc(row.addedAt)])).get())
                .map((row) => row.addedAt)
                .toList();
        for (var index = 0; index < order.length; index++) {
          final account = order[index];
          await (_database.update(_database.accounts)..where(
                (row) =>
                    row.instanceHost.equals(account.instanceHost) &
                    row.accountId.equals(account.accountId),
              ))
              .write(AccountsCompanion(addedAt: Value(slots[index])));
        }
      });

  /// Signs [account] out of this device: deletes its registry row and every
  /// account-scoped local row (caches, drafts, per-account settings) in one
  /// transaction. Token material lives in `TokenStore`; the caller clears
  /// that separately.
  Future<void> remove(AccountKey account) => _database.transaction(() async {
    for (final table in _database.allTables) {
      if (!table.columnsByName.containsKey('instance_host')) continue;
      await _database.customUpdate(
        'DELETE FROM "${table.actualTableName}" '
        'WHERE instance_host = ? AND account_id = ?',
        variables: [
          Variable.withString(account.instanceHost),
          Variable.withString(account.accountId),
        ],
        updates: {table},
        updateKind: UpdateKind.delete,
      );
    }
  });
}

/// One account-management row: the registry row plus its cached profile.
typedef AccountWithProfile = ({Account account, CurrentUserProfile? profile});
