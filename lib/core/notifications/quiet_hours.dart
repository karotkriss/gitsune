import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import 'todos_poller.dart';

/// One account's scheduled quiet-hours window (E12.2, ADR 0002's delivery
/// layer): while [enabled] and the local time is inside the window, new-to-do
/// notifications are suppressed.
class QuietHours {
  const QuietHours({
    required this.enabled,
    required this.startMinutes,
    required this.endMinutes,
  });

  /// Disabled, prefilled with the conventional 22:00-07:00 night window so
  /// enabling the switch is useful without further setup.
  static const defaults = QuietHours(
    enabled: false,
    startMinutes: 22 * 60,
    endMinutes: 7 * 60,
  );

  final bool enabled;

  /// Window bounds in minutes since local midnight. [startMinutes] is
  /// inclusive and [endMinutes] exclusive; a start later than the end wraps
  /// past midnight (22:00-07:00 covers 22:00 tonight to 06:59 tomorrow), and
  /// equal bounds are an empty window.
  final int startMinutes;
  final int endMinutes;

  /// Whether notifications are suppressed at [now] (interpreted in the
  /// device's local time, matching how a person states a quiet window).
  bool isQuietAt(DateTime now) {
    if (!enabled) return false;
    final minutes = now.hour * 60 + now.minute;
    return startMinutes <= endMinutes
        ? minutes >= startMinutes && minutes < endMinutes
        : minutes >= startMinutes || minutes < endMinutes;
  }

  QuietHours copyWith({bool? enabled, int? startMinutes, int? endMinutes}) =>
      QuietHours(
        enabled: enabled ?? this.enabled,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
      );
}

/// Persists one account's [QuietHours] in [AppDatabase.quietHoursSettings];
/// an account without a saved row gets [QuietHours.defaults].
class QuietHoursStore {
  QuietHoursStore({required this.database, required this.account});

  final AppDatabase database;
  final AccountKey account;

  Future<QuietHours> read() async {
    final row =
        await (database.select(database.quietHoursSettings)..where(
              (t) =>
                  t.instanceHost.equals(account.instanceHost) &
                  t.accountId.equals(account.accountId),
            ))
            .getSingleOrNull();
    return row == null
        ? QuietHours.defaults
        : QuietHours(
            enabled: row.enabled,
            startMinutes: row.startMinutes,
            endMinutes: row.endMinutes,
          );
  }

  Future<void> save(QuietHours settings) => database
      .into(database.quietHoursSettings)
      .insertOnConflictUpdate(
        QuietHoursSettingsCompanion.insert(
          instanceHost: account.instanceHost,
          accountId: account.accountId,
          enabled: settings.enabled,
          startMinutes: settings.startMinutes,
          endMinutes: settings.endMinutes,
          updatedAt: DateTime.now(),
        ),
      );
}

/// A [TodoNotifier] decorator that drops notifications while quiet hours are
/// active and delegates untouched otherwise. Wrap the real notifier with this
/// so polling keeps running (the Todos screen stays current) and only the
/// surfacing is suppressed; a suppressed to-do is dropped rather than
/// deferred because it stays visible in the To-Dos tab.
class QuietHoursTodoNotifier implements TodoNotifier {
  QuietHoursTodoNotifier({
    required this.inner,
    required this.store,
    this.now = DateTime.now,
  });

  final TodoNotifier inner;
  final QuietHoursStore store;

  /// Injectable clock so tests pin the current time.
  final DateTime Function() now;

  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) async {
    // Read at surfacing time, not construction time, so a settings change
    // applies to the very next notification.
    if ((await store.read()).isQuietAt(now())) return;
    return inner.showNewTodo(
      account: account,
      todoId: todoId,
      title: title,
      body: body,
    );
  }
}
