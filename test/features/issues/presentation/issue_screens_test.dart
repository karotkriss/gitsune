import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';
import 'package:gitsune/features/issues/presentation/issue_components.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/issues/presentation/issue_list_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../support/fixture_issues_repository.dart';

void main() {
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
}
