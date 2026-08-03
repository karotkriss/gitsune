import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';

/// The seam the poller fires new-to-do notifications through, so tests (and
/// later delivery layers) never depend on the OS notification plumbing.
/// The on-device implementation is `LocalTodoNotifier` in
/// `local_todo_notifier.dart`.
abstract class TodoNotifier {
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  });
}

/// The seam that owns *when* polls run, so the baseline foreground timer can
/// be swapped for real background scheduling (Android WorkManager, iOS
/// background refresh) in E12.3+ without touching the poller.
abstract class PollScheduler {
  void start(Future<void> Function() poll);
  void stop();
}

/// The baseline scheduler: a periodic foreground timer.
class TimerPollScheduler implements PollScheduler {
  TimerPollScheduler({this.interval = const Duration(minutes: 5)});

  final Duration interval;
  Timer? _timer;
  bool _pollInProgress = false;

  @override
  void start(Future<void> Function() poll) {
    stop();
    _timer = Timer.periodic(interval, (_) {
      if (_pollInProgress) {
        return;
      }
      _pollInProgress = true;
      unawaited(_runPoll(poll));
    });
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _runPoll(Future<void> Function() poll) async {
    try {
      await poll();
    } on Object {
      return;
    } finally {
      _pollInProgress = false;
    }
  }
}

/// The layered notification architecture's baseline (ADR 0002, layer 1):
/// conditional-request polling of `GET /todos`, on-device only, no server
/// relay of any kind.
///
/// Each [poll] sends the account's stored `ETag` as `If-None-Match`. A
/// `304 Not Modified` costs no body and changes nothing. A `200` is diffed
/// against the account's last-seen to-do ids and each genuinely new to-do
/// fires one local notification through [notifier]; the very first poll only
/// seeds that state, so a fresh sign-in never replays the existing backlog.
///
/// The poll reads a single newest-first page rather than paginating the whole
/// collection; anything new since the last poll appears there first, and the
/// Todos screen's `TodosRepository.refresh` remains the full-collection sync.
class TodosPoller {
  TodosPoller({
    required this.database,
    required this.client,
    required this.account,
    required this.notifier,
  });

  final AppDatabase database;
  final Dio client;
  final AccountKey account;
  final TodoNotifier notifier;

  Future<void> poll() async {
    final state =
        await (database.select(database.todoPollStates)..where(
              (t) =>
                  t.instanceHost.equals(account.instanceHost) &
                  t.accountId.equals(account.accountId),
            ))
            .getSingleOrNull();

    final Response<Object?> response;
    try {
      response = await client.get<Object?>(
        '/todos',
        queryParameters: {'per_page': '100'},
        options: Options(
          headers: {if (state?.etag != null) 'If-None-Match': state!.etag},
          validateStatus: (status) => status == 200 || status == 304,
        ),
      );
    } on DioException {
      return;
    }
    if (response.statusCode == 304) {
      return;
    }

    final items = (response.data as List<dynamic>).cast<Map<String, dynamic>>();
    final fetchedIds = <int>[for (final item in items) item['id'] as int];

    if (state != null) {
      final seenIds = (jsonDecode(state.seenTodoIds) as List<dynamic>)
          .cast<int>()
          .toSet();
      for (final item in items) {
        if (seenIds.contains(item['id'] as int)) {
          continue;
        }
        final target = item['target'] as Map<String, dynamic>?;
        await notifier.showNewTodo(
          account: account,
          todoId: item['id'] as int,
          title: item['body'] as String? ?? item['action_name'] as String,
          body:
              target?['title'] as String? ??
              item['target_url'] as String? ??
              '',
        );
      }
    }

    await database
        .into(database.todoPollStates)
        .insertOnConflictUpdate(
          TodoPollStatesCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            etag: Value(response.headers.value('etag')),
            seenTodoIds: jsonEncode(fetchedIds),
            updatedAt: DateTime.now(),
          ),
        );
  }
}
