import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/diff/diff_hunk_parser.dart';
import 'package:gitsune/core/syntax/gs_syntax_theme.dart';
import 'package:gitsune/core/syntax/language_detection.dart';
import 'package:gitsune/core/syntax/syntax_highlighter.dart';
import 'package:gitsune/core/theme/app_theme.dart';

void main() {
  final gs = buildAppTheme().extension<GsTheme>()!;
  final base = gs.mono.copyWith(color: gs.textDefault);
  final theme = gsSyntaxTextTheme(gs);

  test('highlighting never loses or reorders characters', () {
    const code = "final greeting = 'Hello, \$name!'; // 42";
    final span = highlightCodeLine(
      code,
      languageId: 'dart',
      base: base,
      theme: theme,
    );
    expect(span.toPlainText(), code);
  });

  test('a keyword is colored with the keyword token', () {
    final span = highlightCodeLine(
      'final x = 1;',
      languageId: 'dart',
      base: base,
      theme: theme,
    );
    final keyword = _findSpanWithText(span, 'final');
    expect(keyword, isNotNull);
    expect((keyword!.style as TextStyle).color, gs.codeKeyword);
  });

  test('a comment is colored with the comment token and italicized', () {
    final span = highlightCodeLine(
      '// a note',
      languageId: 'dart',
      base: base,
      theme: theme,
    );
    final comment = _findSpanWithText(span, '// a note');
    expect(comment, isNotNull);
    expect((comment!.style as TextStyle).color, gs.codeComment);
    expect((comment.style as TextStyle).fontStyle, FontStyle.italic);
  });

  test('an unrecognized language falls back to plain, lossless text', () {
    const code = 'whatever this is, keyword class def';
    final span = highlightCodeLine(
      code,
      languageId: plainTextLanguageId,
      base: base,
      theme: theme,
    );
    expect(span.toPlainText(), code);
  });

  test('empty line highlights to an empty span', () {
    final span = highlightCodeLine(
      '',
      languageId: 'dart',
      base: base,
      theme: theme,
    );
    expect(span.toPlainText(), isEmpty);
  });

  test('highlightDiffLine decorates a DiffLine.content losslessly', () {
    const line = DiffLine(
      type: DiffLineType.addition,
      content: "final answer = 42;",
      newLineNumber: 3,
    );
    final span = highlightDiffLine(
      line,
      languageId: 'dart',
      base: base,
      theme: theme,
    );
    expect(span.toPlainText(), line.content);
    final number = _findSpanWithText(span, '42');
    expect(number, isNotNull);
    expect((number!.style as TextStyle).color, gs.codeNumber);
  });

  test('chooseSyntaxEngine stays native at and under the threshold', () {
    final atThreshold = 'a' * kNativeSyntaxCharThreshold;
    expect(chooseSyntaxEngine(atThreshold), SyntaxEngine.native);
  });

  test('chooseSyntaxEngine falls back to webView past the threshold', () {
    final overThreshold = 'a' * (kNativeSyntaxCharThreshold + 1);
    expect(chooseSyntaxEngine(overThreshold), SyntaxEngine.webView);
  });
}

/// Depth-first search for the first leaf [TextSpan] whose own text matches
/// [text], since `re_highlight` nests matched tokens as child spans.
TextSpan? _findSpanWithText(TextSpan span, String text) {
  if (span.text == text) return span;
  for (final child in span.children ?? const <InlineSpan>[]) {
    if (child is TextSpan) {
      final found = _findSpanWithText(child, text);
      if (found != null) return found;
    }
  }
  return null;
}
