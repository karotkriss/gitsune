import 'dart:convert';

import 'package:unifiedpush/unifiedpush.dart';

import 'push_delivery.dart';

/// The on-device [AndroidPushGateway]: UnifiedPush via the `unifiedpush`
/// plugin (ADR 0002, layer 3). The user installs a distributor (ntfy) that
/// issues an endpoint; a GitLab webhook the user configures posts events to
/// it and the distributor forwards them here. Gitsune runs no server.
///
/// This is the OS adapter, kept thin and behind [AndroidPushGateway] so the
/// controller and its tests never touch the plugin; real forwarding is
/// validated on-device, like `LocalTodoNotifier`.
class UnifiedPushGateway implements AndroidPushGateway {
  @override
  void bind({
    required void Function(Uri endpoint, String instance) onEndpoint,
    required Future<void> Function(String body, String instance) onMessage,
    required void Function(String instance) onUnregistered,
  }) {
    UnifiedPush.initialize(
      onNewEndpoint: (endpoint, instance) =>
          onEndpoint(Uri.parse(endpoint.url), instance),
      onMessage: (message, instance) =>
          onMessage(utf8.decode(message.content), instance),
      onUnregistered: onUnregistered,
    );
  }

  @override
  Future<void> register(String instance) async {
    // Pick the installed distributor (ntfy); registration only yields an
    // endpoint once one is available. With none installed this is a no-op and
    // the settings screen tells the user to install one.
    if (await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
      await UnifiedPush.register(instance: instance);
    }
  }

  @override
  Future<void> unregister(String instance) => UnifiedPush.unregister(instance);
}
