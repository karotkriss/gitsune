import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';
import 'package:gitsune/features/issues/presentation/issue_components.dart';
import 'package:gitsune/features/issues/presentation/issue_create_screen.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/issues/presentation/issue_list_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';
import '../support/fixture_issues_repository.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 8, 2, 10);

  testWidgets('issue list renders row anatomy and paginates at the end', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureIssuesRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keep draft comments after reconnecting'), findsOneWidget);
    expect(find.text('workflow'), findsOneWidget);
    expect(find.text('in review'), findsOneWidget);
    expect(find.text('feature'), findsAtLeastNWidgets(1));
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'2 comments.*Opened by marin.*Labels: workflow::in review, feature',
        ),
      ),
      findsOneWidget,
    );

    expect(repository.nextPageLoads, 1);
    expect(find.text('Document the refresh retry behavior'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('opening an issue shows markdown, metadata, and its thread', (
    tester,
  ) async {
    final repository = FixtureIssuesRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('issue-row-142')));
    await tester.pumpAndSettle();

    expect(find.byType(IssueDetailScreen), findsOneWidget);
    expect(find.text('Keep draft comments after reconnecting'), findsOneWidget);
    expect(find.text('workflow'), findsOneWidget);
    expect(find.text('in review'), findsOneWidget);
    expect(find.text('v1.0'), findsOneWidget);
    expect(find.text('Marin Alvarez'), findsOneWidget);
    expect(
      find.textContaining('preserve draft comments', findRichText: true),
      findsOneWidget,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'added workflow::in review label',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text('The reconnect fixture now covers the queued draft.'),
      findsOneWidget,
    );
    expect(repository.issueLoads, 1);
    expect(repository.firstNotesLoads, 1);
    expect(repository.nextNotesLoads, 1);
  });

  testWidgets('issue description renders before its notes page completes', (
    tester,
  ) async {
    final repository = _DelayedNotesRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Keep draft comments after reconnecting'), findsOneWidget);
    expect(
      find.textContaining('preserve draft comments', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.notes.complete(const IssueNotePage(items: [], hasMore: false));
    await tester.pumpAndSettle();
    expect(find.text('No comments yet.'), findsOneWidget);
  });

  testWidgets('creating an issue previews markdown and folds into the list', (
    tester,
  ) async {
    final repository = FixtureIssuesRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('New issue'));
    await tester.pumpAndSettle();
    expect(find.byType(IssueCreateScreen), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Track reconnect regressions',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Watch for **regressions** weekly',
    );
    await tester.pump();

    expect(find.text('Preview'), findsOneWidget);
    expect(
      find.textContaining('Watch for regressions weekly', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.byType(IssueCreateScreen), findsNothing);
    expect(repository.createdIssues.single, (
      projectId: 7,
      title: 'Track reconnect regressions',
      description: 'Watch for **regressions** weekly',
    ));
    expect(find.byKey(const ValueKey('issue-row-143')), findsOneWidget);
    expect(find.text('Track reconnect regressions'), findsOneWidget);
  });

  testWidgets('posting a comment previews markdown and appends the note', (
    tester,
  ) async {
    final repository = FixtureIssuesRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Confirmed on the **latest** build.',
    );
    await tester.pump();

    expect(find.text('Preview'), findsOneWidget);
    expect(
      find.textContaining('Confirmed on the latest build.', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    expect(repository.createdNotes.single, (
      projectId: 7,
      issueIid: 142,
      body: 'Confirmed on the **latest** build.',
    ));
    expect(find.text('Preview'), findsNothing);
    expect(find.text('Confirmed on the **latest** build.'), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Confirmed on the latest build.', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('create and comment flow uses fixture-backed HTTP end to end', (
    tester,
  ) async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    Map<String, dynamic>? createdIssueBody;
    Map<String, dynamic>? createdNoteBody;
    final initialIssuesLoaded = Completer<void>();
    final createdIssuePosted = Completer<void>();
    final createdIssueLoaded = Completer<void>();
    final createdIssueNotesLoaded = Completer<void>();
    final createdNotePosted = Completer<void>();

    server.handle('GET /api/v4/projects/7/issues', (request) async {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (request.uri.queryParameters['iids[]'] == '143') {
        request.response.write('[${Fixtures.raw('issue_created_143')}]');
        createdIssueLoaded.complete();
      } else {
        request.response.write(Fixtures.raw('issues_page1'));
        initialIssuesLoaded.complete();
      }
      await request.response.close();
    });
    server.handle('POST /api/v4/projects/7/issues', (request) async {
      createdIssueBody =
          jsonDecode(await utf8.decodeStream(request)) as Map<String, dynamic>;
      request.response.statusCode = HttpStatus.created;
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('issue_created_143'));
      await request.response.close();
      createdIssuePosted.complete();
    });
    server.handle('GET /api/v4/projects/7/issues/143/notes', (request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write('[]');
      await request.response.close();
      createdIssueNotesLoaded.complete();
    });
    server.handle('POST /api/v4/projects/7/issues/143/notes', (request) async {
      createdNoteBody =
          jsonDecode(await utf8.decodeStream(request)) as Map<String, dynamic>;
      request.response.statusCode = HttpStatus.created;
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('issue_142_note_created'));
      await request.response.close();
      createdNotePosted.complete();
    });

    const account = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'marin',
    );
    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'fixture-token',
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );
    client.interceptors.clear();
    client.options.headers['Authorization'] = 'Bearer fixture-token';
    client.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => _LoopbackHttpOverrides().createHttpClient(null),
    );
    final repository = GitLabIssuesRepository(client);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: repository,
          now: now,
        ),
      ),
    );
    await _waitForHttp(tester, initialIssuesLoaded.future);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('New issue'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Track reconnect regressions',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      '    indented **draft**\n \t',
    );
    await tester.pump();

    expect(
      tester.widget<GsMarkdown>(find.byType(GsMarkdown)).data,
      '    indented **draft**',
    );
    await tester.tap(find.text('Create'));
    await _waitForHttp(tester, createdIssuePosted.future);
    await tester.pumpAndSettle();

    expect(createdIssueBody, {
      'title': 'Track reconnect regressions',
      'description': '    indented **draft**',
    });
    expect(find.byKey(const ValueKey('issue-row-143')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('issue-row-143')));
    await _waitForHttp(
      tester,
      Future.wait([createdIssueLoaded.future, createdIssueNotesLoaded.future]),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '    comment **body**\n \t');
    await tester.pump();

    expect(
      tester
          .widgetList<GsMarkdown>(find.byType(GsMarkdown))
          .map((markdown) => markdown.data),
      contains('    comment **body**'),
    );
    await tester.tap(find.byTooltip('Send comment'));
    await _waitForHttp(tester, createdNotePosted.future);
    await tester.pumpAndSettle();

    expect(createdNoteBody, {'body': '    comment **body**'});
    expect(find.byKey(const ValueKey('issue-note-9101')), findsOneWidget);
  });

  testWidgets('a delayed notes refresh preserves and deduplicates a comment', (
    tester,
  ) async {
    final repository = _DelayedCommentRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.enterText(
      find.byType(TextField),
      'Confirmed on the **latest** build.',
    );
    await tester.tap(find.byTooltip('Send comment'));
    repository.createdNote.complete(_createdNote());
    await tester.pump();
    repository.firstNotes.complete(
      IssueNotePage(items: [_createdNote()], hasMore: false),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('issue-note-9101')), findsOneWidget);
  });

  testWidgets('refreshing during a comment send preserves its completion', (
    tester,
  ) async {
    final repository = _DelayedCommentRepository(notesImmediately: true);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'refresh race comment');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pump(const Duration(seconds: 1));

    expect(repository.issueLoads, greaterThanOrEqualTo(2));
    repository.createdNote.complete(_createdNote());
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('issue-note-9101')), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
  });

  testWidgets('changing issue scope clears and isolates the comment request', (
    tester,
  ) async {
    final repository = _DelayedCommentRepository(notesImmediately: true);
    Widget screen(int issueIid) => MaterialApp(
      theme: buildAppTheme(),
      home: IssueDetailScreen(
        projectId: 7,
        projectPath: 'gitsune/app',
        issueIid: issueIid,
        repository: repository,
        now: now,
      ),
    );

    await tester.pumpWidget(screen(142));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'old issue draft');
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pump();

    await tester.pumpWidget(screen(141));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(find.text('Preview'), findsNothing);

    repository.createdNote.complete(_createdNote());
    await tester.pumpAndSettle();
    expect(find.textContaining('old issue draft'), findsNothing);
  });

  testWidgets('router exposes issues as a pushed project destination', (
    tester,
  ) async {
    final repository = FixtureIssuesRepository();
    final router = buildAppRouter(
      issuesRepository: repository,
      initialLocation: '/projects/7/issues?projectPath=gitsune%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(IssueListScreen), findsOneWidget);
    expect(find.text('gitsune/app'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('issue-row-142')));
    await tester.pumpAndSettle();

    expect(find.byType(IssueDetailScreen), findsOneWidget);
    expect(find.text('gitsune/app · #142'), findsOneWidget);
  });

  test('relative timestamps stay compact and deterministic', () {
    expect(
      formatIssueRelativeTime(DateTime.utc(2026, 8, 2, 9, 48), now),
      '12m',
    );
    expect(formatIssueRelativeTime(DateTime.utc(2026, 8, 1, 10), now), '1d');
    expect(
      formatIssueRelativeTime(DateTime.utc(2026, 7, 1, 12), now),
      '2026-07-01',
    );
  });
}

