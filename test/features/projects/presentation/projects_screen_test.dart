import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/projects/presentation/projects_screen.dart';
import 'package:gitsune/features/search/data/search_models.dart';

import '../support/fixture_projects_repository.dart';

void main() {
  Widget app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

  testWidgets('lists membership projects with name, description, and '
      'stars', (tester) async {
    final repository = FixtureProjectsRepository();
    await tester.pumpWidget(app(ProjectsScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('gitsune / app'), findsOneWidget);
    expect(find.text('The Gitsune mobile client.'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('gitsune / offline-sync'), findsOneWidget);
  });

  testWidgets('a short first page pulls the next page to fill the '
      'viewport', (tester) async {
    final repository = FixtureProjectsRepository(
      secondPage: [
        const SearchProject(
          id: 21,
          name: 'relay-bridge',
          nameWithNamespace: 'gitsune / relay-bridge',
          description: '',
          starCount: 1,
        ),
      ],
    );
    await tester.pumpWidget(app(ProjectsScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(repository.nextPageLoads, 1);
    expect(find.text('gitsune / relay-bridge'), findsOneWidget);
  });

  testWidgets('tapping a project reports it', (tester) async {
    final repository = FixtureProjectsRepository();
    final tapped = <SearchProject>[];
    await tester.pumpWidget(
      app(ProjectsScreen(repository: repository, onProjectTap: tapped.add)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('gitsune / app'));
    expect(tapped.map((project) => project.id), [7]);
  });

  testWidgets('an empty membership list shows the empty state', (tester) async {
    final repository = FixtureProjectsRepository(firstPage: const []);
    await tester.pumpWidget(app(ProjectsScreen(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('No projects yet.'), findsOneWidget);
    expect(
      find.text('Projects you are a member of appear here.'),
      findsOneWidget,
    );
  });
}
