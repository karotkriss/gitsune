import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/lock/app_lock.dart';
import 'package:gitsune/main.dart';

import 'support/fake_biometric_authenticator.dart';
import 'support/memory_secure_storage.dart';

void main() {
  testWidgets('boots to a dark-themed shell with four tabs', (tester) async {
    final appLock = AppLockController(
      authenticator: FakeBiometricAuthenticator(),
      storage: MemorySecureStorage(),
    );
    addTearDown(appLock.dispose);
    await appLock.load();
    final activeAccount = ActiveAccountStore(storage: MemorySecureStorage());
    addTearDown(activeAccount.dispose);

    await tester.pumpWidget(
      GitsuneApp(appLockController: appLock, activeAccount: activeAccount),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme!.brightness, Brightness.dark);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });
}
