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

  testWidgets('inline discussions render on their diff lines', (tester) async {
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    // The unresolved thread anchors directly beneath its added line.
    final line = find.textContaining('maxInstances');
    final thread = find.byKey(const ValueKey('diff-thread-$_threadId'));
    expect(thread, findsOneWidget);
    expect(find.text('Mira Chen · 2 comments'), findsOneWidget);
    final lineRow = find
        .ancestor(
          of: line,
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == 20,
          ),
        )
        .first;
    expect(
      tester.getTopLeft(thread).dy,
      moreOrLessEquals(tester.getBottomLeft(lineRow).dy),
    );

    // The resolved thread anchors to its deleted line's old-side position.
    final resolvedThread = find.byKey(
      const ValueKey('diff-thread-$_resolvedThreadId'),
    );
    expect(resolvedThread, findsOneWidget);
    expect(
      find.descendant(of: resolvedThread, matching: find.text('Resolved')),
      findsOneWidget,
    );

    // A plain note without a diff position renders no inline row.
    expect(
      find.byKey(
        const ValueKey(
          'diff-thread-8a7c4b5d6e3f2a1b0c9d8e7f6a5b4c3d2e1f0a9b',
        ),
      ),
      findsNothing,
    );
    expect(find.text('1 unresolved thread'), findsOneWidget);
  });

  testWidgets('posting an inline comment adds its thread to the diff', (
    tester,
  ) async {
    final repository = FixtureMergeRequestsRepository();
    await tester.pumpWidget(_screen(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("host = 'gitlab.com'"));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('inline-comment-field')),
      'Prefer reading the host from settings.',
    );
    await tester.tap(find.byKey(const ValueKey('inline-comment-submit')));
    await tester.pumpAndSettle();

    expect(
      repository.lastCreatedBody,
      'Prefer reading the host from settings.',
    );
    final position = repository.lastCreatedPosition!;
    expect(position.newPath, 'lib/src/instance_switcher.dart');
    expect(position.newLine, 17);
    expect(position.oldLine, isNull);
    // The diff refs come from the merge request detail fixture.
    expect(position.headSha, '43cb52c9e1d2b1e4a08b5d3adf1b2c94f0e2a97b');
    expect(position.baseSha, 'd5c30fd1e3ee65a4966b8f6f27f65576e9c1bd85');

    // The created discussion folds into the diff without a refetch.
    expect(
      find.byKey(
        const ValueKey(
          'diff-thread-9b8d5c6e7f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('2 unresolved threads'), findsOneWidget);
  });

  testWidgets('resolving a thread flips its resolved state inline', (
    tester,
  ) async {
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('diff-thread-$_threadId')));
    await tester.pumpAndSettle();

    // The thread sheet renders both notes with markdown bodies.
    expect(
      find.textContaining('configurable', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Ade Ogunleye'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('toggle-resolved')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('toggle-resolved')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('diff-thread-$_threadId')),
        matching: find.text('Resolved'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('unresolved-threads')), findsNothing);
  });
}

const _threadId = '6d5a2f3b4c1e9a8b7f6e5d4c3b2a1f0e9d8c7b6a';
const _resolvedThreadId = '7e6b3a4c5d2f0b9c8a7f6e5d4c3b2a1f0e9d8c7b';
