import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/push_delivery.dart';
import 'package:gitsune/core/notifications/todos_poller.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/settings/push_delivery_screen.dart';

class _FakeGateway implements AndroidPushGateway {
  void Function(Uri endpoint, String instance)? onEndpoint;
  final registered = <String>[];
  final unregistered = <String>[];

  @override
  void bind({
    required void Function(Uri endpoint, String instance) onEndpoint,
    required Future<void> Function(String body, String instance) onMessage,
    required void Function(String instance) onUnregistered,
  }) {
    this.onEndpoint = onEndpoint;
  }

  @override
  Future<void> register(String instance) async => registered.add(instance);

  @override
  Future<void> unregister(String instance) async => unregistered.add(instance);
}

class _SilentNotifier implements TodoNotifier {
  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) async {}
}

void main() {
  const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
  final endpoint = Uri.parse('https://ntfy.sh/upAbC123');

  late AppDatabase database;
  late _FakeGateway gateway;
  late PushDeliveryController controller;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    gateway = _FakeGateway();
    controller = PushDeliveryController(
      store: PushDeliveryStore(database: database, account: account),
      gateway: gateway,
      notifier: _SilentNotifier(),
      account: account,
    );
  });

  tearDown(() => database.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PushDeliveryScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('defaults off and enabling registers and prompts setup', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.enabled, isTrue);
    expect(gateway.registered, [account.toString()]);
    expect(find.textContaining('Waiting for an endpoint'), findsOneWidget);
  });

  testWidgets('shows the generated webhook config once an endpoint arrives', (
    tester,
  ) async {
    await controller.setEnabled(true);
    await pumpScreen(tester);
    gateway.onEndpoint!(endpoint, account.toString());
    await tester.pumpAndSettle();

    expect(find.text(endpoint.toString()), findsOneWidget);
    expect(find.textContaining('{{object_attributes.title}}'), findsOneWidget);
    expect(find.textContaining('Issues events'), findsOneWidget);
  });

  testWidgets('copying the URL writes it to the clipboard', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await controller.setEnabled(true);
    await pumpScreen(tester);
    gateway.onEndpoint!(endpoint, account.toString());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Copy URL'));
    await tester.pumpAndSettle();

    expect(copied, contains(endpoint.toString()));
  });
}
