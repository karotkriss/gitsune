import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/theme/app_theme.dart';

Widget host(String data) => MaterialApp(
  theme: buildAppTheme(),
  home: Scaffold(body: GsMarkdown(data: data)),
);

const _diagram = 'graph TD;\nA-->B;';

void main() {
  testWidgets(
    'a mermaid block degrades to the raw source when rendering is '
    'unavailable, without throwing',
    (tester) async {
      await tester.pumpWidget(host('```mermaid\n$_diagram\n```'));
      await tester.pump();

      expect(tester.takeException(), isNull);
      final gs = buildAppTheme().extension<GsTheme>()!;
      final text = tester.widget<Text>(find.text(_diagram));
      expect(text.style?.fontFamily, gs.mono.fontFamily);
    },
  );

  testWidgets('an ordinary fenced code block still renders as plain code', (
    tester,
  ) async {
    await tester.pumpWidget(host('```dart\nfinal x = 1;\n```'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('final x = 1;'), findsOneWidget);
  });
}
