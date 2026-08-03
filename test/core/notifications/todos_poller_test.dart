import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/notifications/todos_poller.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/fixtures.dart';

class RecordingNotifier implements TodoNotifier {
  final shown =
      <({AccountKey account, int todoId, String title, String body})>[];

  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) async {
    shown.add((account: account, todoId: todoId, title: title, body: body));
  }
}

/// Serves `GET /api/v4/todos` with real conditional-request semantics:
/// a matching `If-None-Match` gets an empty `304`, anything else gets the
/// current [todos] body tagged with the current [etag].
class ConditionalTodosEndpoint {
  ConditionalTodosEndpoint(FakeGitLabServer server) {
    server.handle('GET /api/v4/todos', (request) async {
      receivedIfNoneMatch.add(request.headers.value('if-none-match'));
      if (request.headers.value('if-none-match') == etag) {
        request.response.statusCode = HttpStatus.notModified;
        await request.response.close();
        return;
      }
      request.response.statusCode = 200;
      request.response.headers.set('ETag', etag);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(todos));
      await request.response.close();
    });
  }

  String etag = 'W/"v1"';
  List<Map<String, dynamic>> todos = List<Map<String, dynamic>>.from(
    Fixtures.json('todos_page1') as List<dynamic>,
  );
  final receivedIfNoneMatch = <String?>[];
}

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

  late AppDatabase db;
  late FakeGitLabServer server;
  late ConditionalTodosEndpoint endpoint;
  late RecordingNotifier notifier;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    server = await FakeGitLabServer.start();
    endpoint = ConditionalTodosEndpoint(server);
    notifier = RecordingNotifier();
  });

  tearDown(() async {
    await server.close();
    await db.close();
  });

  TodosPoller createPoller([AccountKey pollerAccount = account]) => TodosPoller(
    database: db,
    client: createGitLabClient(
      account: pollerAccount,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('tok'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    ),
    account: pollerAccount,
    notifier: notifier,
  );

  test(
    'the first poll seeds ETag and last-seen state without notifying',
    () async {
      await createPoller().poll();

      expect(endpoint.receivedIfNoneMatch, [null]);
      expect(notifier.shown, isEmpty);

      final state = await db.select(db.todoPollStates).getSingle();
      expect(state.instanceHost, account.instanceHost);
      expect(state.accountId, account.accountId);
      expect(state.etag, 'W/"v1"');
      expect(jsonDecode(state.seenTodoIds), [102, 101]);
    },
  );

  test('the persisted ETag is sent as If-None-Match and a 304 stays quiet '
      '(even across poller instances)', () async {
    await createPoller().poll();

    // A fresh poller instance proves the ETag round-trips through the
    // database, not just instance memory.
    await createPoller().poll();

    expect(endpoint.receivedIfNoneMatch, [null, 'W/"v1"']);
    expect(notifier.shown, isEmpty);

    final state = await db.select(db.todoPollStates).getSingle();
    expect(state.etag, 'W/"v1"');
  });

  test(
    'a 200 with a new to-do fires exactly one notification for it',
    () async {
      final poller = createPoller();
      await poller.poll();

      endpoint.etag = 'W/"v2"';
      endpoint.todos = [
        {
          'id': 103,
          'author': {'name': 'Priya Sharma', 'username': 'priya'},
          'action_name': 'directly_addressed',
          'target_type': 'Issue',
          'target': {'iid': 240, 'title': 'Poller loses ETag on restart'},
          'target_url': 'https://gitlab.example.com/gitsune/app/-/issues/240',
          'body': 'Priya mentioned you',
          'state': 'pending',
          'created_at': '2026-08-01T09:00:00.000Z',
        },
        ...endpoint.todos,
      ];
      await poller.poll();

      expect(notifier.shown, hasLength(1));
      final shown = notifier.shown.single;
      expect(shown.account, account);
      expect(shown.todoId, 103);
      expect(shown.title, 'Priya mentioned you');
      expect(shown.body, 'Poller loses ETag on restart');

      // The new to-do is now last-seen: polling the same body again (fresh
      // ETag, so no 304 shortcut) must not re-notify.
      endpoint.etag = 'W/"v3"';
      await poller.poll();
      expect(notifier.shown, hasLength(1));
      expect(endpoint.receivedIfNoneMatch, [null, 'W/"v1"', 'W/"v2"']);
    },
  );

  test('poll state is account-scoped: one account never notifies for or '
      'consumes another\'s state', () async {
    await createPoller().poll();

    // Account A has seen ids 102 and 101; the same server content is brand
    // new to account B, whose first poll must seed silently, not replay.
    const other = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'bram',
    );
    await createPoller(other).poll();
    expect(notifier.shown, isEmpty);
    // B has no stored ETag yet, so its first request is unconditional.
    expect(endpoint.receivedIfNoneMatch, [null, null]);

    final states = await db.select(db.todoPollStates).get();
    expect(states.map((s) => s.accountId).toSet(), {'alice', 'bram'});

    // A new to-do notifies each account exactly once, attributed to it.
    endpoint.etag = 'W/"v2"';
    endpoint.todos = [
      ...endpoint.todos,
      (Fixtures.json('todos_page2') as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .single,
    ];
    await createPoller().poll();
    expect(notifier.shown, hasLength(1));
    expect(notifier.shown.single.account, account);
    await createPoller(other).poll();
    expect(notifier.shown, hasLength(2));
    expect(notifier.shown.last.account, other);
    expect(notifier.shown.last.todoId, 88101);
  });

  test('a network failure changes nothing and notifies nothing', () async {
    final poller = createPoller();
    await poller.poll();
    await server.close();

    await poller.poll();

    expect(notifier.shown, isEmpty);
    final state = await db.select(db.todoPollStates).getSingle();
    expect(state.etag, 'W/"v1"');
  });

  test('TimerPollScheduler polls on its interval until stopped', () {
    fakeAsync((async) {
      var polls = 0;
      final scheduler = TimerPollScheduler(
        interval: const Duration(minutes: 5),
      );

      scheduler.start(() async => polls++);
      async.elapse(const Duration(minutes: 16));
      expect(polls, 3);

      scheduler.stop();
      async.elapse(const Duration(minutes: 30));
      expect(polls, 3);
    });
  });

  test('TimerPollScheduler serializes polls and recovers from errors', () {
    fakeAsync((async) {
      final firstPoll = Completer<void>();
      var polls = 0;
      final scheduler = TimerPollScheduler(
        interval: const Duration(minutes: 5),
      );

      scheduler.start(() {
        polls++;
        return switch (polls) {
          1 => firstPoll.future,
          2 => Future<void>.error(StateError('poll failed')),
          _ => Future<void>.value(),
        };
      });

      async.elapse(const Duration(minutes: 15));
      expect(polls, 1);

      firstPoll.complete();
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));
      expect(polls, 2);

      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));
      expect(polls, 3);
      scheduler.stop();
    });
  });

  test('the poll state composite key is instanceHost + accountId', () {
    expect(db.todoPollStates.primaryKey, {
      db.todoPollStates.instanceHost,
      db.todoPollStates.accountId,
    });
  });
}
