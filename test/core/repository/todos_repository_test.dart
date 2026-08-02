import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/repository/todos_repository.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  /// Serves two offset-paginated pages of to-dos, mirroring GitLab's real
  /// behavior: a `Link: <...>; rel="next"` header on every page but the
  /// last.
  void registerTwoTodoPages(FakeGitLabServer server) {
    const fixtureByPage = {'1': 'todos_page1', '2': 'todos_page2'};

    server.handle('GET /api/v4/todos', (request) async {
      final page = request.uri.queryParameters['page'] ?? '1';
      expect(request.uri.queryParameters['per_page'], '100');
      expect(request.uri.queryParameters.containsKey('pagination'), isFalse);
      expect(request.uri.queryParameters.containsKey('order_by'), isFalse);
      expect(request.uri.queryParameters.containsKey('sort'), isFalse);
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      if (page == '1') {
        final nextUri = server.baseUri.resolve(
          '/api/v4/todos?page=2&per_page=100',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
      }
      request.response.write(Fixtures.raw(fixtureByPage[page]!));
      await request.response.close();
    });
  }

  test('an initial read serves the cached database state', () async {
    await db
        .into(db.todoItems)
        .insert(
          TodoItemsCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            todoId: 1,
            authorName: 'Alice',
            authorUsername: 'alice',
            actionName: 'assigned',
            targetType: 'Issue',
            targetUrl: 'https://gitlab.example.com/gitsune/app/-/issues/1',
            body: 'Cached to-do',
            state: 'pending',
            createdAt: DateTime.utc(2026, 7, 1),
          ),
        );

    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = TodosRepository(
      database: db,
      client: client,
      account: account,
    );

    final todos = await repository.watch().first;

    expect(todos, hasLength(1));
    expect(todos.single.body, 'Cached to-do');
  });

  test(
    'a refresh paginates the whole collection, writes through, and the '
    'stream re-emits',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      registerTwoTodoPages(server);

      final client = createGitLabClient(
        account: account,
        baseUrl: server.baseUri.resolve('/api/v4'),
        readToken: (_) async => 'tok',
        refreshToken: (_) async => fail('refresh should not be called'),
      );
      final repository = TodosRepository(
        database: db,
        client: client,
        account: account,
      );

      final emissions = repository.watch().map((todos) => todos.length);
      final expectation = expectLater(emissions, emitsInOrder([0, 3]));

      await repository.refresh();

      await expectation;

      final todos = await repository.watch().first;
      expect(todos.map((t) => t.todoId), [102, 101, 88101]);
      expect(todos.first.targetTitle, 'Add instance switcher sheet');
      expect(todos.last.targetType, 'Pipeline');
    },
  );

  test('a subsequent refresh replaces to-dos no longer returned', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/todos', Fixtures.json('todos_page2'));

    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = TodosRepository(
      database: db,
      client: client,
      account: account,
    );

    await db
        .into(db.todoItems)
        .insert(
          TodoItemsCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            todoId: 999,
            authorName: 'Stale',
            authorUsername: 'stale',
            actionName: 'assigned',
            targetType: 'Issue',
            targetUrl: 'https://gitlab.example.com/gitsune/app/-/issues/999',
            body: 'Stale to-do',
            state: 'pending',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );

    await repository.refresh();

    final todos = await repository.watch().first;
    expect(todos.map((t) => t.todoId), [88101]);
  });

  test('a network failure leaves cached data served (offline-first)', () async {
    await db
        .into(db.todoItems)
        .insert(
          TodoItemsCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            todoId: 1,
            authorName: 'Alice',
            authorUsername: 'alice',
            actionName: 'assigned',
            targetType: 'Issue',
            targetUrl: 'https://gitlab.example.com/gitsune/app/-/issues/1',
            body: 'Cached to-do',
            state: 'pending',
            createdAt: DateTime.utc(2026, 7, 1),
          ),
        );

    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/todos', {'error': 'boom'}, statusCode: 500);

    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = TodosRepository(
      database: db,
      client: client,
      account: account,
    );

    await repository.refresh();

    final todos = await repository.watch().first;
    expect(todos, hasLength(1));
    expect(todos.single.body, 'Cached to-do');
  });

  test('overlapping refreshes commit snapshots in request order', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final firstRequestStarted = Completer<void>();
    final releaseFirstRequest = Completer<void>();
    var requestCount = 0;
    server.handle('GET /api/v4/todos', (request) async {
      requestCount += 1;
      final todo = List<Map<String, dynamic>>.from(
        Fixtures.json('todos_page2') as List,
      ).single;
      if (requestCount == 1) {
        firstRequestStarted.complete();
        await releaseFirstRequest.future;
        todo['body'] = 'Older snapshot';
      } else {
        todo['body'] = 'Newer snapshot';
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode([todo]));
      await request.response.close();
    });

    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = TodosRepository(
      database: db,
      client: client,
      account: account,
    );

    final firstRefresh = repository.refresh();
    await firstRequestStarted.future;
    final secondRefresh = repository.refresh();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    releaseFirstRequest.complete();
    await Future.wait([firstRefresh, secondRefresh]);

    expect(requestCount, 2);
    final todos = await repository.watch().first;
    expect(todos.single.body, 'Newer snapshot');
  });

  test('the composite key is instanceHost + accountId + todoId', () {
    expect(db.todoItems.primaryKey, {
      db.todoItems.instanceHost,
      db.todoItems.accountId,
      db.todoItems.todoId,
    });
  });
}
