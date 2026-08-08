import 'package:dio/io.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/repository/todos_repository.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';
import 'package:gitsune/features/todos/todo_deep_link.dart';
import 'package:gitsune/features/todos/todos_screen.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/fixtures.dart';
import '../../support/loopback_http_overrides.dart';
import '../issues/support/fixture_issues_repository.dart';
import 'support/fixture_todos_repository.dart';

void main() {
  // Real HTTP against the in-process fake server needs the real event loop.
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final createdAt = DateTime.utc(2026, 8, 1);

  group('todoRouteLocation', () {
    test('routes an issue to-do to the issue detail surface', () {
      final todo = fixtureTodo(
        id: 101,
        actionName: 'assigned',
        targetType: 'Issue',
        targetIid: 233,
        body: 'Priya assigned you',
        createdAt: createdAt,
      );
      expect(
        todoRouteLocation(todo),
        '/projects/1/issues/233?projectPath=gitsune%2Fapp',
      );
    });

    test('routes a merge request to-do to the MR detail surface', () {
      final todo = fixtureTodo(
        id: 102,
        actionName: 'review_requested',
        targetType: 'MergeRequest',
        targetIid: 142,
        body: 'Ade requested your review',
        createdAt: createdAt,
      );
      expect(
        todoRouteLocation(todo),
        '/projects/1/merge_requests/142?projectPath=gitsune%2Fapp',
      );
    });

    test('routes a pipeline to-do using the pipeline id from its web URL', () {
      final todo = fixtureTodo(
        id: 88101,
        actionName: 'build_failed',
        targetType: 'Pipeline',
        body: 'Pipeline failed on main',
        createdAt: createdAt,
      );
      expect(
        todoRouteLocation(todo),
        '/projects/1/pipelines/88101?projectPath=gitsune%2Fapp',
      );
    });

    test('falls back to web for target types without an in-app surface', () {
      for (final targetType in ['Epic', 'DesignManagement::Design', 'Commit']) {
        final todo = fixtureTodo(
          id: 201,
          actionName: 'directly_addressed',
          targetType: targetType,
          body: 'Mentioned you',
          createdAt: createdAt,
        );
        expect(todoRouteLocation(todo), isNull, reason: targetType);
      }
    });

    test('falls back to web when the project id is missing', () {
      final todo = fixtureTodo(
        id: 101,
        actionName: 'assigned',
        targetType: 'Issue',
        projectId: null,
        targetIid: 233,
        body: 'Priya assigned you',
        createdAt: createdAt,
      );
      expect(todoRouteLocation(todo), isNull);
    });

    test('falls back to web when an issue to-do has no target iid', () {
      final todo = fixtureTodo(
        id: 101,
        actionName: 'assigned',
        targetType: 'Issue',
        body: 'Priya assigned you',
        createdAt: createdAt,
      );
      expect(todoRouteLocation(todo), isNull);
    });

    test('falls back to web when a pipeline URL carries no trailing id', () {
      final todo = fixtureTodo(
        id: 88101,
        actionName: 'build_failed',
        targetType: 'Pipeline',
        targetUrl: 'https://gitlab.example.com/gitsune/app/-/pipelines',
        body: 'Pipeline failed on main',
        createdAt: createdAt,
      );
      expect(todoRouteLocation(todo), isNull);
    });
  });

  testWidgets('tapping an issue to-do opens the issue screen and tapping an '
      'unknown-type to-do opens its web URL', (tester) async {
    const account = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'alice',
    );
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/todos', Fixtures.json('todos_deeplink'));

    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('tok'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );
    // Escape flutter_test's mocked HttpClient so requests reach the loopback
    // fake server, while keeping the no-live-instance guard (a non-loopback
    // host still throws LiveNetworkBlocked), matching the sibling widget tests.
    client.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => LoopbackHttpOverrides().createHttpClient(null),
    );
    final repository = TodosRepository(
      database: db,
      client: client,
      account: account,
    );
    await repository.refresh();

    final openedWebUrls = <Uri>[];
    final router = buildAppRouter(
      todosRepository: repository,
      issuesRepository: FixtureIssuesRepository(),
      openWebUrl: (url) async => openedWebUrls.add(url),
      initialLocation: '/todos',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep draft comments after reconnecting'));
    await tester.pumpAndSettle();
    expect(find.byType(IssueDetailScreen), findsOneWidget);
    expect(openedWebUrls, isEmpty);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(TodosScreen), findsOneWidget);

    await tester.tap(find.text('Mobile release epic'));
    await tester.pumpAndSettle();
    expect(find.byType(TodosScreen), findsOneWidget);
    expect(openedWebUrls, [
      Uri.parse('https://gitlab.example.com/groups/gitsune/-/epics/9'),
    ]);

    // Drain the screen's own in-flight refresh (the queue serializes), then
    // unmount so the drift stream cancels before the database closes.
    await repository.refresh();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
