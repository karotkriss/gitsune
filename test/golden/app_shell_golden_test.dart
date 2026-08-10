import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/lock/app_lock.dart';
import 'package:gitsune/main.dart';

import '../support/fake_biometric_authenticator.dart';
import '../support/memory_secure_storage.dart';

void main() {
  const tabs = {
    'Home': ('Home', 'shell_home'),
    'To-Dos': ('To-Do List', 'shell_todos'),
    'Explore': ('Explore', 'shell_explore'),
    'Profile': ('Profile', 'shell_profile'),
  };

  for (final MapEntry(key: label, value: tab) in tabs.entries) {
    testWidgets('$label tab navigates and matches the dark-theme golden', (
      tester,
    ) async {
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

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(tab.$1),
        tab.$1 == label ? findsNWidgets(2) : findsOneWidget,
      );

      await expectLater(
        find.byType(GitsuneApp),
        matchesGoldenFile('goldens/${tab.$2}.png'),
      );
    });
  }
}
