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
    // Taller than a device viewport so the golden captures the whole wizard,
    // including the generated webhook configuration below the fold.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: RelayWizardScreen(store: store, sendTest: sendTest),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('configured ntfy wizard matches the golden', (tester) async {
    await store.save(
      RelaySetup.defaults.copyWith(enabled: true, ntfyTopic: 'gitsune-a1b2c3'),
    );
    await pumpScreen(tester);

    await expectLater(
      find.byType(RelayWizardScreen),
      matchesGoldenFile('goldens/relay_wizard_ntfy.png'),
    );
  });

  testWidgets('unreachable-relay error state matches the golden', (
    tester,
  ) async {
    await store.save(RelaySetup.defaults.copyWith(ntfyTopic: 'gitsune-a1b2c3'));
    await pumpScreen(
      tester,
      sendTest: (_) async =>
          throw const RelayTestException(RelayTestFailure.unreachable),
    );

    await tester.tap(find.byKey(const ValueKey('relay-test-button')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RelayWizardScreen),
      matchesGoldenFile('goldens/relay_wizard_error.png'),
    );
  });
}
