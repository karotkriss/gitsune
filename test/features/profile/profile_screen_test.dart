import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/lock/app_lock.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/profile/profile_screen.dart';

import '../../support/fake_biometric_authenticator.dart';
import '../../support/memory_secure_storage.dart';

void main() {
  late FakeBiometricAuthenticator authenticator;
  late MemorySecureStorage storage;
  late AppLockController controller;

  setUp(() {
    authenticator = FakeBiometricAuthenticator();
    storage = MemorySecureStorage();
    controller = AppLockController(
      authenticator: authenticator,
      storage: storage,
    );
  });

  tearDown(() => controller.dispose());

  Future<void> pumpProfile(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: ProfileScreen(appLockController: controller),
    ),
  );

  testWidgets('the toggle arms the lock after one passed check', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.enabled, isTrue);
    expect(authenticator.authCalls, 1);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
  });

  testWidgets('an unsupported device keeps the toggle off and explains why', (
    tester,
  ) async {
    authenticator.supported = false;
    await pumpProfile(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.enabled, isFalse);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.textContaining('Could not verify'), findsOneWidget);
  });

  testWidgets('a failed enable write keeps the toggle off and reports it', (
    tester,
  ) async {
    storage.writeError = StateError('keystore unavailable');
    await pumpProfile(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.enabled, isFalse);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.text('Could not save the app lock setting.'), findsOneWidget);
  });

  testWidgets('a failed disable write keeps the toggle on and reports it', (
    tester,
  ) async {
    await controller.setEnabled(true);
    storage.writeError = StateError('keystore unavailable');
    await pumpProfile(tester);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.enabled, isTrue);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    expect(find.text('Could not save the app lock setting.'), findsOneWidget);
  });

  testWidgets('without a controller the profile shows no lock toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const ProfileScreen()),
    );
    expect(find.byType(SwitchListTile), findsNothing);
  });
}
