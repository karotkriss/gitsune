import 'package:gitsune/core/lock/app_lock.dart';

/// Scriptable [BiometricAuthenticator] so app-lock tests never need real
/// biometric hardware (the fixtures-first bar for E13.1).
class FakeBiometricAuthenticator implements BiometricAuthenticator {
  bool supported = true;
  BiometricResult result = BiometricResult.success;
  int authCalls = 0;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    authCalls++;
    return result;
  }
}
