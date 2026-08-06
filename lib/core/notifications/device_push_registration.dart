import 'package:dio/dio.dart';

/// Compile-time gate for [registerDevice] (ADR 0002, layer 5). Off by
/// default: GitLab's device push-subscription registry is itself still
/// behind GitLab's own feature flags, and even once generally available,
/// adoption for a self-hosted instance depends on an unresolved
/// APNs credential-sharing arrangement between this project and cooperating
/// instance administrators. See docs/research/notification-analysis.md.
/// Flip only once both gates clear.
const nativePushRegistrationEnabled = false;

/// Request shape for GitLab's device push-subscription registry
/// (`POST /api/v4/user/push_subscriptions`), not yet generally available.
class DevicePushSubscription {
  const DevicePushSubscription({
    required this.deviceToken,
    required this.platform,
  });

  /// The APNs device token for this install. GitLab's registry is
  /// Apple-push-only as of this research; there is nothing for Android yet.
  final String deviceToken;

  /// The push platform, e.g. `"apns"`.
  final String platform;

  Map<String, dynamic> toJson() => {
    'device_token': deviceToken,
    'platform': platform,
  };
}

/// Registers this device with GitLab's native push-subscription registry.
///
/// This seam exists so Gitsune can evaluate GitLab's native push capability
/// without architectural rework if it becomes available; it is not wired
/// into any composition root. Throws [StateError] unless [enabled], which
/// defaults to [nativePushRegistrationEnabled], so the deferral holds even
/// if a future call site forgets to check the flag itself. Tests pass
/// `enabled: true` directly to exercise the request shape without flipping
/// the production default.
Future<void> registerDevice(
  Dio client,
  DevicePushSubscription subscription, {
  bool enabled = nativePushRegistrationEnabled,
}) async {
  if (!enabled) {
    throw StateError(
      'Native push registration is deferred; see ADR 0002 layer 5.',
    );
  }
  await client.post<void>(
    '/user/push_subscriptions',
    data: subscription.toJson(),
  );
}
