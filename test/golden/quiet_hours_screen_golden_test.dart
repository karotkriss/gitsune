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

  testWidgets('Quiet hours screen matches the golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = QuietHoursStore(database: database, account: account);
    await store.save(
      const QuietHours(
        enabled: true,
        startMinutes: 22 * 60,
        endMinutes: 7 * 60,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: QuietHoursScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(QuietHoursScreen),
      matchesGoldenFile('goldens/quiet_hours_screen.png'),
    );
  });
}
