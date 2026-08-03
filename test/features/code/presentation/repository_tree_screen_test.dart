import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../support/fixture_repository_tree_repository.dart';

void main() {
  testWidgets('the tree drills down one directory level per screen and the '
      'breadcrumb jumps back up', (tester) async {
    final repository = FixtureRepositoryTreeRepository();
    final router = buildAppRouter(
      repositoryTreeRepository: repository,
      initialLocation: '/projects/7/tree?projectPath=gitsune%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    // The root level lists only its own entries, directories first.
    expect(find.text('android'), findsOneWidget);
    expect(find.text('README.md'), findsOneWidget);
    expect(find.text('main.dart'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('tree-entry-lib')));
    await tester.pumpAndSettle();

    expect(find.text('main.dart'), findsOneWidget);
    expect(find.text('README.md'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('tree-entry-lib/core')));
    await tester.pumpAndSettle();

    expect(find.text('app_theme.dart'), findsOneWidget);

    // One breadcrumb level up: app / lib / core -> lib.
    await tester.tap(find.text('lib'));
    await tester.pumpAndSettle();

    expect(find.text('main.dart'), findsOneWidget);
    expect(find.text('app_theme.dart'), findsNothing);

    // Straight to the root across two levels.
    await tester.tap(find.byKey(const ValueKey('tree-entry-lib/core')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('app'));
    await tester.pumpAndSettle();

    expect(find.text('android'), findsOneWidget);
    expect(find.text('main.dart'), findsNothing);

    // Each visited directory was refreshed exactly when first shown.
    expect(repository.refreshedPaths, ['', 'lib', 'lib/core', 'lib/core']);
  });

  testWidgets('tapping a file stays on the directory listing', (tester) async {
    final repository = FixtureRepositoryTreeRepository();
    final router = buildAppRouter(
      repositoryTreeRepository: repository,
      initialLocation: '/projects/7/tree?projectPath=gitsune%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tree-entry-README.md')));
    await tester.pumpAndSettle();

    expect(find.text('android'), findsOneWidget);
    expect(repository.refreshedPaths, ['']);
  });

  testWidgets('a direct nested route breadcrumb navigates to its ancestor', (
    tester,
  ) async {
    final repository = FixtureRepositoryTreeRepository();
    final router = buildAppRouter(
      repositoryTreeRepository: repository,
      initialLocation:
          '/projects/7/tree?projectPath=gitsune%2Fapp&ref=main&path=lib%2Fcore',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('app_theme.dart'), findsOneWidget);

    await tester.tap(find.text('lib'));
    await tester.pumpAndSettle();

    expect(find.text('main.dart'), findsOneWidget);

    await tester.tap(find.text('app'));
    await tester.pumpAndSettle();

    expect(find.text('android'), findsOneWidget);
    expect(repository.refreshedPaths, ['lib/core', 'lib', '']);
    expect(repository.refreshedRefs, ['main', 'main', 'main']);
  });

  testWidgets('an unknown directory shows the empty state', (tester) async {
    final repository = FixtureRepositoryTreeRepository();
    final router = buildAppRouter(
      repositoryTreeRepository: repository,
      initialLocation:
          '/projects/7/tree?projectPath=gitsune%2Fapp&path=empty_dir',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('This directory is empty.'), findsOneWidget);
  });
}
