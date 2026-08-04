import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/quiet_hours.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/settings/quiet_hours_screen.dart';

void main() {
  const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');

  late AppDatabase database;
  late QuietHoursStore store;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    store = QuietHoursStore(database: database, account: account);
  });

  tearDown(() => database.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: QuietHoursScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the defaults and persists toggling the switch', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('10:00 PM'), findsOneWidget);
    expect(find.text('7:00 AM'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect((await store.read()).enabled, isTrue);
  });

  testWidgets('picking a start time persists the new window', (tester) async {
    await store.save(QuietHours.defaults.copyWith(enabled: true));
    await pumpScreen(tester);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    // The dial picker opens on the hour ring; 9 PM sits at the 9 o'clock
    // ring position, but entering text via input mode is deterministic.
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final saved = await store.read();
    expect(saved.startMinutes, 21 * 60);
    expect(saved.endMinutes, 7 * 60, reason: 'end is untouched');
    expect(find.text('9:00 PM'), findsOneWidget);
  });
}
