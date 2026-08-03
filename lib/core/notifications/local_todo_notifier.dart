import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/account_key.dart';
import 'todos_poller.dart';

/// The on-device [TodoNotifier]: local notifications via
/// `flutter_local_notifications`, per ADR 0002's no-server-relay baseline.
///
/// Tests exercise the poller against a recording [TodoNotifier] instead;
/// real delivery through this class is validated on-device.
class LocalTodoNotifier implements TodoNotifier {
  LocalTodoNotifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _androidChannel = AndroidNotificationDetails(
    'todos',
    'To-dos',
    channelDescription: 'New GitLab to-dos assigned to you',
  );

  /// Initializes the plugin and requests the Android 13+ runtime
  /// notification permission (iOS permissions are requested by
  /// [DarwinInitializationSettings] itself).
  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) {
    return _plugin.show(
      // Distinct per account and to-do so one account's notification never
      // replaces another's; stability across app restarts doesn't matter
      // because a to-do only ever counts as new once.
      id: Object.hash(account, todoId),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: _androidChannel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
