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
  AccountSessions(this._database);

  final AppDatabase _database;

  /// Registers a completed sign-in. Signing in an already-registered account
  /// (re-auth) clears its [Account.needsReauth] mark and keeps its original
  /// [Account.addedAt] switcher position.
  Future<void> signedIn(AccountKey account) => _database
      .into(_database.accounts)
      .insert(
        AccountsCompanion.insert(
          instanceHost: account.instanceHost,
          accountId: account.accountId,
          addedAt: DateTime.now(),
        ),
        onConflict: DoUpdate(
          (_) => const AccountsCompanion(needsReauth: Value(false)),
        ),
      );

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
}
