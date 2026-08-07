import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/push_delivery.dart';
import 'package:gitsune/core/notifications/quiet_hours.dart';
import 'package:gitsune/core/notifications/relay_webhook.dart';
import 'package:gitsune/core/notifications/todos_poller.dart';

class RecordingNotifier implements TodoNotifier {
  final shown = <Map<String, Object?>>[];

  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) async {
    shown.add({'todoId': todoId, 'title': title, 'body': body});
  }
}

/// A test double for the UnifiedPush plugin seam: records register/unregister
/// calls and lets the test drive the plugin's callbacks.
class FakeAndroidPushGateway implements AndroidPushGateway {
  void Function(Uri endpoint, String instance)? onEndpoint;
  Future<void> Function(String body, String instance)? onMessage;
  void Function(String instance)? onUnregistered;

  final registered = <String>[];
  final unregistered = <String>[];

  @override
  void bind({
    required void Function(Uri endpoint, String instance) onEndpoint,
    required Future<void> Function(String body, String instance) onMessage,
    required void Function(String instance) onUnregistered,
  }) {
    this.onEndpoint = onEndpoint;
    this.onMessage = onMessage;
    this.onUnregistered = onUnregistered;
  }

  @override
  Future<void> register(String instance) async => registered.add(instance);

  @override
  Future<void> unregister(String instance) async => unregistered.add(instance);
}

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );
  final endpoint = Uri.parse('https://ntfy.sh/upAbC123');

  RelayWebhookConfig buildNtfyWebhookConfig(Uri endpoint) =>
      buildRelayWebhookConfig(UnifiedPushTarget(endpoint: endpoint));

  group('buildRelayWebhookConfig(UnifiedPushTarget)', () {
    test('generates the exact GitLab webhook configuration', () {
      final config = buildNtfyWebhookConfig(endpoint);
      expect(config.url, endpoint);
      expect(config.headers, {'Content-Type': 'application/json'});
      expect(
        config.payloadTemplate,
        '{"title":"{{object_attributes.title}}",'
        '"body":"{{object_kind}} · {{project.path_with_namespace}}",'
        '"url":"{{object_attributes.url}}"}',
      );
      expect(config.triggerEvents, [
        'Issues events',
        'Merge request events',
        'Comments',
      ]);
    });

    test('is deterministic for a given endpoint', () {
      final a = buildNtfyWebhookConfig(endpoint);
      final b = buildNtfyWebhookConfig(endpoint);
      expect(a.url, b.url);
      expect(a.headers, b.headers);
      expect(a.payloadTemplate, b.payloadTemplate);
      expect(a.triggerEvents, b.triggerEvents);
    });

    test('carries the endpoint through as the POST target', () {
      final other = Uri.parse('https://push.example.org/topic/xyz');
      expect(buildNtfyWebhookConfig(other).url, other);
    });
  });

  group('PushDeliveryMessage.parse', () {
    test('parses the JSON the generated template produces', () {
      // The body GitLab renders from the template and ntfy forwards verbatim.
      final message = PushDeliveryMessage.parse(
        '{"title":"Fix login","body":"issue · group/app",'
        '"url":"https://gitlab.example.com/group/app/-/issues/7"}',
      );
      expect(message, isNotNull);
      expect(message!.title, 'Fix login');
      expect(message.body, 'issue · group/app');
      expect(message.url, 'https://gitlab.example.com/group/app/-/issues/7');
    });

    test('defaults missing optional fields to empty strings', () {
      final message = PushDeliveryMessage.parse('{"title":"Only a title"}');
      expect(message!.body, '');
      expect(message.url, '');
    });

    test('returns null for a missing title, non-object, or malformed JSON', () {
      expect(PushDeliveryMessage.parse('{"body":"no title"}'), isNull);
      expect(PushDeliveryMessage.parse('["not","an","object"]'), isNull);
      expect(PushDeliveryMessage.parse('not json at all'), isNull);
    });
  });

  group('PushDeliveryStore', () {
    late AppDatabase db;
    late PushDeliveryStore store;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      store = PushDeliveryStore(database: db, account: account);
    });

    tearDown(() => db.close());

    test('reads disabled with no endpoint when nothing is saved', () async {
      final settings = await store.read();
      expect(settings.enabled, isFalse);
      expect(settings.endpoint, isNull);
    });

    test('round-trips enabled state and endpoint', () async {
      await store.save(PushDeliverySettings(enabled: true, endpoint: endpoint));
      final settings = await store.read();
      expect(settings.enabled, isTrue);
      expect(settings.endpoint, endpoint);
    });

    test('is scoped per account', () async {
      await store.save(PushDeliverySettings(enabled: true, endpoint: endpoint));
      final other = PushDeliveryStore(
        database: db,
        account: const AccountKey(
          instanceHost: 'gitlab.example.com',
          accountId: 'bob',
        ),
      );
      final settings = await other.read();
      expect(settings.enabled, isFalse);
      expect(settings.endpoint, isNull);
    });
  });

  group('PushDeliveryController', () {
    late AppDatabase db;
    late PushDeliveryStore store;
    late FakeAndroidPushGateway gateway;
    late RecordingNotifier notifier;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      store = PushDeliveryStore(database: db, account: account);
      gateway = FakeAndroidPushGateway();
      notifier = RecordingNotifier();
    });

    tearDown(() => db.close());

    PushDeliveryController controllerWith(TodoNotifier n) =>
        PushDeliveryController(
          store: store,
          gateway: gateway,
          notifier: n,
          account: account,
        );

    test('defaults to off; the baseline poller stays the default', () async {
      final controller = controllerWith(notifier);
      await controller.load();
      expect(controller.enabled, isFalse);
      expect(gateway.registered, isEmpty);
      expect(controller.webhookConfig, isNull);
    });

    test('opting in registers and persists; opting out unregisters', () async {
      final controller = controllerWith(notifier);
      await controller.load();

      await controller.setEnabled(true);
      expect(controller.enabled, isTrue);
      expect(gateway.registered, [account.toString()]);
      expect((await store.read()).enabled, isTrue);

      await controller.setEnabled(false);
      expect(controller.enabled, isFalse);
      expect(gateway.unregistered, [account.toString()]);
      expect((await store.read()).enabled, isFalse);
      expect(controller.webhookConfig, isNull);
    });

    test('a delivered endpoint yields the webhook config to show', () async {
      final controller = controllerWith(notifier);
      await controller.load();
      await controller.setEnabled(true);

      gateway.onEndpoint!(endpoint, account.toString());
      expect(controller.endpoint, endpoint);
      final expected = buildNtfyWebhookConfig(endpoint);
      expect(controller.webhookConfig?.url, expected.url);
      expect(controller.webhookConfig?.headers, expected.headers);
      expect(
        controller.webhookConfig?.payloadTemplate,
        expected.payloadTemplate,
      );
      expect(controller.webhookConfig?.triggerEvents, expected.triggerEvents);
      expect((await store.read()).endpoint, endpoint);
    });

    test('a forwarded message surfaces through the notifier', () async {
      final controller = controllerWith(notifier);
      await controller.load();
      await controller.setEnabled(true);

      await gateway.onMessage!(
        '{"title":"Review requested","body":"merge_request · group/app",'
        '"url":"https://gitlab.example.com/group/app/-/merge_requests/3"}',
        account.toString(),
      );
      expect(notifier.shown, hasLength(1));
      expect(notifier.shown.single['title'], 'Review requested');
      expect(notifier.shown.single['body'], 'merge_request · group/app');
    });

    test(
      'ignores messages for another account (no cross-account leak)',
      () async {
        final controller = controllerWith(notifier);
        await controller.load();
        await controller.setEnabled(true);

        await gateway.onMessage!(
          '{"title":"Someone else\'s to-do"}',
          const AccountKey(
            instanceHost: 'gitlab.example.com',
            accountId: 'bob',
          ).toString(),
        );
        expect(notifier.shown, isEmpty);
      },
    );

    test('drops a malformed forward rather than surfacing a blank', () async {
      final controller = controllerWith(notifier);
      await controller.load();
      await controller.setEnabled(true);

      await gateway.onMessage!('not json', account.toString());
      expect(notifier.shown, isEmpty);
    });

    test('quiet hours suppresses this path too', () async {
      final quietStore = QuietHoursStore(database: db, account: account);
      await quietStore.save(
        const QuietHours(
          enabled: true,
          startMinutes: 22 * 60,
          endMinutes: 7 * 60,
        ),
      );
      final quiet = QuietHoursTodoNotifier(
        inner: notifier,
        store: quietStore,
        now: () => DateTime(2026, 8, 7, 23),
      );
      final controller = controllerWith(quiet);
      await controller.load();
      await controller.setEnabled(true);

      await gateway.onMessage!(
        '{"title":"Late night to-do"}',
        account.toString(),
      );
      expect(notifier.shown, isEmpty, reason: '23:00 is inside 22:00-07:00');
    });

    test('load restores an opted-in account and re-registers', () async {
      await store.save(PushDeliverySettings(enabled: true, endpoint: endpoint));
      final controller = controllerWith(notifier);
      await controller.load();
      expect(controller.enabled, isTrue);
      expect(controller.endpoint, endpoint);
      expect(controller.webhookConfig, isNotNull);
      expect(gateway.registered, [account.toString()]);
    });
  });
}
