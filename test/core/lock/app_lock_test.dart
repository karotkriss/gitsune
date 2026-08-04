import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/lock/app_lock.dart';

import '../../support/fake_biometric_authenticator.dart';
import '../../support/memory_secure_storage.dart';

class _ThrowingStorage extends MemorySecureStorage {
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw StateError('keystore unavailable');
}

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

  test('load with nothing persisted leaves the lock off and open', () async {
    expect(controller.loaded, isFalse);
    await controller.load();
    expect(controller.loaded, isTrue);
    expect(controller.enabled, isFalse);
    expect(controller.locked, isFalse);
  });

  test('load with the lock enabled starts locked (cold-launch gate)', () async {
    storage.values['gitsune.appLock.enabled'] = 'true';
    await controller.load();
    expect(controller.enabled, isTrue);
    expect(controller.locked, isTrue);
  });

  test('an unreadable store means disabled, never a hard lock', () async {
    final broken = AppLockController(
      authenticator: authenticator,
      storage: _ThrowingStorage(),
    );
    addTearDown(broken.dispose);
    await broken.load();
    expect(broken.enabled, isFalse);
    expect(broken.locked, isFalse);
  });

  test('enabling requires one passed check and persists the flag', () async {
    expect(await controller.setEnabled(true), isTrue);
    expect(authenticator.authCalls, 1);
    expect(controller.enabled, isTrue);
    expect(controller.locked, isFalse);
    expect(storage.values['gitsune.appLock.enabled'], 'true');
  });

  test('enabling on an unsupported device refuses without prompting', () async {
    authenticator.supported = false;
    expect(await controller.setEnabled(true), isFalse);
    expect(authenticator.authCalls, 0);
    expect(controller.enabled, isFalse);
    expect(storage.values, isEmpty);
  });

  test('enabling stays off when the confirmation check fails', () async {
    authenticator.result = BiometricResult.failure;
    expect(await controller.setEnabled(true), isFalse);
    expect(controller.enabled, isFalse);
    expect(storage.values, isEmpty);
  });

  test('an enable write failure leaves state unchanged and surfaces', () async {
    storage.writeError = StateError('keystore unavailable');

    await expectLater(controller.setEnabled(true), throwsStateError);

    expect(controller.loaded, isFalse);
    expect(controller.enabled, isFalse);
    expect(controller.locked, isFalse);
    expect(storage.values, isEmpty);
  });

  test('disabling persists and opens the gate without a check', () async {
    await controller.setEnabled(true);
    authenticator.authCalls = 0;
    expect(await controller.setEnabled(false), isTrue);
    expect(authenticator.authCalls, 0);
    expect(controller.enabled, isFalse);
    expect(storage.values['gitsune.appLock.enabled'], 'false');
  });

  test(
    'a disable write failure preserves enabled state and surfaces',
    () async {
      await controller.setEnabled(true);
      storage.writeError = StateError('keystore unavailable');

      await expectLater(controller.setEnabled(false), throwsStateError);

      expect(controller.enabled, isTrue);
      expect(controller.locked, isFalse);
      expect(storage.values['gitsune.appLock.enabled'], 'true');
    },
  );

  test('lock only arms while enabled', () async {
    controller.lock();
    expect(controller.locked, isFalse);

    await controller.setEnabled(true);
    controller.lock();
    expect(controller.locked, isTrue);
  });

  test('unlock opens on success and stays shut on failure', () async {
    await controller.setEnabled(true);
    controller.lock();

    authenticator.result = BiometricResult.failure;
    await controller.unlock();
    expect(controller.locked, isTrue);

    authenticator.result = BiometricResult.success;
    await controller.unlock();
    expect(controller.locked, isFalse);
  });

  test('unlock degrades open when the device cannot run any check', () async {
    await controller.setEnabled(true);
    controller.lock();

    authenticator.supported = false;
    authenticator.authCalls = 0;
    await controller.unlock();
    expect(controller.locked, isFalse);
    expect(authenticator.authCalls, 0);
  });

  test('unlock degrades open on an unavailable prompt result', () async {
    await controller.setEnabled(true);
    controller.lock();

    authenticator.result = BiometricResult.unavailable;
    await controller.unlock();
    expect(controller.locked, isFalse);
  });
}
