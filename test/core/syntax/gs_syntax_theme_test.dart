import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/syntax/gs_syntax_theme.dart';
import 'package:gitsune/core/theme/app_theme.dart';

void main() {
  final gs = buildAppTheme().extension<GsTheme>()!;

  test('a simple scope becomes a single hljs class selector', () {
    expect(gsSyntaxCss(gs), contains('.hljs-keyword {'));
  });

  test('a compound scope becomes a chained class selector', () {
    // highlight.js emits `title.function_` as two DOM classes
    // (`hljs-title` and `function_`), so the CSS selector chains them
    // rather than treating the dot as a literal class-name character.
    expect(gsSyntaxCss(gs), contains('.hljs-title.function_ {'));
  });

  test('comment scopes render italic', () {
    expect(gsSyntaxCss(gs), contains('.hljs-comment { color:'));
    expect(
      RegExp(r'\.hljs-comment \{ color: [^;]+; font-style: italic; \}')
          .hasMatch(gsSyntaxCss(gs)),
      isTrue,
    );
  });
}
