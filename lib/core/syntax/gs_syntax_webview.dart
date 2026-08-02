import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';
import 'gs_syntax_theme.dart';

/// WebView-based full-file syntax highlighter: the fallback
/// `chooseSyntaxEngine` picks for oversized full-file source, driven by the
/// offline highlight.js bundle at `assets/syntax/highlight.min.js` (see
/// `assets/syntax/README.md`). The JS is embedded inline into a generated
/// HTML document at load time, so this never makes a network request.
class GsSyntaxWebView extends StatefulWidget {
  const GsSyntaxWebView({
    super.key,
    required this.source,
    required this.languageId,
    required this.theme,
  });

  final String source;
  final String languageId;
  final GsTheme theme;

  @override
  State<GsSyntaxWebView> createState() => _GsSyntaxWebViewState();
}

class _GsSyntaxWebViewState extends State<GsSyntaxWebView> {
  late final WebViewController _controller;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.theme.codeBg);
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant GsSyntaxWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source == widget.source &&
        oldWidget.languageId == widget.languageId &&
        oldWidget.theme == widget.theme) {
      return;
    }
    if (oldWidget.theme != widget.theme) {
      unawaited(_controller.setBackgroundColor(widget.theme.codeBg));
    }
    unawaited(_load());
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final source = widget.source;
    final languageId = widget.languageId;
    final css = gsSyntaxCss(widget.theme);
    final highlightJsFuture = rootBundle.loadString(
      'assets/syntax/highlight.min.js',
    );
    final fontDataFuture = rootBundle.load('assets/fonts/GitLabMono.ttf');
    final highlightJs = await highlightJsFuture;
    final fontData = await fontDataFuture;
    if (!mounted || generation != _loadGeneration) {
      return;
    }
    final fontBase64 = base64Encode(
      fontData.buffer.asUint8List(
        fontData.offsetInBytes,
        fontData.lengthInBytes,
      ),
    );
    await _controller.loadHtmlString(
      _buildHtml(
        highlightJs: highlightJs,
        fontBase64: fontBase64,
        source: source,
        languageId: languageId,
        css: css,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

String _buildHtml({
  required String highlightJs,
  required String fontBase64,
  required String source,
  required String languageId,
  required String css,
}) =>
    '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
@font-face {
  font-family: 'GitLab Mono';
  src: url(data:font/ttf;base64,$fontBase64) format('truetype');
}
$css</style>
</head>
<body>
<pre><code id="code"></code></pre>
<script>$highlightJs</script>
<script>
var el = document.getElementById('code');
el.textContent = ${_jsString(source)};
el.classList.add('language-' + ${_jsString(languageId)});
hljs.highlightElement(el);
</script>
</body>
</html>
''';

// Encodes [value] as a JS string literal safe to splice into a <script>
// block: JSON-encoding handles quote/backslash/control-char escaping, and
// escaping "</" additionally stops a literal "</script>" inside [value] from
// closing the enclosing script tag early.
String _jsString(String value) => jsonEncode(value).replaceAll('</', r'<\/');
