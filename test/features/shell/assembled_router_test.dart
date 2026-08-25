import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/home/home_screen.dart';
import 'package:gitsune/features/home/home_tiles.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/issues/presentation/issue_list_screen.dart';
import 'package:gitsune/features/profile/profile_screen.dart';
import 'package:gitsune/features/search/presentation/search_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';
import 'package:gitsune/features/todos/todos_screen.dart';

import '../issues/support/fixture_issues_repository.dart';
import '../my_work/support/fixture_my_work_repository.dart';
import '../projects/support/fixture_projects_repository.dart';
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

  InkWell inkWellFor(WidgetTester tester, String label) =>
      tester.widget<InkWell>(
        find
            .ancestor(of: find.text(label), matching: find.byType(InkWell))
            .first,
      );

  testWidgets('with nothing wired, only the To-Do tile is live; the others '
      'are disabled, not dead-tapping', (tester) async {
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

    // The destination-less tiles take no tap (onTap == null), so they are
    // disabled rather than tapping into nothing.
    for (final label in const [
      'Issues',
      'Merge Requests',
      'Pipelines',
      'Projects',
      'Groups',
    ]) {
      expect(
        inkWellFor(tester, label).onTap,
        isNull,
        reason: '$label must be disabled',
      );
    }

    // The To-Do tile is live and navigates to the To-Dos surface.
    expect(inkWellFor(tester, 'To-Do List').onTap, isNotNull);
    await tester.tap(find.text('To-Do List'));
    await tester.pumpAndSettle();
    expect(find.byType(TodosScreen), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('every Home tile either reaches its destination screen or is '
      'disabled - a live tile that navigates nowhere cannot ship', (
    tester,
  ) async {
    final todos = FixtureTodosRepository();
    addTearDown(todos.dispose);
    final router = buildAppRouter(
      todosRepository: todos,
      searchRepository: FixtureSearchRepository(),
      issuesRepository: FixtureIssuesRepository(),
      myWorkRepository: FixtureMyWorkRepository(),
      projectsRepository: FixtureProjectsRepository(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    // Each live tile must land on a screen that is not Home; each remaining
    // tile must be disabled. Add every new tile here as its surface lands.
    const destinations = <String, String?>{
      'Issues': 'My Issues',
      'Merge Requests': 'My Merge Requests',
      'To-Do List': null, // asserted via TodosScreen below
      'Projects': 'Projects',
      'Pipelines': null,
      'Groups': null,
    };
    const disabled = {'Pipelines', 'Groups'};
    for (final tile in HomeTile.values) {
      expect(
        destinations.containsKey(tile.label),
        isTrue,
        reason:
            '${tile.label} is not covered by this guard; give the new tile '
            'a destination (or explicitly disable it) and add it here',
      );
    }

    for (final MapEntry(key: label, value: title) in destinations.entries) {
      if (disabled.contains(label)) {
        expect(
          inkWellFor(tester, label).onTap,
          isNull,
          reason: '$label has no destination and must be disabled',
        );
        continue;
      }
      expect(
        inkWellFor(tester, label).onTap,
        isNotNull,
        reason: '$label must be live',
      );
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        find.byType(HomeScreen),
        findsNothing,
        reason: '$label must navigate away from Home',
      );
      if (title != null) {
        expect(find.text(title), findsOneWidget);
        await tester.pageBack();
      } else {
        expect(find.byType(TodosScreen), findsOneWidget);
        // The To-Do tile switches tabs rather than pushing, so return home
        // through the navigation bar.
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Home'),
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    }

    await unmount(tester);
  });

  testWidgets('a My Issues row deep-links into the issue detail screen', (
    tester,
  ) async {
    final router = buildAppRouter(
      issuesRepository: FixtureIssuesRepository(),
      myWorkRepository: FixtureMyWorkRepository(),
      initialLocation: '/my/issues',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep draft comments after reconnecting'));
    await tester.pumpAndSettle();

    expect(find.byType(IssueDetailScreen), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a Projects row opens that project\'s issue list', (
    tester,
  ) async {
    final router = buildAppRouter(
      issuesRepository: FixtureIssuesRepository(),
      projectsRepository: FixtureProjectsRepository(),
      initialLocation: '/projects',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('gitsune / app'));
    await tester.pumpAndSettle();

    expect(find.byType(IssueListScreen), findsOneWidget);
    expect(find.text('gitsune / app'), findsOneWidget);

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
