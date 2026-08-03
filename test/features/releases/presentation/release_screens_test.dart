import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../support/fixture_releases_repository.dart';

void main() {
  Future<FixtureReleasesRepository> pumpReleases(
    WidgetTester tester, {
    String initialLocation = '/projects/7/releases?projectPath=acme%2Fapp',
  }) async {
    final repository = FixtureReleasesRepository();
    final router = buildAppRouter(
      releasesRepository: repository,
      initialLocation: initialLocation,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('the list shows every cached release, newest first, and '
      'refreshes the project on open', (tester) async {
    final repository = await pumpReleases(tester);

    expect(find.text('Releases'), findsOneWidget);
    expect(find.text('acme/app'), findsOneWidget);
    expect(find.text('Version 1.2.0'), findsOneWidget);
    // The unnamed release falls back to its tag.
    expect(find.text('v1.1.0'), findsOneWidget);
    expect(find.text('First stable release'), findsOneWidget);
    expect(
      find.textContaining('Jun 2, 2026', findRichText: true),
      findsOneWidget,
    );

    final firstRow = tester.getTopLeft(find.text('Version 1.2.0'));
    final lastRow = tester.getTopLeft(find.text('First stable release'));
    expect(firstRow.dy, lessThan(lastRow.dy));

    expect(repository.refreshedProjectIds, [7]);
  });

  testWidgets('tapping a release opens its detail with the notes rendered '
      'as markdown and the asset links listed', (tester) async {
    await pumpReleases(tester);

    await tester.tap(find.byKey(const ValueKey('release-row-v1.2.0')));
    await tester.pumpAndSettle();

    expect(find.text('Release'), findsOneWidget);
    expect(find.text('Version 1.2.0'), findsOneWidget);
    expect(find.text('v1.2.0'), findsOneWidget);
    expect(find.text('Jun 2, 2026'), findsOneWidget);
    expect(find.text('by Alice Doe'), findsOneWidget);

    // The markdown notes render as rich text: the raw `##` heading marker is
    // gone and the bold run's content is present.
    expect(find.byType(GsMarkdown), findsOneWidget);
    expect(find.text('Highlights', findRichText: true), findsOneWidget);
    expect(find.textContaining('##'), findsNothing);
    expect(
      find.textContaining('twice as fast', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('**twice as fast**', findRichText: true),
      findsNothing,
    );

    expect(find.text('Assets'), findsOneWidget);
    expect(find.text('Android APK'), findsOneWidget);
    expect(find.text('Source code (zip)'), findsOneWidget);
    expect(find.text('Source code (tar.gz)'), findsOneWidget);
  });

  testWidgets('a release without notes says so instead of rendering empty '
      'markdown', (tester) async {
    await pumpReleases(tester);

    await tester.tap(find.byKey(const ValueKey('release-row-v1.1.0')));
    await tester.pumpAndSettle();

    expect(find.text('No release notes.'), findsOneWidget);
    expect(find.byType(GsMarkdown), findsNothing);
  });

  testWidgets('a deep link to an unknown tag reports the release as not '
      'found', (tester) async {
    await pumpReleases(
      tester,
      initialLocation:
          '/projects/7/releases/detail?projectPath=acme%2Fapp&tag=v9.9.9',
    );

    expect(find.text('Release not found.'), findsOneWidget);
  });
}
