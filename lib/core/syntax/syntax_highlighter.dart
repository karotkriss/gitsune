/// The native, per-line syntax-highlighting engine (`re_highlight`).
///
/// [highlightCodeLine] is the single entry point both diff rendering (E7.2,
/// decorating [DiffLine.content] from `lib/core/diff/diff_hunk_parser.dart`)
/// and full-file rendering (E9.2, one call per source line) call into; it has
/// no notion of "diff" or "file", only a line of code and a language id from
/// [detectLanguageId].
library;

import 'package:flutter/painting.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';

import '../diff/diff_hunk_parser.dart';
import 'language_detection.dart';

final Highlight _highlight = Highlight()
  ..registerLanguages(builtinAllLanguages);

/// Which engine renders a full-file source view: [native] is `re_highlight`
/// run per line on the main isolate, [webView] hands the whole file to the
/// bundled offline highlight.js instead. See [chooseSyntaxEngine].
enum SyntaxEngine { native, webView }

/// Full-file source length above which the native per-line path (one
/// `re_highlight` call per line, on the main isolate) gets slow enough that
/// the WebView fallback should render the file instead.
///
/// ponytail: a flat character-count threshold, not a profiled device budget;
/// tighten with real large-file profiling if E9.2 shows jank near this line.
const int kNativeSyntaxCharThreshold = 200 * 1024;

/// Picks the engine a full-file view should use for [source], purely by
/// size. Diffs and ordinary files always use [SyntaxEngine.native]; only a
/// full-file view above [kNativeSyntaxCharThreshold] gets [SyntaxEngine.webView].
SyntaxEngine chooseSyntaxEngine(String source) =>
    source.length > kNativeSyntaxCharThreshold
    ? SyntaxEngine.webView
    : SyntaxEngine.native;

/// Highlights one line of [code] as [languageId] (from [detectLanguageId]),
/// returning a [TextSpan] styled from [theme] (see [gsSyntaxTextTheme]) with
/// [base] as the fallback style for unscoped and unmapped text.
///
/// Used both for a single diff line's content and for each line of a
/// full-file source view split on `\n`.
TextSpan highlightCodeLine(
  String code, {
  required String languageId,
  required TextStyle base,
  required Map<String, TextStyle> theme,
}) {
  if (code.isEmpty) return TextSpan(text: code, style: base);
  final result = _highlight.highlight(code: code, language: languageId);
  final renderer = TextSpanRenderer(base, theme);
  result.render(renderer);
  return renderer.span ?? TextSpan(text: code, style: base);
}

/// [highlightCodeLine] for a [DiffHunk] line: decorates [DiffLine.content]
/// with the same per-line engine a full-file view uses.
TextSpan highlightDiffLine(
  DiffLine line, {
  required String languageId,
  required TextStyle base,
  required Map<String, TextStyle> theme,
}) => highlightCodeLine(
  line.content,
  languageId: languageId,
  base: base,
  theme: theme,
);
