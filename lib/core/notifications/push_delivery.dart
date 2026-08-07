import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import 'todos_poller.dart';

/// The E12.4 Android opt-in delivery layer (ADR 0002, layer 3): UnifiedPush
/// fed by the user's own webhook-to-ntfy bridge. Gitsune operates no server
/// here. A project or group owner adds a GitLab webhook - whose exact
/// configuration Gitsune generates - pointing at the ntfy UnifiedPush
/// endpoint this device registered; ntfy forwards each event to Gitsune,
/// which surfaces it as a local notification. This is opt-in and off by
/// default; the [TodosPoller] baseline stays the default path.
///
/// This file is the Flutter-free (foundation-only) core: the webhook-config
/// generator, the delivered-message parser, the persistence store, the
/// gateway seam, and the controller. The concrete UnifiedPush plugin adapter
/// is `UnifiedPushGateway` in `unified_push_gateway.dart`, kept separate so
/// this core stays plainly unit-testable and the OS plumbing is validated
/// on-device.

/// The GitLab webhook configuration a user pastes into their own project or
/// group webhook so GitLab posts each selected event to their ntfy
/// UnifiedPush endpoint, which forwards it to Gitsune.
///
/// GitLab supports a custom webhook payload template and custom headers, so
/// the [payloadTemplate] renders GitLab's event fields straight into the
/// compact JSON [PushDeliveryMessage.parse] reads on receipt, with no
/// translation server in between.
@immutable
class NtfyWebhookConfig {
  const NtfyWebhookConfig({
    required this.url,
    required this.headers,
    required this.payloadTemplate,
    required this.triggerEvents,
  });

  /// Where GitLab POSTs: the UnifiedPush endpoint the ntfy distributor issued
  /// for this device.
  final Uri url;

  /// Custom headers to set on the GitLab webhook.
  final Map<String, String> headers;

  /// The GitLab custom webhook payload template ({{...}} fields), rendered by
  /// GitLab into the JSON [PushDeliveryMessage.parse] expects.
  final String payloadTemplate;

  /// The webhook trigger checkboxes to enable, as their GitLab UI labels.
  /// These cover the events that create to-dos (assignment, mention, review
  /// request) without broadcasting every project event.
  final List<String> triggerEvents;

  @override
  bool operator ==(Object other) =>
      other is NtfyWebhookConfig &&
      other.url == url &&
      mapEquals(other.headers, headers) &&
      other.payloadTemplate == payloadTemplate &&
      listEquals(other.triggerEvents, triggerEvents);

  @override
  int get hashCode => Object.hash(
    url,
    Object.hashAllUnordered(
      headers.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    payloadTemplate,
    Object.hashAll(triggerEvents),
  );
}

/// Builds the exact [NtfyWebhookConfig] for [endpoint] (the UnifiedPush
/// endpoint the ntfy distributor issued). Deterministic so its output can be
/// asserted against fixtures.
NtfyWebhookConfig buildNtfyWebhookConfig(Uri endpoint) => NtfyWebhookConfig(
  url: endpoint,
  headers: const {'Content-Type': 'application/json'},
  payloadTemplate:
      '{"title":"{{object_attributes.title}}",'
      '"body":"{{object_kind}} · {{project.path_with_namespace}}",'
      '"url":"{{object_attributes.url}}"}',
  triggerEvents: const ['Issues events', 'Merge request events', 'Comments'],
);

/// One event forwarded from ntfy to this device: the compact JSON produced by
/// the generated webhook template, parsed into the fields a notification
/// needs.
@immutable
class PushDeliveryMessage {
  const PushDeliveryMessage({
    required this.title,
    required this.body,
    required this.url,
  });

  final String title;
  final String body;

  /// The web URL of the underlying item, for deep-linking.
  final String url;

  /// Parses [rawBody] as the JSON the generated webhook template produces.
  /// Returns null for anything that is not the expected shape (a `title`
  /// string is the one required field), so a malformed forward is dropped
  /// rather than surfaced as a blank notification.
  static PushDeliveryMessage? parse(String rawBody) {
    final Object? decoded;
    try {
      decoded = jsonDecode(rawBody);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final title = decoded['title'];
    if (title is! String) return null;
    final body = decoded['body'];
    final url = decoded['url'];
    return PushDeliveryMessage(
      title: title,
      body: body is String ? body : '',
      url: url is String ? url : '',
    );
  }
}

/// One account's opt-in push-delivery setting: whether the UnifiedPush path
/// is [enabled] and the [endpoint] the distributor last issued (null until a
/// distributor registers one).
@immutable
class PushDeliverySettings {
  const PushDeliverySettings({required this.enabled, this.endpoint});

  static const disabled = PushDeliverySettings(enabled: false);

  final bool enabled;
  final Uri? endpoint;
}

/// Persists one account's [PushDeliverySettings] in
/// [AppDatabase.pushNotificationSettings]; an account without a saved row is
/// [PushDeliverySettings.disabled].
class PushDeliveryStore {
  PushDeliveryStore({required this.database, required this.account});

  final AppDatabase database;
  final AccountKey account;

