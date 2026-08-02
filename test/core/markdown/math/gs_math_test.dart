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
}
