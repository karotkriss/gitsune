import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/diff/diff_file.dart';
import 'package:gitsune/core/diff/gs_diff_view.dart';
import 'package:gitsune/core/theme/app_theme.dart';

import '../../support/fixtures.dart';

List<DiffFile> _filesFrom(String fixture) => (Fixtures.json(fixture) as List)
    .map((value) => DiffFile.fromJson(Map<String, dynamic>.from(value as Map)))
    .toList(growable: false);

Widget _app(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  home: Scaffold(body: child),
);

/// Every leaf [TextSpan] under the rendered diff, flattened.
List<TextSpan> _spans(WidgetTester tester) {
  final spans = <TextSpan>[];
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    richText.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
  }
  return spans;
}

void main() {
  testWidgets('renders add/remove/context styling and syntax highlighting', (
    tester,
  ) async {
    final files = _filesFrom('merge_request_142_diffs_page1');
    final gs = buildAppTheme().extension<GsTheme>()!;

    await tester.pumpWidget(
      _app(GsDiffView(files: files, onOpenInBrowser: () {})),
    );

    // Line backgrounds from the --gs-diff-* tokens.
    final rowColors = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .map((box) => box.color)
        .toSet();
    expect(rowColors, contains(gs.diffAddBg));
    expect(rowColors, contains(gs.diffDelBg));
    expect(rowColors, contains(gs.codeBg));

    // Per-line syntax highlighting from the --gs-code-* tokens.
    final spans = _spans(tester);
    TextSpan spanWith(String text) => spans.firstWhere(
      (span) => span.text!.contains(text),
      orElse: () => fail('no span containing "$text"'),
    );
    expect(spanWith('class').style?.color, gs.codeKeyword);
    expect(spanWith("'gitlab.com'").style?.color, gs.codeString);
    // The engine splits the comment into word-wise leaf spans, so match a
    // substring that stays within one leaf.
    expect(spanWith('Instance switcher entry').style?.color, gs.codeComment);
    expect(spanWith('42').style?.color, gs.codeNumber);
    expect(spanWith('InstanceSwitcher').style?.color, gs.codeFunction);

    // Context lines keep the default mono text color.
    expect(spanWith('Welcome.').style?.color, gs.textDefault);

    // File headers and change-kind chips.
    expect(find.text('lib/src/instance_switcher.dart'), findsOneWidget);
    expect(find.text('docs/README.md -> README.md'), findsOneWidget);
    expect(find.text('renamed'), findsOneWidget);
    expect(find.byKey(const ValueKey('diff-web-fallback')), findsNothing);
  });

  testWidgets('oversized diff shows the web fallback instead of rendering', (
    tester,
  ) async {
    final files = _filesFrom('merge_request_142_diffs_oversized');
    var opened = 0;

    await tester.pumpWidget(
      _app(GsDiffView(files: files, onOpenInBrowser: () => opened++)),
    );

    expect(find.byKey(const ValueKey('diff-web-fallback')), findsOneWidget);
    expect(find.text('This diff is too large to view here.'), findsOneWidget);
    expect(find.text('lib/generated/part_000.dart'), findsNothing);

    await tester.tap(find.text('Open in browser'));
    expect(opened, 1);
  });

  testWidgets('suppressed diff shows the web fallback instead of empty files', (
    tester,
  ) async {
    final files = _filesFrom('merge_request_142_diffs_suppressed');

    await tester.pumpWidget(
      _app(GsDiffView(files: files, onOpenInBrowser: () {})),
    );

    expect(find.byKey(const ValueKey('diff-web-fallback')), findsOneWidget);
    expect(find.text('lib/generated/large.dart'), findsNothing);
    expect(find.text('lib/generated/collapsed.dart'), findsNothing);
  });

  testWidgets('large single-file diff builds only visible row chunks', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 500);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final source = _filesFrom('merge_request_142_diffs_page1').first;
    final hunk = source.hunks.first;
    final largeFile = DiffFile(
      oldPath: source.oldPath,
      newPath: source.newPath,
      newFile: source.newFile,
      renamedFile: source.renamedFile,
      deletedFile: source.deletedFile,
      hunks: List.filled(maxInAppDiffLines ~/ hunk.lines.length, hunk),
    );

    await tester.pumpWidget(
      _app(GsDiffView(files: [largeFile], onOpenInBrowser: () {})),
    );

    expect(largeFile.lineCount, greaterThan(4000));
    expect(largeFile.lineCount, lessThanOrEqualTo(maxInAppDiffLines));
    expect(find.byType(RichText).evaluate().length, lessThan(200));
  });

  testWidgets('scaled horizontal position stays synchronized across chunks', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(160, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final source = _filesFrom('merge_request_142_diffs_page1').first;
    final file = DiffFile(
      oldPath: source.oldPath,
      newPath: source.newPath,
      newFile: source.newFile,
      renamedFile: source.renamedFile,
      deletedFile: source.deletedFile,
      hunks: List.filled(8, source.hunks.first),
    );

    await tester.pumpWidget(
      _app(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: GsDiffView(files: [file], onOpenInBrowser: () {}),
        ),
      ),
    );

    final firstFinder = find.byKey(const ValueKey('diff-horizontal-0-0'));
    final secondFinder = find.byKey(const ValueKey('diff-horizontal-0-1'));
    expect(firstFinder, findsOneWidget);
    expect(secondFinder, findsOneWidget);

    await tester.drag(firstFinder, const Offset(-80, 0));
    await tester.pump();

    final first = tester.widget<SingleChildScrollView>(firstFinder);
    final second = tester.widget<SingleChildScrollView>(secondFinder);
    expect(first.controller!.offset, greaterThan(0));
    expect(second.controller!.offset, first.controller!.offset);
  });
}
