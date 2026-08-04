import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Outcome of one biometric or device-credential check.
enum BiometricResult {
  /// The user passed the check.
  success,

  /// The user failed or dismissed the check; the lock stays shut and the
  /// lock screen offers a retry.
  failure,

  /// This device cannot run any check (no hardware, nothing enrolled, no
  /// device credential); the lock opens rather than stranding the user.
  unavailable,
}

/// Platform seam for the E13.1 biometric app lock: the shell talks to this
/// interface so tests drive the lock with a fake instead of real hardware.
abstract interface class BiometricAuthenticator {
  /// Whether the device can check biometrics or fall back to a device
  /// credential (pin, pattern, passcode).
  Future<bool> isDeviceSupported();

  /// Shows the platform authentication prompt.
  Future<BiometricResult> authenticate({required String reason});
}

/// [BiometricAuthenticator] backed by the local_auth plugin, with
/// device-credential fallback left on (never `biometricOnly`) per the E13.1
/// degradation contract.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    try {
      final passed = await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
      return passed ? BiometricResult.success : BiometricResult.failure;
    } on LocalAuthException catch (error) {
      // Only capability gaps degrade open; a cancel or transient error stays
      // locked so dismissing the prompt is never a bypass.
      const unavailableCodes = {
        LocalAuthExceptionCode.noBiometricHardware,
        LocalAuthExceptionCode.noBiometricsEnrolled,
        LocalAuthExceptionCode.noCredentialsSet,
      };
      return unavailableCodes.contains(error.code)
          ? BiometricResult.unavailable
          : BiometricResult.failure;
    }
  }
}

/// Owns the app-lock state: the persisted settings toggle and whether the UI
/// is currently gated. `AppLockGate` listens and covers the app while
/// [locked] holds; the Profile settings tile flips [setEnabled].
class AppLockController extends ChangeNotifier {
  AppLockController({
    required this._authenticator,
    this._storage = const FlutterSecureStorage(),
  });

  static const _enabledKey = 'gitsune.appLock.enabled';

  final BiometricAuthenticator _authenticator;
  final FlutterSecureStorage _storage;

  bool _enabled = false;
  bool _locked = false;
  bool _unlocking = false;

  /// Whether the lock is switched on in settings.
  bool get enabled => _enabled;

  /// Whether the UI is gated right now.
  bool get locked => _locked;

  /// Loads the persisted toggle; when enabled the app starts locked (the
  /// cold-launch gate). An unreadable flag means disabled: a corrupt store
  /// must never hard-lock the user out.
  Future<void> load() async {
    var enabled = false;
    try {
      enabled = await _storage.read(key: _enabledKey) == 'true';
    } catch (_) {}
    _enabled = enabled;
    _locked = enabled;
    notifyListeners();
  }

  /// Flips the setting. Enabling requires passing the check once first, so
  /// the lock cannot be armed by someone who could not open it and an
  /// unsupported device reports the gap instead of arming a dead lock.
  /// Returns false, leaving the lock off, when that proof fails.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      if (!await _authenticator.isDeviceSupported()) return false;
      final result = await _authenticator.authenticate(
        reason: 'Verify unlocking works before turning on the app lock',
      );
      if (result != BiometricResult.success) return false;
    }
    _enabled = value;
    _locked = false;
    try {
      await _storage.write(key: _enabledKey, value: '$value');
    } catch (_) {}
    notifyListeners();
    return true;
  }

  /// Re-arms the gate; called when the app leaves the foreground.
  void lock() {
    if (!_enabled || _locked) return;
    _locked = true;
    notifyListeners();
  }

  /// Runs the platform check and opens the gate on success. An unsupported
  /// device or an unavailable result opens it too (the degradation path); a
  /// failed or dismissed check stays locked so the lock screen can retry.
  Future<void> unlock() async {
    if (!_locked || _unlocking) return;
    _unlocking = true;
    try {
      if (await _authenticator.isDeviceSupported()) {
        final result = await _authenticator.authenticate(
          reason: 'Unlock Gitsune',
        );
        if (result == BiometricResult.failure) return;
      }
      _locked = false;
      notifyListeners();
    } finally {
      _unlocking = false;
    }
  }
}