class _DelayedNotesRepository implements IssuesRepository {
  final _delegate = FixtureIssuesRepository();
  final notes = Completer<IssueNotePage>();

  @override
  Future<IssuePage> loadFirstPage(int projectId) =>
      _delegate.loadFirstPage(projectId);

  @override
  Future<IssuePage> loadNextPage(int projectId) =>
      _delegate.loadNextPage(projectId);

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) =>
      _delegate.loadIssue(projectId, issueIid);

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) =>
      notes.future;

  @override
  Future<IssueNotePage> loadNextNotesPage(int projectId, int issueIid) =>
      throw StateError('No next notes page.');

  @override
  Future<Issue> createIssue(
    int projectId, {
    required String title,
    String description = '',
  }) =>
      _delegate.createIssue(projectId, title: title, description: description);

  @override
  Future<IssueNote> createNote(int projectId, int issueIid, String body) =>
      _delegate.createNote(projectId, issueIid, body);
}

class _DelayedCommentRepository implements IssuesRepository {
  _DelayedCommentRepository({this.notesImmediately = false});

  final bool notesImmediately;
  final _delegate = FixtureIssuesRepository();
  final firstNotes = Completer<IssueNotePage>();
  final createdNote = Completer<IssueNote>();
  int issueLoads = 0;

