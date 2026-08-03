import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/search/data/search_models.dart';
import 'package:gitsune/features/search/data/search_repository.dart';
import 'package:gitsune/features/search/presentation/search_screen.dart';

import '../support/fixture_search_repository.dart';

void main() {
  final now = DateTime.utc(2026, 8, 2, 10);

  final project = SearchProject.fromJson(const {
    'id': 7,
    'name': 'app',
    'name_with_namespace': 'gitsune / app',
    'description': 'The Gitsune mobile client.',
    'star_count': 12,
  });

  final issue = Issue.fromJson(const {
    'id': 1420,
    'project_id': 7,
    'iid': 142,
    'title': 'Keep draft comments after reconnecting',
    'state': 'opened',
    'author': {'id': 11, 'username': 'marin', 'name': 'Marin Alvarez'},
    'created_at': '2026-07-30T10:00:00Z',
    'updated_at': '2026-08-02T08:30:00Z',
    'labels': <dynamic>[],
    'assignees': <dynamic>[],
    'user_notes_count': 2,
  });

  final mergeRequest = SearchMergeRequest.fromJson(const {
    'id': 5201,
    'project_id': 7,
    'iid': 88,
    'title': 'Retry offline queue after reconnect',
    'state': 'opened',
    'author': {'id': 11, 'username': 'marin', 'name': 'Marin Alvarez'},
    'created_at': '2026-07-28T09:00:00Z',
    'updated_at': '2026-08-01T14:00:00Z',
    'labels': <dynamic>[],
    'user_notes_count': 4,
  });

  Future<void> pumpSearch(
    WidgetTester tester,
    FixtureSearchRepository repository,
  ) => tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: SearchScreen(repository: repository, now: now),
    ),
  );

  testWidgets('searching shows results grouped by entity type', (tester) async {
    final repository = FixtureSearchRepository(
      projects: [project],
      issues: [issue],
      mergeRequests: [mergeRequest],
    );
    await pumpSearch(tester, repository);

    await tester.enterText(find.byType(TextField), 'offline');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('gitsune / app'), findsOneWidget);
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Keep draft comments after reconnecting'), findsOneWidget);
    expect(find.text('Merge requests'), findsOneWidget);
    expect(find.text('Retry offline queue after reconnect'), findsOneWidget);
    expect(repository.projectSearches, 1);
    expect(repository.issueSearches, 1);
    expect(repository.mergeRequestSearches, 1);
  });

  testWidgets('no matches renders an empty state', (tester) async {
    final repository = FixtureSearchRepository();
    await pumpSearch(tester, repository);

    await tester.enterText(find.byType(TextField), 'doesnotexist');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('No results.'), findsOneWidget);
    expect(find.text('Nothing matched "doesnotexist".'), findsOneWidget);
    expect(find.text('Projects'), findsNothing);
  });

  testWidgets('shows a prompt before any search is submitted', (tester) async {
    final repository = FixtureSearchRepository();
    await pumpSearch(tester, repository);

    expect(find.text('Search Gitsune'), findsOneWidget);
    expect(repository.issueSearches, 0);
  });

  testWidgets('ignores load-more results from an earlier search', (
    tester,
  ) async {
    final stalePage = Completer<SearchPage<SearchProject>>();
    final repository = _OverlappingSearchRepository(
      staleProjectPage: stalePage.future,
      firstProject: project,
    );
    await pumpSearch(tester, repository);

    await tester.enterText(find.byType(TextField), 'first');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'second');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Load more'), findsOneWidget);

    stalePage.complete(
      SearchPage(
        items: [
          SearchProject.fromJson(const {
            'id': 8,
            'name': 'stale',
            'name_with_namespace': 'gitsune / stale',
            'description': 'Result from the earlier query.',
            'star_count': 0,
          }),
        ],
        hasMore: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('gitsune / stale'), findsNothing);
    expect(find.text('Load more'), findsOneWidget);
  });

  testWidgets('ignores load-more errors from an earlier search', (
    tester,
  ) async {
    final stalePage = Completer<SearchPage<SearchProject>>();
    final repository = _OverlappingSearchRepository(
      staleProjectPage: stalePage.future,
      firstProject: project,
    );
    await pumpSearch(tester, repository);

    await tester.enterText(find.byType(TextField), 'first');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'second');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    stalePage.completeError(Exception('stale failure'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load more. Try again'), findsNothing);
    expect(find.text('Load more'), findsOneWidget);
  });
}

class _OverlappingSearchRepository extends FixtureSearchRepository {
  _OverlappingSearchRepository({
    required this.staleProjectPage,
    required this.firstProject,
  });

  final Future<SearchPage<SearchProject>> staleProjectPage;
  final SearchProject firstProject;

  @override
  Future<SearchPage<SearchProject>> loadFirstProjectsPage(String term) async =>
      SearchPage(items: [firstProject], hasMore: true);

  @override
  Future<SearchPage<SearchProject>> loadNextProjectsPage(String term) =>
      staleProjectPage;
}
