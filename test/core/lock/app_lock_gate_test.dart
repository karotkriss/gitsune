import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/lock/app_lock.dart';
import 'package:gitsune/core/lock/app_lock_gate.dart';
import 'package:gitsune/core/theme/app_theme.dart';

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

  tearDown(() {
    controller.dispose();
    // Later tests must not inherit a backgrounded lifecycle.
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
  });

  Future<void> pumpGate(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: AppLockGate(controller: controller, child: const Text('content')),
    ),
  );

  Finder lockScreen() => find.text('Gitsune is locked');

  testWidgets('enabled lock gates a cold launch until the check passes', (
    tester,
  ) async {
    storage.values['gitsune.appLock.enabled'] = 'true';
    await controller.load();

    await pumpGate(tester);
    expect(lockScreen(), findsOneWidget);

    // The gate auto-prompts; the fake passes and the app opens.
    await tester.pumpAndSettle();
    expect(lockScreen(), findsNothing);
    expect(authenticator.authCalls, 1);
  });

  testWidgets('disabled lock passes straight through without prompting', (
    tester,
  ) async {
    await controller.load();

    await pumpGate(tester);
    await tester.pumpAndSettle();
    expect(lockScreen(), findsNothing);
    expect(authenticator.authCalls, 0);
  });

  testWidgets('unavailable hardware degrades open instead of hard-locking', (
    tester,
  ) async {
    storage.values['gitsune.appLock.enabled'] = 'true';
    await controller.load();
    authenticator.supported = false;

    await pumpGate(tester);
    await tester.pumpAndSettle();
    expect(lockScreen(), findsNothing);
    expect(authenticator.authCalls, 0);
  });

  testWidgets('a failed check stays locked and the button retries', (
    tester,
  ) async {
    storage.values['gitsune.appLock.enabled'] = 'true';
    await controller.load();
    authenticator.result = BiometricResult.failure;

    await pumpGate(tester);
    await tester.pumpAndSettle();
    expect(lockScreen(), findsOneWidget);

    authenticator.result = BiometricResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(lockScreen(), findsNothing);
  });

  testWidgets('locked content cannot receive input or expose semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    storage.values['gitsune.appLock.enabled'] = 'true';
    await controller.load();
    authenticator.result = BiometricResult.failure;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: AppLockGate(
          controller: controller,
          child: Center(
            child: FilledButton(
              onPressed: () => presses += 1,
              child: const Text('Sensitive action'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sensitive action'), findsOneWidget);
    expect(find.bySemanticsLabel('Sensitive action'), findsNothing);
    await tester.tap(find.text('Sensitive action'), warnIfMissed: false);
    expect(presses, 0);
    semantics.dispose();
  });

  testWidgets('leaving the foreground re-locks and resume prompts again', (
    tester,
  ) async {
    storage.values['gitsune.appLock.enabled'] = 'true';
    await controller.load();

    await pumpGate(tester);
    await tester.pumpAndSettle();
    expect(lockScreen(), findsNothing);
    expect(authenticator.authCalls, 1);

    // No frames build while hidden, so assert the re-lock on the controller.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(controller.locked, isTrue);

    // Back in the foreground the lock screen renders, then the resume
    // prompt passes and opens the gate again.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(lockScreen(), findsOneWidget);
    await tester.pumpAndSettle();
    expect(lockScreen(), findsNothing);
    expect(authenticator.authCalls, 2);
  });
}
