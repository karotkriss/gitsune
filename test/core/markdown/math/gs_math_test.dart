import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/theme/app_theme.dart';

Widget host(String data) => MaterialApp(
  theme: buildAppTheme(),
  home: Scaffold(body: GsMarkdown(data: data)),
);

void main() {
  testWidgets(r'inline math renders as TeX, not the raw $...$ source', (
    tester,
  ) async {
    await tester.pumpWidget(host(r'energy is $E = mc^2$ always'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsOneWidget);
    expect(find.text(r'$E = mc^2$'), findsNothing);
  });

  testWidgets(r'block math renders as TeX, not the raw $$...$$ source', (
    tester,
  ) async {
    await tester.pumpWidget(host('\$\$\nE = mc^2\n\$\$'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsOneWidget);
    expect(find.textContaining('E = mc^2'), findsNothing);
  });

  testWidgets('malformed math degrades to the raw source in a code block', (
    tester,
  ) async {
    const malformed = r'$\frac{1}{$';
    await tester.pumpWidget(host('before $malformed after'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final gs = buildAppTheme().extension<GsTheme>()!;
    final text = tester.widget<Text>(find.text(r'\frac{1}{'));
    expect(text.style?.fontFamily, gs.mono.fontFamily);
  });

  testWidgets(r'an unterminated $$ block preserves following Markdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        r'$$'
        '\nnot math\n\n# Still a heading',
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsNothing);
    final gs = buildAppTheme().extension<GsTheme>()!;
    final delimiter = tester.widget<Text>(find.text(r'$$'));
    expect(delimiter.style?.fontFamily, gs.mono.fontFamily);
    expect(find.text('not math'), findsOneWidget);
    expect(find.text('Still a heading'), findsOneWidget);
  });

  testWidgets(r'an empty $$ block shows its raw delimiters', (tester) async {
    await tester.pumpWidget(
      host(
        r'$$'
        '\n'
        r'$$',
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsNothing);
    final gs = buildAppTheme().extension<GsTheme>()!;
    final delimiters = tester.widget<Text>(
      find.text(
        r'$$'
        '\n'
        r'$$',
      ),
    );
    expect(delimiters.style?.fontFamily, gs.mono.fontFamily);
  });

  testWidgets('currency and whitespace-bound dollars remain plain text', (
    tester,
  ) async {
    const source = r'Costs are $20,000 and $30,000; keep $ x$ and $x $ too.';
    await tester.pumpWidget(host(source));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsNothing);
    expect(find.text(source), findsOneWidget);
  });
}
