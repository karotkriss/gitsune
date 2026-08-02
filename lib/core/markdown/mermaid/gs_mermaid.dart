import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../gs_markdown_fallback.dart';

const _asset = 'assets/vendor/mermaid/mermaid.html';
const _timeout = Duration(seconds: 8);

enum _Status { loading, rendered, failed }

/// Renders a Mermaid diagram offline via a bundled `mermaid.min.js` in a
/// WebView (see `assets/vendor/README.md`).
///
/// Degrades to the raw [source] in a code block, never throwing, when a
/// WebView platform implementation is unavailable, loading times out, or
/// Mermaid itself reports a parse error for a malformed diagram.
class GsMermaid extends StatefulWidget {
  const GsMermaid({super.key, required this.source});

  final String source;

  @override
  State<GsMermaid> createState() => _GsMermaidState();
}

class _GsMermaidState extends State<GsMermaid> {
  _Status _status = _Status.loading;
  double _height = 120;
  WebViewController? _controller;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..addJavaScriptChannel('GsMermaid', onMessageReceived: _onMessage)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) => _controller?.runJavaScript(
              'gsRenderMermaid(${jsonEncode(widget.source)})',
            ),
          ),
        )
        ..loadFlutterAsset(_asset);
      _controller = controller;
      _timeoutTimer = Timer(_timeout, _onTimeout);
    } on Object {
      _status = _Status.failed;
    }
  }

  void _onTimeout() {
    if (mounted && _status == _Status.loading) {
      setState(() => _status = _Status.failed);
    }
  }

  void _onMessage(JavaScriptMessage message) {
    if (!mounted) return;
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(message.message) as Map<String, dynamic>;
    } on FormatException {
      decoded = null;
    }
    _timeoutTimer?.cancel();
    if (decoded != null && decoded['ok'] == true) {
      final height = (decoded['height'] as num?)?.toDouble() ?? _height;
      setState(() {
        _status = _Status.rendered;
        _height = height.clamp(40, 4000);
      });
    } else {
      setState(() => _status = _Status.failed);
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_status == _Status.failed || controller == null) {
      return gsRawSourceFallback(context, widget.source);
    }
    return SizedBox(
      height: _status == _Status.loading ? 120 : _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          WebViewWidget(controller: controller),
          if (_status == _Status.loading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
