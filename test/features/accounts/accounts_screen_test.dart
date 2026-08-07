import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/account_sessions.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/accounts/accounts_screen.dart';

import '../../support/memory_secure_storage.dart';

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
  late SecureTokenStore tokenStore;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sessions = AccountSessions(database);
    activeAccount = ActiveAccountStore(storage: MemorySecureStorage());
    tokenStore = SecureTokenStore(storage: MemorySecureStorage());
  });

  tearDown(() => database.close());

  Future<void> cacheProfile(AccountKey key, String username) => database
      .into(database.currentUserProfiles)
      .insert(
        CurrentUserProfilesCompanion.insert(
          instanceHost: key.instanceHost,
          accountId: key.accountId,
          username: username,
          name: username,
          updatedAt: DateTime.now(),
        ),
      );

  Future<void> pumpScreen(WidgetTester tester, {VoidCallback? onAdd}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: AccountsScreen(
          sessions: sessions,
          activeAccount: activeAccount,
          tokenStore: tokenStore,
          onAddAccount: onAdd,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Cancelling a drift query stream schedules a zero-duration real timer;
  // unmount and elapse fake time so no test ends with pending timers.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('every row shows its username (or account id fallback) and '
      'host', (tester) async {
    await sessions.signedIn(alice);
    await sessions.signedIn(selfHostedAlice);
    await cacheProfile(alice, 'alice');

    await pumpScreen(tester);

    expect(find.text('@alice'), findsOneWidget);
    expect(find.text('gitlab.com'), findsOneWidget);
    // No cached profile yet: the registry's account id stands in, and the
    // host still shows.
    expect(find.text('Account 1'), findsOneWidget);
    expect(find.text('gitlab.example.com'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('tapping a row switches with a single state change', (
    tester,
  ) async {
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await cacheProfile(alice, 'alice');
    await cacheProfile(bob, 'bob');
    await activeAccount.setActive(alice);
    var notifications = 0;
    activeAccount.addListener(() => notifications++);

    await pumpScreen(tester);
    await tester.tap(find.text('@bob'));
    await tester.pumpAndSettle();

    expect(activeAccount.value, bob);
    expect(notifications, 1);
    await unmount(tester);
  });

  testWidgets('a re-auth-marked row is labeled', (tester) async {
    await sessions.signedIn(alice);
    await sessions.markNeedsReauth(alice);

    await pumpScreen(tester);

    expect(find.text('Sign-in required'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('removing an account asks for confirmation, then deletes the '
      'row, its tokens, and hands the active slot to the next account', (
    tester,
  ) async {
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await cacheProfile(alice, 'alice');
    await cacheProfile(bob, 'bob');
    await tokenStore.save(alice, OAuthTokens(accessToken: 'at-alice'));
    await activeAccount.setActive(alice);

    await pumpScreen(tester);
    await tester.tap(find.byTooltip('Remove account').first);
    await tester.pumpAndSettle();
    expect(find.text('Remove @alice?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('@alice'), findsNothing);
    expect(find.text('@bob'), findsOneWidget);
    expect(await tokenStore.read(alice), isNull);
    expect(activeAccount.value, bob);
    await unmount(tester);
  });

  testWidgets('cancelling the confirmation removes nothing', (tester) async {
    await sessions.signedIn(alice);
    await cacheProfile(alice, 'alice');

    await pumpScreen(tester);
    await tester.tap(find.byTooltip('Remove account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('@alice'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('dragging the grip handle reorders the switcher and the order '
      'persists', (tester) async {
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await cacheProfile(alice, 'alice');
    await cacheProfile(bob, 'bob');

    await pumpScreen(tester);
    expect(
      tester.getTopLeft(find.text('@alice')).dy,
      lessThan(tester.getTopLeft(find.text('@bob')).dy),
    );

    await tester.timedDrag(
      find.byKey(const ValueKey('drag-gitlab.com-1')),
      const Offset(0, 120),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('@bob')).dy,
      lessThan(tester.getTopLeft(find.text('@alice')).dy),
    );

    // The registry persisted the new order: it comes back on a fresh screen,
    // as it would across an app restart.
    await unmount(tester);
    await pumpScreen(tester);
    expect(
      tester.getTopLeft(find.text('@bob')).dy,
      lessThan(tester.getTopLeft(find.text('@alice')).dy),
    );
    await unmount(tester);
  });

  testWidgets('with no accounts, the surface offers only adding one', (
    tester,
  ) async {
    var added = false;
    await pumpScreen(tester, onAdd: () => added = true);

    expect(
      find.text('No accounts yet. Add one to get started.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Add account'));
    expect(added, isTrue);
    await unmount(tester);
  });

  testWidgets('the quick-switch sheet lists every account with its host and '
      'switches in a single state change', (tester) async {
    await sessions.signedIn(alice);
    await sessions.signedIn(selfHostedAlice);
    await cacheProfile(alice, 'alice');
    await cacheProfile(selfHostedAlice, 'alice');
    await activeAccount.setActive(alice);
    var notifications = 0;
    activeAccount.addListener(() => notifications++);

    await tester.pumpWidget(
      MaterialApp(
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

    // The same username on two instances: only the host tells them apart.
    expect(find.text('@alice'), findsNWidgets(2));
    expect(find.text('gitlab.com'), findsOneWidget);
    expect(find.text('gitlab.example.com'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('switch-gitlab.example.com-1')));
    await tester.pumpAndSettle();

    expect(activeAccount.value, selfHostedAlice);
    expect(notifications, 1);
    expect(find.text('Switch account'), findsNothing);
    await unmount(tester);
  });
}
