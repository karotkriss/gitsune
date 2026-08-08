import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../features/releases/support/fixture_releases_repository.dart';

/// E16.2 performance guard: prove the paginated lists build lazily.
///
/// Every paginated list in the app (issues, merge requests, to-dos, search
/// results, releases, repository tree) renders its rows through the same
/// `SliverList.builder` inside a `CustomScrollView`. This harness exercises
/// that shared mechanism through the releases screen with a large synthetic
/// dataset and measures how many row widgets are actually instantiated: a
/// lazy list keeps only the viewport (plus a small cache extent) in the tree,
/// so the count must stay a small constant regardless of dataset size. If a
/// future change swaps a builder for an eager `ListView(children: [...])` or a
/// materialised `Column`, this count would jump to the dataset size and fail.
void main() {
  // A representative phone viewport so the visible-row count is deterministic.
  const dpr = 3.0;
  const logicalSize = Size(390, 844);

  List<ReleaseEntry> generateReleases(int count) => [
    for (var i = 0; i < count; i++)
      ReleaseEntry(
        instanceHost: 'gitlab.example.com',
        accountId: 'alice',
        projectId: 7,
        tagName: 'v$i',
        name: 'Release $i',
        description: '',
        releasedAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: i)),
        authorName: 'Alice',
        assetsJson: jsonEncode(const {}),
        position: i,
      ),
  ];

  Finder rows() => find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey && '${key.value}'.startsWith('release-row-');
  });

  testWidgets('a 500-item list keeps only a viewport window of rows in the '
      'tree, and the window follows the scroll offset', (tester) async {
    tester.view.devicePixelRatio = dpr;
    tester.view.physicalSize = logicalSize * dpr;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    const total = 500;
    final repository = FixtureReleasesRepository(generateReleases(total));
    final router = buildAppRouter(
      releasesRepository: repository,
      initialLocation: '/projects/7/releases?projectPath=acme%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    final builtAtTop = rows().evaluate().length;
    debugPrint('lazy-list: $total releases -> $builtAtTop rows built at top');

    // Lazy: the tree holds a small window, not one row per dataset entry.
    expect(builtAtTop, greaterThan(0));
    expect(
      builtAtTop,
      lessThan(60),
      reason: 'a lazy list builds ~one viewport of rows, not all $total',
    );
    expect(find.byKey(const ValueKey('release-row-v0')), findsOneWidget);
    expect(find.byKey(const ValueKey('release-row-v499')), findsNothing);

    // Scroll to the end: the window must move, not grow. The target row isn't
    // built yet, so the scrollable is named explicitly rather than resolved
    // through the (absent) target's ancestor.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('release-row-v499')),
      1000,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 100,
    );
    await tester.pumpAndSettle();

    final builtAtBottom = rows().evaluate().length;
    debugPrint(
      'lazy-list: $total releases -> $builtAtBottom rows built at '
      'bottom after scroll',
    );

    expect(builtAtBottom, lessThan(60));
    expect(find.byKey(const ValueKey('release-row-v499')), findsOneWidget);
    expect(find.byKey(const ValueKey('release-row-v0')), findsNothing);
  });
}
