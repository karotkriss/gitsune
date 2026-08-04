import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/quiet_hours.dart';
import 'package:gitsune/core/notifications/todos_poller.dart';

class RecordingNotifier implements TodoNotifier {
  final shown = <int>[];

  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) async {
    shown.add(todoId);
  }
}

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

  DateTime at(int hour, [int minute = 0]) => DateTime(2026, 8, 4, hour, minute);

  group('QuietHours.isQuietAt', () {
    const sameDay = QuietHours(
      enabled: true,
      startMinutes: 9 * 60,
      endMinutes: 17 * 60,
    );
    const overnight = QuietHours(
      enabled: true,
      startMinutes: 22 * 60,
      endMinutes: 7 * 60,
    );

    test('same-day window: inside, outside, and boundaries', () {
      expect(sameDay.isQuietAt(at(12)), isTrue);
      expect(sameDay.isQuietAt(at(8, 59)), isFalse);
      expect(sameDay.isQuietAt(at(9)), isTrue, reason: 'start is inclusive');
      expect(sameDay.isQuietAt(at(17)), isFalse, reason: 'end is exclusive');
      expect(sameDay.isQuietAt(at(21)), isFalse);
    });

    test('overnight window wraps past midnight', () {
      expect(overnight.isQuietAt(at(23)), isTrue);
      expect(overnight.isQuietAt(at(0)), isTrue);
      expect(overnight.isQuietAt(at(3)), isTrue);
      expect(overnight.isQuietAt(at(12)), isFalse);
      expect(overnight.isQuietAt(at(22)), isTrue, reason: 'start inclusive');
      expect(overnight.isQuietAt(at(7)), isFalse, reason: 'end is exclusive');
      expect(overnight.isQuietAt(at(6, 59)), isTrue);
      expect(overnight.isQuietAt(at(21, 59)), isFalse);
    });

    test('disabled window never suppresses', () {
      const disabled = QuietHours(
        enabled: false,
        startMinutes: 0,
        endMinutes: 24 * 60,
      );
      expect(disabled.isQuietAt(at(12)), isFalse);
    });

    test('equal bounds are an empty window', () {
      const empty = QuietHours(
        enabled: true,
        startMinutes: 10 * 60,
        endMinutes: 10 * 60,
      );
      expect(empty.isQuietAt(at(10)), isFalse);
      expect(empty.isQuietAt(at(22)), isFalse);
    });
  });

  group('QuietHoursStore', () {
    late AppDatabase db;
    late QuietHoursStore store;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      store = QuietHoursStore(database: db, account: account);
    });

    tearDown(() => db.close());

    test('reads defaults when nothing is saved', () async {
      final settings = await store.read();
      expect(settings.enabled, isFalse);
      expect(settings.startMinutes, 22 * 60);
      expect(settings.endMinutes, 7 * 60);
    });

    test('round-trips a saved window and updates in place', () async {
      await store.save(
        const QuietHours(
          enabled: true,
          startMinutes: 21 * 60,
          endMinutes: 8 * 60 + 30,
        ),
      );
      var settings = await store.read();
      expect(settings.enabled, isTrue);
      expect(settings.startMinutes, 21 * 60);
      expect(settings.endMinutes, 8 * 60 + 30);

      await store.save(settings.copyWith(enabled: false));
      settings = await store.read();
      expect(settings.enabled, isFalse);
      expect(settings.startMinutes, 21 * 60);
    });

    test('is scoped per account', () async {
      await store.save(
        const QuietHours(enabled: true, startMinutes: 0, endMinutes: 1440),
      );
      final other = QuietHoursStore(
        database: db,
        account: const AccountKey(
          instanceHost: 'gitlab.example.com',
          accountId: 'bob',
        ),
      );
      expect((await other.read()).enabled, isFalse);
    });
  });

  group('QuietHoursTodoNotifier', () {
    late AppDatabase db;
    late QuietHoursStore store;
    late RecordingNotifier inner;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      store = QuietHoursStore(database: db, account: account);
      inner = RecordingNotifier();
    });

    tearDown(() => db.close());

    QuietHoursTodoNotifier notifierAt(DateTime now) =>
        QuietHoursTodoNotifier(inner: inner, store: store, now: () => now);

    Future<void> show(QuietHoursTodoNotifier notifier, int todoId) =>
        notifier.showNewTodo(
          account: account,
          todoId: todoId,
          title: 'title',
          body: 'body',
        );

    test('suppresses inside the window and surfaces outside it', () async {
      await store.save(
        const QuietHours(
          enabled: true,
          startMinutes: 22 * 60,
          endMinutes: 7 * 60,
        ),
      );

      await show(notifierAt(at(23)), 1);
      expect(inner.shown, isEmpty, reason: '23:00 is inside 22:00-07:00');

      await show(notifierAt(at(3)), 2);
      expect(inner.shown, isEmpty, reason: 'the window wraps past midnight');

      await show(notifierAt(at(12)), 3);
      expect(inner.shown, [3], reason: 'noon is outside the window');
    });

    test('surfaces everything while quiet hours are disabled', () async {
      await show(notifierAt(at(23)), 1);
      expect(inner.shown, [1], reason: 'defaults are disabled');
    });

    test('a settings change applies to the next notification', () async {
      final notifier = notifierAt(at(23));
      await show(notifier, 1);
      expect(inner.shown, [1]);

      await store.save(
        const QuietHours(
          enabled: true,
          startMinutes: 22 * 60,
          endMinutes: 7 * 60,
        ),
      );
      await show(notifier, 2);
      expect(inner.shown, [1], reason: 'the same notifier now suppresses');
    });
  });
}