  Future<PushDeliverySettings> read() async {
    final row =
        await (database.select(database.pushNotificationSettings)..where(
              (t) =>
                  t.instanceHost.equals(account.instanceHost) &
                  t.accountId.equals(account.accountId),
            ))
            .getSingleOrNull();
    if (row == null) return PushDeliverySettings.disabled;
    return PushDeliverySettings(
      enabled: row.enabled,
      endpoint: row.endpoint == null ? null : Uri.parse(row.endpoint!),
    );
  }

  Future<void> save(PushDeliverySettings settings) => database
      .into(database.pushNotificationSettings)
      .insertOnConflictUpdate(
        PushNotificationSettingsCompanion.insert(
          instanceHost: account.instanceHost,
          accountId: account.accountId,
          enabled: settings.enabled,
          endpoint: Value(settings.endpoint?.toString()),
          updatedAt: DateTime.now(),
        ),
      );
}

/// The service seam that owns the UnifiedPush registration and the incoming
/// message stream, so the controller (and its tests) never depend on the
/// plugin. Each account registers under its own [instance] string, so the
/// distributor issues a distinct endpoint per account and the callbacks carry
/// the [instance] to attribute a message back to its account. The on-device
/// implementation is `UnifiedPushGateway` in `unified_push_gateway.dart`.
abstract class AndroidPushGateway {
  /// Wires the callbacks the plugin fans out to. Called once before any
  /// [register]. [onEndpoint] fires when the distributor issues (or renews) an
  /// endpoint; [onMessage] carries a forwarded event's raw JSON body;
  /// [onUnregistered] fires when the distributor drops the registration.
  void bind({
    required void Function(Uri endpoint, String instance) onEndpoint,
    required Future<void> Function(String body, String instance) onMessage,
    required void Function(String instance) onUnregistered,
  });

  Future<void> register(String instance);
  Future<void> unregister(String instance);
}

/// Orchestrates one account's opt-in UnifiedPush delivery: persists the
/// toggle and endpoint through [store], registers/unregisters through
/// [gateway], and surfaces each forwarded event through [notifier].
///
/// [notifier] is the quiet-hours-wrapped notifier from the composition root
/// (`QuietHoursTodoNotifier`), so the E12.2 window suppresses this path too
/// without any extra logic here. Messages for a foreign [instance] are
/// ignored, so one account never surfaces another's notifications.
class PushDeliveryController extends ChangeNotifier {
  PushDeliveryController({
    required this.store,
    required this.gateway,
    required this.notifier,
    required this.account,
  });

  final PushDeliveryStore store;
  final AndroidPushGateway gateway;
  final TodoNotifier notifier;
  final AccountKey account;

  String get _instance => account.toString();

  bool _enabled = false;
  bool get enabled => _enabled;

  Uri? _endpoint;

  /// The endpoint the distributor last issued for this account, if any.
  Uri? get endpoint => _endpoint;

  /// The webhook configuration to show the user, once an endpoint exists.
  NtfyWebhookConfig? get webhookConfig =>
      _endpoint == null ? null : buildNtfyWebhookConfig(_endpoint!);

  /// Loads the persisted setting and, if enabled, binds the gateway and
  /// (re)registers so a fresh endpoint arrives. Call once at startup.
  Future<void> load() async {
    gateway.bind(
      onEndpoint: _handleEndpoint,
      onMessage: _handleMessage,
      onUnregistered: _handleUnregistered,
    );
    final settings = await store.read();
    _enabled = settings.enabled;
    _endpoint = settings.endpoint;
    notifyListeners();
    if (_enabled) await gateway.register(_instance);
  }

  /// Turns the opt-in path on or off: persists the choice and registers or
  /// unregisters with the distributor.
  Future<void> setEnabled(bool value) async {
    if (value == _enabled) return;
    _enabled = value;
    if (!value) _endpoint = null;
    notifyListeners();
    await store.save(
      PushDeliverySettings(enabled: value, endpoint: value ? _endpoint : null),
    );
    if (value) {
      await gateway.register(_instance);
    } else {
      await gateway.unregister(_instance);
    }
  }

  void _handleEndpoint(Uri endpoint, String instance) {
    if (instance != _instance || !_enabled) return;
    _endpoint = endpoint;
    notifyListeners();
    unawaited(
      store.save(PushDeliverySettings(enabled: true, endpoint: endpoint)),
    );
  }

  Future<void> _handleMessage(String body, String instance) async {
    // Attribution guard: only surface events for this account's endpoint, so
    // a second account's forwarded events never leak into this one.
    if (instance != _instance || !_enabled) return;
    final message = PushDeliveryMessage.parse(body);
    if (message == null) return;
    await notifier.showNewTodo(
      account: account,
      // The notifier keys its OS notification id off this; a message has no
      // to-do id, so derive a stable one from the item's URL (falling back to
      // the title) - re-delivery of the same item then updates in place.
      todoId: (message.url.isNotEmpty ? message.url : message.title).hashCode,
      title: message.title,
      body: message.body,
    );
  }

  void _handleUnregistered(String instance) {
    if (instance != _instance) return;
    _endpoint = null;
    notifyListeners();
    unawaited(store.save(PushDeliverySettings(enabled: _enabled)));
  }
}
