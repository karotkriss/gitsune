import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'gs_syntax_theme.dart';
import 'gs_syntax_webview.dart';
import 'language_detection.dart';
import 'syntax_highlighter.dart';

/// Highlighted full-file source, themed from the token layer.
///
/// The public surface a screen calls: [chooseSyntaxEngine] picks the engine
/// from [source]'s size, so a caller never chooses between the native and
/// WebView paths itself. Below the threshold this renders each line with the
/// native `re_highlight` engine ([highlightCodeLine]); above it, this hands
/// the whole file to the offline WebView highlighter ([GsSyntaxWebView]).
/// Line numbers and a wrap toggle belong to the file-view screen (E9.2), not
/// here.
class GsSourceView extends StatelessWidget {
  const GsSourceView({super.key, required this.source, required this.path});

  /// The full file content to highlight.
  final String source;

  /// The file's path (or bare filename), used for language detection.
  final String path;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final languageId = detectLanguageId(path);

    if (chooseSyntaxEngine(source) == SyntaxEngine.webView) {
      return GsSyntaxWebView(
        source: source,
        languageId: languageId,
        theme: gs,
      );
    }

    final base = gs.mono.copyWith(color: gs.textDefault);
    final theme = gsSyntaxTextTheme(gs);
    final lines = source.split('\n');
    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) => Text.rich(
        highlightCodeLine(
          lines[index],
          languageId: languageId,
          base: base,
          theme: theme,
        ),
      ),
    );
  }
}
