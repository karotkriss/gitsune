import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/account_sessions.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/accounts/accounts_screen.dart';

import '../support/memory_secure_storage.dart';

void main() {
  const alice = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
  const bob = AccountKey(instanceHost: 'gitlab.com', accountId: '2');
  const selfHostedAlice = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: '1',
  );

  late AppDatabase database;
  late AccountSessions sessions;
  late ActiveAccountStore activeAccount;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sessions = AccountSessions(
      database,
      now: () => DateTime.utc(2026, 8, 7, 9),
    );
    activeAccount = ActiveAccountStore(storage: MemorySecureStorage());

    // Two accounts on gitlab.com plus one self-hosted whose refresh was
    // rejected and whose profile is not cached yet: the golden covers the
    // username row, the active check, the account-id fallback, and the
    // re-auth label, with the host on every row.
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await sessions.signedIn(selfHostedAlice);
    await sessions.markNeedsReauth(selfHostedAlice);
    for (final (key, username, name) in [
      (alice, 'alice', 'Alice Weiss'),
      (bob, 'bob', 'Bob Muster'),
    ]) {
      await database
          .into(database.currentUserProfiles)
          .insert(
            CurrentUserProfilesCompanion.insert(
              instanceHost: key.instanceHost,
              accountId: key.accountId,
              username: username,
              name: name,
              updatedAt: DateTime.utc(2026, 8, 7, 9),
            ),
          );
    }
    await activeAccount.setActive(alice);
  });

  tearDown(() => database.close());

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  void sizeView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('account management surface matches golden', (tester) async {
    sizeView(tester);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: AccountsScreen(sessions: sessions, activeAccount: activeAccount),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/accounts_screen.png'),
    );
    await unmount(tester);
  });

  testWidgets('account quick-switch sheet matches golden', (tester) async {
    sizeView(tester);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showAccountSwitchSheet(
                  context,
                  sessions: sessions,
                  activeAccount: activeAccount,
                ),
                child: const Text('Switch'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/account_switch_sheet.png'),
    );
    await unmount(tester);
  });
}
