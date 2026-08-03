import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/repository/recently_viewed_repository.dart';
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

  testWidgets('triage actions fold into the issue and add inline events', (
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
    expect(repository.issueLoads, 1);

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close issue'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls.last.stateEvent, 'close');
    expect(find.text('Closed'), findsOneWidget);

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reopen issue'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls.last.stateEvent, 'reopen');
    expect(find.text('Open'), findsOneWidget);

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('bug'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls.last.labels, [
      'workflow::in review',
      'feature',
      'bug',
    ]);
    final bugPill = tester
        .widgetList<IssueLabelPill>(find.byType(IssueLabelPill))
        .singleWhere((pill) => pill.label.name == 'bug');
    expect(bugPill.label.colorHex, '#DD2B0E');

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit assignees'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Noe Fernandez'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls.last.assigneeIds, [12, 13]);
    expect(find.text('Noe Fernandez'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('You closed', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('You reopened', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('You added bug label', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('You assigned to @noe', findRichText: true),
      findsOneWidget,
    );
    expect(repository.issueLoads, 1);
    expect(repository.firstNotesLoads, 1);
  });

  testWidgets('triage pickers preserve selections outside the loaded page', (
    tester,
  ) async {
    final repository = _TriageRegressionRepository(
      projectLabels: _fixtureLabels()
          .where((label) => label.name == 'bug')
          .toList(),
      projectMembers: _fixtureMembers()
          .where((member) => member.username == 'noe')
          .toList(),
    );
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

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(CheckboxListTile),
        matching: find.text('workflow::in review'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CheckboxListTile),
        matching: find.text('feature'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('bug'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls.last.labels?.toSet(), {
      'workflow::in review',
      'feature',
      'bug',
    });

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit assignees'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(CheckboxListTile),
        matching: find.text('Suki Kim'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Noe Fernandez'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(repository.updateCalls.last.assigneeIds?.toSet(), {12, 13});
  });

  testWidgets('a recently viewed issue renders offline from the cache', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final cache = RecentlyViewedCache(
      database: db,
      account: const AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: 'alice',
      ),
    );
    await cache.put(
      RecentlyViewedType.issue,
      7,
      142,
      jsonEncode(Fixtures.json('issue_142')),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: _OfflineIssuesRepository(),
          recentlyViewedCache: cache,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keep draft comments after reconnecting'), findsOneWidget);
    expect(find.text('Unable to refresh this issue.'), findsOneWidget);
  });

  testWidgets('switching account caches replaces the displayed issue', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    RecentlyViewedCache cacheFor(String accountId) => RecentlyViewedCache(
      database: db,
      account: AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: accountId,
      ),
    );
    final aliceCache = cacheFor('alice');
    final bobCache = cacheFor('bob');
    final fixture = Map<String, dynamic>.from(
      Fixtures.json('issue_142') as Map,
    );
    await aliceCache.put(
      RecentlyViewedType.issue,
      7,
      142,
      jsonEncode({...fixture, 'title': 'Alice issue'}),
    );
    await bobCache.put(
      RecentlyViewedType.issue,
      7,
      142,
      jsonEncode({...fixture, 'title': 'Bob issue'}),
    );

    Widget screen(RecentlyViewedCache cache) => MaterialApp(
      theme: buildAppTheme(),
      home: IssueDetailScreen(
        projectId: 7,
        projectPath: 'gitsune/app',
        issueIid: 142,
        repository: _OfflineIssuesRepository(),
        recentlyViewedCache: cache,
        now: now,
      ),
    );

    await tester.pumpWidget(screen(aliceCache));
    await tester.pumpAndSettle();
    expect(find.text('Alice issue'), findsOneWidget);

    await tester.pumpWidget(screen(bobCache));
    await tester.pumpAndSettle();
    expect(find.text('Alice issue'), findsNothing);
    expect(find.text('Bob issue'), findsOneWidget);
  });

  testWidgets('an initial issue still touches its cached view timestamp', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    var clock = DateTime.utc(2026, 8, 2, 8);
    final cache = RecentlyViewedCache(
      database: db,
      account: const AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: 'alice',
      ),
      now: () => clock,
    );
    await cache.put(
      RecentlyViewedType.issue,
      7,
      142,
      jsonEncode(Fixtures.json('issue_142')),
    );
    clock = DateTime.utc(2026, 8, 2, 9);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: _OfflineIssuesRepository(),
          recentlyViewedCache: cache,
          initialIssue: _fixtureIssue(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = await db.select(db.recentlyViewedItems).getSingle();
    expect(row.lastViewedAt.toUtc(), clock);
  });

  testWidgets('triage writes the updated issue through to the cache', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final cache = RecentlyViewedCache(
      database: db,
      account: const AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: 'alice',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: FixtureIssuesRepository(),
          recentlyViewedCache: cache,
          initialIssue: _fixtureIssue(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close issue'));
    await tester.pumpAndSettle();

    final payload = await cache
        .watchPayload(RecentlyViewedType.issue, 7, 142)
        .first;
    final cached = Issue.fromJson(jsonDecode(payload!) as Map<String, dynamic>);
    expect(cached.state, IssueState.closed);
  });

  testWidgets('a stale issue refresh cannot overwrite committed triage', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final cache = RecentlyViewedCache(
      database: db,
      account: const AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: 'alice',
      ),
    );
    final staleIssue = Completer<Issue>();
    final repository = _TriageRegressionRepository(delayedIssue: staleIssue);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          recentlyViewedCache: cache,
          initialIssue: _fixtureIssue(),
          now: now,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Close issue'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Closed'), findsOneWidget);

    staleIssue.complete(_fixtureIssue());
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsOneWidget);
    final payload = await cache
        .watchPayload(RecentlyViewedType.issue, 7, 142)
        .first;
    expect(
      Issue.fromJson(jsonDecode(payload!) as Map<String, dynamic>).state,
      IssueState.closed,
    );
  });

  testWidgets('a cache write failure does not fail successful triage', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final cache = _FailingWriteRecentlyViewedCache(
      database: db,
      account: const AccountKey(
        instanceHost: 'gitlab.example.com',
        accountId: 'alice',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: FixtureIssuesRepository(),
          recentlyViewedCache: cache,
          initialIssue: _fixtureIssue(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close issue'));
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Unable to update the issue.'), findsNothing);
  });

  testWidgets('a pending notes refresh preserves later triage events', (
    tester,
  ) async {
    final staleNotes = Completer<IssueNotePage>();
    final repository = _TriageRegressionRepository(delayedNotes: staleNotes);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          initialIssue: _fixtureIssue(),
          now: now,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Close issue'));
    await tester.pump();
    await tester.pump();

    staleNotes.complete(const IssueNotePage(items: [], hasMore: false));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('You closed', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('picker options are discarded after issue scope changes', (
    tester,
  ) async {
    final staleLabels = Completer<List<IssueLabel>>();
    final repository = _TriageRegressionRepository(delayedLabels: staleLabels);
    Widget screen(int issueIid) => MaterialApp(
      theme: buildAppTheme(),
      home: IssueDetailScreen(
        projectId: 7,
        projectPath: 'gitsune/app',
        issueIid: issueIid,
        repository: repository,
        initialIssue: _fixtureIssue(),
        now: now,
      ),
    );

    await tester.pumpWidget(screen(142));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await tester.pump();

    await tester.pumpWidget(screen(141));
    await tester.pumpAndSettle();
    staleLabels.complete(_fixtureLabels());
    await tester.pumpAndSettle();

    expect(find.text('Labels'), findsNothing);
    expect(repository.updateCalls, isEmpty);
  });

  testWidgets('picker selection is discarded after issue state refreshes', (
    tester,
  ) async {
    final refreshedIssue = Completer<Issue>();
    final repository = _TriageRegressionRepository(
      delayedIssue: refreshedIssue,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          initialIssue: _fixtureIssue(),
          now: now,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Edit labels'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Labels'), findsOneWidget);
    refreshedIssue.complete(_fixtureIssueWithLabels(['bug']));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.updateCalls, isEmpty);
    expect(find.text('bug'), findsOneWidget);
  });

  testWidgets('triage flow uses fixture-backed HTTP end to end', (
    tester,
  ) async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var issueJson = Map<String, dynamic>.from(
      Fixtures.json('issue_142') as Map,
    );
    var issueGets = 0;
    final initialIssueLoaded = Completer<void>();
    final notesLoaded = Completer<void>();
    final labelsLoaded = Completer<void>();
    final membersLoaded = Completer<void>();
    final putBodies = <Map<String, dynamic>>[];
    var putDone = Completer<void>();

    server.handle('GET /api/v4/projects/7/issues', (request) async {
      issueGets++;
      request.response.headers.contentType = ContentType.json;
      request.response.write('[${jsonEncode(issueJson)}]');
      await request.response.close();
      if (!initialIssueLoaded.isCompleted) initialIssueLoaded.complete();
    });
    server.handle('GET /api/v4/projects/7/issues/142/notes', (request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write('[]');
      await request.response.close();
      if (!notesLoaded.isCompleted) notesLoaded.complete();
    });
    server.handle('GET /api/v4/projects/7/labels', (request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('project_7_labels'));
      await request.response.close();
      if (!labelsLoaded.isCompleted) labelsLoaded.complete();
    });
    server.handle('GET /api/v4/projects/7/members/all', (request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('project_7_members'));
      await request.response.close();
      if (!membersLoaded.isCompleted) membersLoaded.complete();
    });
    server.handle('PUT /api/v4/projects/7/issues/142', (request) async {
      final body =
          jsonDecode(await utf8.decodeStream(request)) as Map<String, dynamic>;
      putBodies.add(body);
      issueJson = applyIssueUpdateJson(issueJson, body);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(issueJson));
      await request.response.close();
      putDone.complete();
    });

    const account = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'marin',
    );
    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('fixture-token'),
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
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository,
          now: now,
        ),
      ),
    );
    await _waitForHttp(
      tester,
      Future.wait([initialIssueLoaded.future, notesLoaded.future]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close issue'));
    await _waitForHttp(tester, putDone.future);
    await tester.pumpAndSettle();

    expect(putBodies.last, {'state_event': 'close'});
    expect(issueJson['state'], 'closed');
    expect(find.text('Closed'), findsOneWidget);

    putDone = Completer<void>();
    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit labels'));
    await _waitForHttp(tester, labelsLoaded.future);
    await tester.pumpAndSettle();
    await tester.tap(find.text('bug'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await _waitForHttp(tester, putDone.future);
    await tester.pumpAndSettle();

    expect(putBodies.last, {'labels': 'workflow::in review,feature,bug'});
    expect(issueJson['labels'], contains('bug'));

    putDone = Completer<void>();
    await tester.tap(find.byTooltip('Issue actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit assignees'));
    await _waitForHttp(tester, membersLoaded.future);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Noe Fernandez'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await _waitForHttp(tester, putDone.future);
    await tester.pumpAndSettle();

    expect(putBodies.last, {
      'assignee_ids': [12, 13],
    });

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('You closed', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('You added bug label', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('You assigned to @noe', findRichText: true),
      findsOneWidget,
    );
    expect(issueGets, 1);
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
      readToken: (_) async => const TokenReadResult('fixture-token'),
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

  @override
  Future<List<IssueLabel>> loadProjectLabels(int projectId) =>
      _delegate.loadProjectLabels(projectId);

  @override
  Future<List<IssueAuthor>> loadProjectMembers(int projectId) =>
      _delegate.loadProjectMembers(projectId);

  @override
  Future<Issue> updateIssue(
    int projectId,
    int issueIid, {
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  }) => _delegate.updateIssue(
    projectId,
    issueIid,
    labels: labels,
    assigneeIds: assigneeIds,
    stateEvent: stateEvent,
  );
}

class _TriageRegressionRepository extends FixtureIssuesRepository {
  _TriageRegressionRepository({
    this.delayedIssue,
    this.delayedNotes,
    this.delayedLabels,
    this.projectLabels,
    this.projectMembers,
  });

  final Completer<Issue>? delayedIssue;
  final Completer<IssueNotePage>? delayedNotes;
  final Completer<List<IssueLabel>>? delayedLabels;
  final List<IssueLabel>? projectLabels;
  final List<IssueAuthor>? projectMembers;

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) {
    if (delayedIssue case final delayed?) {
      issueLoads++;
      return delayed.future;
    }
    return super.loadIssue(projectId, issueIid);
  }

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) {
    if (delayedNotes case final delayed?) {
      firstNotesLoads++;
      return delayed.future;
    }
    return super.loadFirstNotesPage(projectId, issueIid);
  }

  @override
  Future<List<IssueLabel>> loadProjectLabels(int projectId) {
    if (delayedLabels case final delayed?) return delayed.future;
    if (projectLabels case final labels?) return Future.value(labels);
    return super.loadProjectLabels(projectId);
  }

  @override
  Future<List<IssueAuthor>> loadProjectMembers(int projectId) {
    if (projectMembers case final members?) return Future.value(members);
    return super.loadProjectMembers(projectId);
  }
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

  @override
  Future<List<IssueLabel>> loadProjectLabels(int projectId) =>
      _delegate.loadProjectLabels(projectId);

  @override
  Future<List<IssueAuthor>> loadProjectMembers(int projectId) =>
      _delegate.loadProjectMembers(projectId);

  @override
  Future<Issue> updateIssue(
    int projectId,
    int issueIid, {
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  }) => _delegate.updateIssue(
    projectId,
    issueIid,
    labels: labels,
    assigneeIds: assigneeIds,
    stateEvent: stateEvent,
  );
}

IssueNote _createdNote() => IssueNote.fromJson(
  Map<String, dynamic>.from(Fixtures.json('issue_142_note_created') as Map),
);

Issue _fixtureIssue() => Issue.fromJson(
  Map<String, dynamic>.from(Fixtures.json('issue_142') as Map),
);

Issue _fixtureIssueWithLabels(List<String> labels) {
  final json = Map<String, dynamic>.from(Fixtures.json('issue_142') as Map);
  json['labels'] = labels;
  return Issue.fromJson(json);
}

List<IssueLabel> _fixtureLabels() => (Fixtures.json('project_7_labels') as List)
    .map(IssueLabel.fromJson)
    .toList(growable: false);

List<IssueAuthor> _fixtureMembers() =>
    (Fixtures.json('project_7_members') as List)
        .map(
          (value) =>
              IssueAuthor.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(growable: false);

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

/// A repository whose reads fail the way an offline device's would.
class _OfflineIssuesRepository extends FixtureIssuesRepository {
  @override
  Future<Issue> loadIssue(int projectId, int issueIid) async {
    throw const SocketException('offline');
  }

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) async {
    throw const SocketException('offline');
  }
}

class _FailingWriteRecentlyViewedCache extends RecentlyViewedCache {
  _FailingWriteRecentlyViewedCache({
    required super.database,
    required super.account,
  });

  @override
  Future<bool> putIf(
    RecentlyViewedType type,
    int projectId,
    int itemId,
    String payload, {
    required bool Function(String? existingPayload) shouldReplace,
  }) => Future.error(StateError('cache write failed'));
}
