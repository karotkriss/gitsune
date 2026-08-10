import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/lock/app_lock.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';
import 'package:gitsune/main.dart';

import '../../support/fake_biometric_authenticator.dart';
import '../../support/memory_secure_storage.dart';

/// The regression test for the field "sign-in does nothing" bug: it drives the
/// production composition root (`GitsuneApp`), not a stubbed screen, and asserts
/// a completed sign-in produces a SIGNED-IN APP - the router leaves the sign-in
/// screen for the signed-in shell, the session registry records the account,
/// and the active-account store points at it. A stubbed OAuth seam stands in
/// for the browser so no live instance or platform browser is touched.
void main() {
  testWidgets('a completed gitlab.com sign-in produces a signed-in app: it '
      'leaves the sign-in screen, records the session, and makes it active', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final appLock = AppLockController(
      authenticator: FakeBiometricAuthenticator(),
      storage: MemorySecureStorage(),
    );
    addTearDown(appLock.dispose);
    await appLock.load();
    final activeAccount = ActiveAccountStore(storage: MemorySecureStorage());
    addTearDown(activeAccount.dispose);

    const account = AccountKey(instanceHost: 'gitlab.com', accountId: '42');
    var signIns = 0;

    await tester.pumpWidget(
      GitsuneApp(
        appLockController: appLock,
        database: database,
        tokenStore: SecureTokenStore(storage: MemorySecureStorage()),
        activeAccount: activeAccount,
        // Stand in for the system-browser OAuth leg with a completed result.
        signInGitlabCom: () async {
          signIns++;
          return (
            account: account,
            tokens: const OAuthTokens(accessToken: 'access-token'),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Signed out at startup: the shell is up and no account is active.
    expect(activeAccount.value, isNull);
    expect(find.byType(SignInScreen), findsNothing);

    // Reach the sign-in screen the way a user does, from the Profile tab.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);

    // gitlab.com is pre-filled; completing OAuth must flip the app signed-in.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(signIns, 1);

    // Router asserted: the sign-in screen is gone and the shell is back.
    expect(find.byType(SignInScreen), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Active-account store asserted: it now holds the signed-in account.
    expect(activeAccount.value, account);

    // Session registry asserted: the account is recorded (one-shot read, never
    // an awaited drift stream, which would deadlock a widget test).
    final registered = await tester.runAsync(
      () => database.select(database.accounts).get(),
    );
    expect(
      registered!.map((row) => (row.instanceHost, row.accountId)),
      contains(('gitlab.com', '42')),
    );

    // The router is the signed-in composition (not the signed-out one): its
    // Profile tab exposes account management, wired only when signed in.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Switch account'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);

    // Unmount and elapse time so the drift-backed home tile-order stream's
    // pending cancellation timer runs before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
