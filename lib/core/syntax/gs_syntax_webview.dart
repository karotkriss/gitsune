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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.theme.codeBg);
    unawaited(_load());
  }

  Future<void> _load() async {
    final highlightJs = await rootBundle.loadString(
      'assets/syntax/highlight.min.js',
    );
    await _controller.loadHtmlString(
      _buildHtml(
        highlightJs: highlightJs,
        source: widget.source,
        languageId: widget.languageId,
        css: gsSyntaxCss(widget.theme),
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
<style>$css</style>
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
