import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/push_delivery.dart';
import 'package:gitsune/core/notifications/todos_poller.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/settings/push_delivery_screen.dart';

class _NoopGateway implements AndroidPushGateway {
  @override
  void bind({
    required void Function(Uri endpoint, String instance) onEndpoint,
    required Future<void> Function(String body, String instance) onMessage,
    required void Function(String instance) onUnregistered,
  }) {}

  @override
  Future<void> register(String instance) async {}

  @override
  Future<void> unregister(String instance) async {}
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

  testWidgets('Android push screen matches the golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = PushDeliveryStore(database: database, account: account);
    await store.save(
      PushDeliverySettings(
        enabled: true,
        endpoint: Uri.parse('https://ntfy.sh/upAbC123'),
      ),
    );
    final controller = PushDeliveryController(
      store: store,
      gateway: _NoopGateway(),
      notifier: _SilentNotifier(),
      account: account,
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PushDeliveryScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PushDeliveryScreen),
      matchesGoldenFile('goldens/push_delivery_screen.png'),
    );
  });
}
