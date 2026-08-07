import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/relay_setup.dart';
import 'package:gitsune/core/notifications/relay_webhook.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/settings/relay_wizard_screen.dart';

void main() {
  const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
  const appToken = 'azGDORePK8gMaC0QOYAMyEEuzJnyUi';
  const userKey = 'uQiRzpo4DXghDmr9QzzfQu27cmVRsG';

  late AppDatabase database;
  late RelaySetupStore store;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    store = RelaySetupStore(database: database, account: account);
  });

  tearDown(() => database.close());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<void> Function(RelayTarget target)? sendTest,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: RelayWizardScreen(store: store, sendTest: sendTest),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enterTopicSetup(WidgetTester tester, String topic) async {
    final field = find.byKey(const ValueKey('relay-ntfy-topic'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, topic);
    await tester.pumpAndSettle();
  }

  testWidgets('opt-in defaults off with ntfy prefilled and no config yet', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('relay-enabled-switch')),
          )
          .value,
      isFalse,
    );
    expect(find.text('https://ntfy.sh'), findsOneWidget);
    expect(
      find.text('Finish step 2 to generate the webhook configuration.'),
      findsOneWidget,
    );
    expect((await store.read()).enabled, isFalse);
  });

  testWidgets('toggling the switch persists the opt-in', (tester) async {
    await pumpScreen(tester);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('relay-enabled-switch')),
    );

    expect((await store.read()).enabled, isTrue);
  });

  testWidgets('an invalid topic surfaces its error and blocks the send', (
    tester,
  ) async {
    var sends = 0;
    await pumpScreen(tester, sendTest: (_) async => sends++);

    await enterTopicSetup(tester, 'not a topic!');
    await tapVisible(tester, find.byKey(const ValueKey('relay-test-button')));

    expect(
      find.text(
        'Topic names use only letters, digits, - and _, '
        'up to 64 characters.',
      ),
      findsOneWidget,
    );
    expect(sends, 0);
  });

  testWidgets('a passing test sends to the entered relay and confirms', (
    tester,
  ) async {
    RelayTarget? sent;
    await pumpScreen(tester, sendTest: (target) async => sent = target);

    await enterTopicSetup(tester, 'gitsune-a1b2c3');
    await tapVisible(tester, find.byKey(const ValueKey('relay-test-button')));

    final target = sent! as NtfyTarget;
    expect(target.server, Uri.parse('https://ntfy.sh'));
    expect(target.topic, 'gitsune-a1b2c3');
    expect(
      find.text('Sent. Check the ntfy app on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('an unreachable relay shows the actionable error', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      sendTest: (_) async =>
          throw const RelayTestException(RelayTestFailure.unreachable),
    );

    await enterTopicSetup(tester, 'gitsune-a1b2c3');
    await tapVisible(tester, find.byKey(const ValueKey('relay-test-button')));

    expect(
      find.text(
        'Could not reach ntfy.sh. Check the server address and your '
        'connection, then try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('valid ntfy details generate the webhook configuration', (
    tester,
  ) async {
    await pumpScreen(tester);

    await enterTopicSetup(tester, 'gitsune-a1b2c3');

    expect(
      find.text(
        buildRelayWebhookConfig(
          NtfyTarget(
            server: Uri.parse('https://ntfy.sh'),
            topic: 'gitsune-a1b2c3',
          ),
        ).payloadTemplate,
      ),
      findsOneWidget,
    );
  });

  testWidgets('the Pushover path collects credentials and reports rejection', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      sendTest: (_) async =>
          throw const RelayTestException(RelayTestFailure.rejected),
    );

    await tapVisible(tester, find.text('Pushover'));
    final tokenField = find.byKey(const ValueKey('relay-pushover-token'));
    await tester.ensureVisible(tokenField);
    await tester.pumpAndSettle();
    await tester.enterText(tokenField, appToken);
    await tester.enterText(
      find.byKey(const ValueKey('relay-pushover-user')),
      userKey,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('https://api.pushover.net/1/messages.json'),
      findsOneWidget,
    );

    await tapVisible(tester, find.byKey(const ValueKey('relay-test-button')));

    expect(
      find.text(
        'Pushover rejected the credentials. Check the application '
        'API token and your user key in the Pushover dashboard.',
      ),
      findsOneWidget,
    );

    final saved = await store.read();
    expect(saved.service, RelayService.pushover);
    expect(saved.pushoverAppToken, appToken);
    expect(saved.pushoverUserKey, userKey);
  });

  test('the store never leaks a setup across accounts', () async {
    await store.save(
      RelaySetup.defaults.copyWith(enabled: true, ntfyTopic: 'gitsune-a1b2c3'),
    );

    final other = RelaySetupStore(
      database: database,
      account: const AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: '2',
      ),
    );
    final read = await other.read();
    expect(read.enabled, isFalse);
    expect(read.ntfyTopic, isEmpty);
  });
}
