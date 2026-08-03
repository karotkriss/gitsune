import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_changes_screen.dart';

import '../support/fixture_merge_requests_repository.dart';

Widget _screen({
  FixtureMergeRequestsRepository? repository,
  String? webUrl,
  Future<void> Function(Uri url)? openWebUrl,
}) => MaterialApp(
  theme: buildAppTheme(),
  home: MergeRequestChangesScreen(
    projectId: 7,
    projectPath: 'gitsune/app',
    mergeIid: 142,
    repository: repository ?? FixtureMergeRequestsRepository(),
    webUrl: webUrl,
    openWebUrl: openWebUrl,
  ),
);

class _FailingDetailRepository extends FixtureMergeRequestsRepository {
  @override
  Future<MergeRequest> loadMergeRequest(int projectId, int mergeIid) async {
    throw StateError('detail unavailable');
  }
}

void main() {
  testWidgets('jump-to-file scrolls the chosen file into view', (tester) async {
    tester.view.devicePixelRatio = 1;
    // Short enough that the last file sits beyond the list's cache extent
    // until the jump scrolls it into view.
    tester.view.physicalSize = const Size(390, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    expect(find.text('lib/src/instance_switcher.dart'), findsOneWidget);
    // The last file is beyond the lazily built range until the jump.
    expect(find.text('lib/src/legacy_switcher.dart'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('jump-to-file')));
    await tester.pumpAndSettle();
    expect(find.text('lib/src/legacy_switcher.dart'), findsOneWidget);

    await tester.tap(find.text('lib/src/legacy_switcher.dart'));
    await tester.pumpAndSettle();

    expect(find.text('deleted'), findsOneWidget);
    expect(find.text('lib/src/legacy_switcher.dart'), findsOneWidget);
  });

  testWidgets('oversized diff falls back to the web viewer', (tester) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      _screen(
        repository: FixtureMergeRequestsRepository(
          diffFixtures: const ['merge_request_142_diffs_oversized'],
        ),
        openWebUrl: (url) async => opened.add(url),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('diff-web-fallback')), findsOneWidget);
    expect(find.byKey(const ValueKey('jump-to-file')), findsNothing);

    await tester.tap(find.text('Open in browser'));
    await tester.pumpAndSettle();

    // With no webUrl passed in, the screen resolves it from the merge
    // request fixture itself.
    expect(opened, [
      Uri.parse(
        'https://gitlab.example.com/gitsune/app/-/merge_requests/142/diffs',
      ),
    ]);
  });

  testWidgets('normal diff renders without loading merge request details', (
    tester,
  ) async {
    await tester.pumpWidget(_screen(repository: _FailingDetailRepository()));
    await tester.pumpAndSettle();

    expect(find.text('lib/src/instance_switcher.dart'), findsOneWidget);
    expect(find.text('Unable to load these changes.'), findsNothing);
  });
}
