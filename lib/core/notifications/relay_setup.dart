import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import 'relay_webhook.dart';

/// One account's opt-in relay notification setup (E12.5, ADR 0002's iOS
/// opt-in layer): whether the user opted in, which relay service they chose,
/// and the details the wizard uses to test the relay and generate the
/// GitLab webhook configuration.
///
/// Default off. Enabling changes nothing about in-app delivery - the
/// baseline poller (E12.1) stays on either way, and relay notifications
/// flow from the user's GitLab instance directly to their relay service.
class RelaySetup {
  const RelaySetup({
    required this.enabled,
    required this.service,
    required this.ntfyServer,
    required this.ntfyTopic,
    required this.pushoverAppToken,
    required this.pushoverUserKey,
  });

  /// Disabled, prefilled with the public ntfy server so the common case
  /// only needs a topic name.
  static const defaults = RelaySetup(
    enabled: false,
    service: RelayService.ntfy,
    ntfyServer: 'https://ntfy.sh',
    ntfyTopic: '',
    pushoverAppToken: '',
    pushoverUserKey: '',
  );

  final bool enabled;
  final RelayService service;

  /// Raw wizard inputs, kept as entered so reopening the wizard restores
  /// the user's setup; `core/notifications/relay_webhook.dart` validates
  /// them into a [RelayTarget].
  final String ntfyServer;
  final String ntfyTopic;
  final String pushoverAppToken;
  final String pushoverUserKey;

  RelaySetup copyWith({
    bool? enabled,
    RelayService? service,
    String? ntfyServer,
    String? ntfyTopic,
    String? pushoverAppToken,
    String? pushoverUserKey,
  }) => RelaySetup(
    enabled: enabled ?? this.enabled,
    service: service ?? this.service,
    ntfyServer: ntfyServer ?? this.ntfyServer,
    ntfyTopic: ntfyTopic ?? this.ntfyTopic,
    pushoverAppToken: pushoverAppToken ?? this.pushoverAppToken,
    pushoverUserKey: pushoverUserKey ?? this.pushoverUserKey,
  );
}

/// Persists one account's [RelaySetup] in [AppDatabase.relaySetups]; an
/// account without a saved row gets [RelaySetup.defaults].
class RelaySetupStore {
  RelaySetupStore({required this.database, required this.account});

  final AppDatabase database;
  final AccountKey account;

  Future<RelaySetup> read() async {
    final row =
        await (database.select(database.relaySetups)..where(
              (t) =>
                  t.instanceHost.equals(account.instanceHost) &
                  t.accountId.equals(account.accountId),
            ))
            .getSingleOrNull();
    return row == null
        ? RelaySetup.defaults
        : RelaySetup(
            enabled: row.enabled,
            service:
                RelayService.values.asNameMap()[row.service] ??
                RelayService.ntfy,
            ntfyServer: row.ntfyServer,
            ntfyTopic: row.ntfyTopic,
            pushoverAppToken: row.pushoverAppToken,
            pushoverUserKey: row.pushoverUserKey,
          );
  }

  Future<void> save(RelaySetup setup) => database
      .into(database.relaySetups)
      .insertOnConflictUpdate(
        RelaySetupsCompanion.insert(
          instanceHost: account.instanceHost,
          accountId: account.accountId,
          enabled: setup.enabled,
          service: setup.service.name,
          ntfyServer: setup.ntfyServer,
          ntfyTopic: setup.ntfyTopic,
          pushoverAppToken: setup.pushoverAppToken,
          pushoverUserKey: setup.pushoverUserKey,
          updatedAt: DateTime.now(),
        ),
      );
}