  @override
  Future<IssuePage> loadFirstPage(int projectId) =>
      _delegate.loadFirstPage(projectId);

  @override
  Future<IssuePage> loadNextPage(int projectId) =>
      _delegate.loadNextPage(projectId);

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) {
    issueLoads++;
    return _delegate.loadIssue(projectId, issueIid);
  }

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) =>
      notesImmediately
      ? Future.value(const IssueNotePage(items: [], hasMore: false))
      : firstNotes.future;

  @override
  Future<IssueNotePage> loadNextNotesPage(int projectId, int issueIid) =>
      throw StateError('No next notes page.');

  @override
  Future<Issue> createIssue(
    int projectId, {
    required String title,
    String description = '',
  }) =>
      _delegate.createIssue(projectId, title: title, description: description);

  @override
  Future<IssueNote> createNote(int projectId, int issueIid, String body) =>
      createdNote.future;
}

IssueNote _createdNote() => IssueNote.fromJson(
  Map<String, dynamic>.from(Fixtures.json('issue_142_note_created') as Map),
);

Future<void> _waitForHttp<T>(WidgetTester tester, Future<T> future) async {
  var completed = false;
  Object? failure;
  StackTrace? failureStack;
  unawaited(
    future.then<void>(
      (_) => completed = true,
      onError: (Object error, StackTrace stack) {
        failure = error;
        failureStack = stack;
        completed = true;
      },
    ),
  );
  for (var attempt = 0; attempt < 100 && !completed; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  if (failure != null) {
    Error.throwWithStackTrace(failure!, failureStack!);
  }
  if (!completed) {
    throw TimeoutException('Loopback HTTP request did not complete.');
  }
}

class _LoopbackHttpOverrides extends HttpOverrides {}
