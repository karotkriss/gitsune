import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/home/home_screen.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/profile/profile_screen.dart';
import 'package:gitsune/features/search/presentation/search_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';
import 'package:gitsune/features/todos/todos_screen.dart';

import '../issues/support/fixture_issues_repository.dart';
import '../search/support/fixture_search_repository.dart';
import '../todos/support/fixture_todos_repository.dart';

/// The regression guard for the home-tile/navigation wiring bug: it walks the
/// assembled router (production `buildAppRouter`) through every bottom tab and
/// every Home tile, asserting each reaches the screen it should - the assertion
/// that was missing when five Home tiles and every Search result silently did
/// nothing.
void main() {
  // Unmount and elapse a frame so a screen that subscribes to a stream
  // (TodosScreen) never ends the test with a pending timer.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every bottom tab reaches its screen', (tester) async {
    final todos = FixtureTodosRepository();
    addTearDown(todos.dispose);
    final router = buildAppRouter(
      todosRepository: todos,
      searchRepository: FixtureSearchRepository(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    // Boots on Home.
    expect(find.byType(HomeScreen), findsOneWidget);

    await tapTab(tester, 'To-Dos');
    expect(find.byType(TodosScreen), findsOneWidget);

    await tapTab(tester, 'Explore');
    expect(find.byType(SearchScreen), findsOneWidget);

    await tapTab(tester, 'Profile');
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tapTab(tester, 'Home');
    expect(find.byType(HomeScreen), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the To-Do tile navigates; the others are disabled, not '
      'dead-tapping', (tester) async {
    final todos = FixtureTodosRepository();
    addTearDown(todos.dispose);
    final router = buildAppRouter(
      todosRepository: todos,
      searchRepository: FixtureSearchRepository(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    InkWell inkWellFor(String label) => tester.widget<InkWell>(
      find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first,
    );

    // The five destination-less tiles take no tap (onTap == null), so they
    // are disabled rather than tapping into nothing.
    for (final label in const [
      'Issues',
      'Merge Requests',
      'Pipelines',
      'Projects',
      'Groups',
    ]) {
      expect(
        inkWellFor(label).onTap,
        isNull,
        reason: '$label must be disabled',
      );
    }

    // The To-Do tile is live and navigates to the To-Dos surface.
    expect(inkWellFor('To-Do List').onTap, isNotNull);
    await tester.tap(find.text('To-Do List'));
    await tester.pumpAndSettle();
    expect(find.byType(TodosScreen), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a Search result opens its detail screen', (tester) async {
    final router = buildAppRouter(
      issuesRepository: FixtureIssuesRepository(),
      searchRepository: FixtureSearchRepository(
        issues: [
          Issue.fromJson(const {
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
          }),
        ],
      ),
      initialLocation: '/explore',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'draft');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep draft comments after reconnecting'));
    await tester.pumpAndSettle();

    expect(find.byType(IssueDetailScreen), findsOneWidget);

    await unmount(tester);
  });
}
