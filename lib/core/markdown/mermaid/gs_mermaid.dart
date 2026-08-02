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
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _startRender();
  }

  @override
  void didUpdateWidget(covariant GsMermaid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source != oldWidget.source) _startRender();
  }

  void _startRender() {
    final generation = ++_generation;
    _timeoutTimer?.cancel();
    _status = _Status.loading;
    _height = 120;
    _controller = null;
    _timeoutTimer = Timer(_timeout, () => _fail(generation));
    unawaited(_init(generation));
  }

  Future<void> _init(int generation) async {
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.transparent);
      await controller.addJavaScriptChannel(
        'GsMermaid',
        onMessageReceived: (message) => _onMessage(message, generation),
      );
      final navigationDelegate = NavigationDelegate();
      await navigationDelegate.platform.setOnPageFinished(
        (_) => unawaited(_render(controller, generation)),
      );
      await controller.setNavigationDelegate(navigationDelegate);
      if (!_isActive(generation)) return;
      setState(() => _controller = controller);
      await controller.loadFlutterAsset(_asset);
    } on Object {
      _fail(generation);
    }
  }

  Future<void> _render(WebViewController controller, int generation) async {
    if (!_isActive(generation)) return;
    try {
      await controller.runJavaScript(
        'gsRenderMermaid(${jsonEncode(widget.source)})',
      );
    } on Object {
      _fail(generation);
    }
  }

  bool _isActive(int generation) =>
      mounted && generation == _generation && _status == _Status.loading;

  void _fail(int generation) {
    if (!_isActive(generation)) return;
    _timeoutTimer?.cancel();
    setState(() {
      _status = _Status.failed;
      _controller = null;
    });
  }

  void _onMessage(JavaScriptMessage message, int generation) {
    if (!_isActive(generation)) return;
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(message.message) as Map<String, dynamic>;
    } on Object {
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
      _fail(generation);
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
    if (_status == _Status.failed) {
      return gsRawSourceFallback(context, widget.source);
    }
    if (controller == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
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
