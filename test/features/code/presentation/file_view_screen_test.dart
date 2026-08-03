import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/syntax/syntax_highlighter.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/code/presentation/file_view_screen.dart';

import '../support/fixture_repository_tree_repository.dart';

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

/// Every leaf [TextSpan] under the rendered screen, flattened.
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
  testWidgets('renders the file in GitLab Mono with line numbers and syntax '
      'highlighting', (tester) async {
    final gs = buildAppTheme().extension<GsTheme>()!;
    await tester.pumpWidget(
      _app(
        FileViewScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          filePath: 'lib/core/app_theme.dart',
          repository: FixtureRepositoryTreeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // One gutter number per line: the fixture file has 9 lines (its
    // trailing newline terminates the last line rather than adding a tenth).
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('10'), findsNothing);

    final spans = _spans(tester);
    TextSpan spanWith(String text) => spans.firstWhere(
      (span) => span.text!.contains(text),
      orElse: () => fail('no span containing "$text"'),
    );
    expect(spanWith('class').style?.color, gs.codeKeyword);
    expect(spanWith("'Hello, ").style?.color, gs.codeString);
    expect(spanWith('deliberately long comment').style?.color, gs.codeComment);
    expect(spanWith('42').style?.color, gs.codeNumber);
    expect(spanWith('Greeter').style?.color, gs.codeFunction);
    // Scoped spans carry only their token color and inherit the rest, so
    // GitLab Mono is asserted on a base-styled span and the gutter.
    expect(spanWith('greet').style?.fontFamily, gs.mono.fontFamily);
    expect(
      tester.widget<Text>(find.text('1')).style?.fontFamily,
      gs.mono.fontFamily,
    );
  });

  testWidgets('the wrap toggle switches between the horizontal viewport and '
      'soft-wrapped lines', (tester) async {
    await tester.pumpWidget(
      _app(
        FileViewScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          filePath: 'lib/core/app_theme.dart',
          repository: FixtureRepositoryTreeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Wrap is off by default: unbroken lines pan in a horizontal viewport
    // wider than the screen.
    final horizontalScroll = find.byKey(
      const ValueKey('file-horizontal-scroll'),
    );
    expect(horizontalScroll, findsOneWidget);
    final unwrappedWidth = tester
        .getSize(
          find.descendant(
            of: horizontalScroll,
            matching: find.byType(SizedBox).first,
          ),
        )
        .width;
    expect(
      unwrappedWidth,
      greaterThan(tester.getSize(find.byType(Scaffold)).width),
    );

    await tester.tap(find.byKey(const ValueKey('file-wrap-toggle')));
    await tester.pumpAndSettle();

    // Wrap on: no horizontal viewport, the long comment line spans multiple
    // text lines instead.
    expect(horizontalScroll, findsNothing);
    final wrappedLine = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('deliberately long'),
    );
    final shortLine = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('const answer'),
    );
    expect(
      tester.getSize(wrappedLine).height,
      greaterThan(tester.getSize(shortLine).height * 1.5),
    );

    await tester.tap(find.byKey(const ValueKey('file-wrap-toggle')));
    await tester.pumpAndSettle();
    expect(horizontalScroll, findsOneWidget);
  });

  testWidgets('an oversized file offers the web fallback instead of '
      'rendering', (tester) async {
    final openedUrls = <Uri>[];
    final repository = FixtureRepositoryTreeRepository(fixtureTree(), {
      'data/huge.json': 'x' * (kNativeSyntaxCharThreshold + 1),
    });
    await tester.pumpWidget(
      _app(
        FileViewScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          filePath: 'data/huge.json',
          ref: 'main',
          repository: repository,
          openWebUrl: (url) async => openedUrls.add(url),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('file-web-fallback')), findsOneWidget);
    expect(find.byKey(const ValueKey('file-wrap-toggle')), findsNothing);

    await tester.tap(find.text('Open in browser'));
    await tester.pumpAndSettle();

    expect(openedUrls, [
      Uri.parse(
        'https://gitlab.example.com/gitsune/app/-/blob/main/data/huge.json',
      ),
    ]);
  });

  testWidgets('a failed load shows the error state and retry reloads', (
    tester,
  ) async {
    final repository = FixtureRepositoryTreeRepository(fixtureTree(), {});
    await tester.pumpWidget(
      _app(
        FileViewScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          filePath: 'README.md',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load this file.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repository.loadedFilePaths, ['README.md', 'README.md']);
  });
}
