import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/syntax/gs_syntax_webview.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reloads highlighted content when the widget updates', (
    tester,
  ) async {
    final platform = _TestWebViewPlatform();
    WebViewPlatform.instance = platform;
    final theme = buildAppTheme().extension<GsTheme>()!;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GsSyntaxWebView(
          source: 'const first = 1;',
          languageId: 'dart',
          theme: theme,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => _waitForLoadCount(platform.controller, expected: 1),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GsSyntaxWebView(
          source: 'def second(): pass',
          languageId: 'python',
          theme: theme,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => _waitForLoadCount(platform.controller, expected: 2),
    );

    expect(platform.controller.loadedHtml, hasLength(2));
    expect(platform.controller.loadedHtml.last, contains('def second(): pass'));
    expect(platform.controller.loadedHtml.last, contains('"python"'));
    expect(platform.controller.loadedHtml.last, isNot(contains('const first')));
  });
}

Future<void> _waitForLoadCount(
  _TestPlatformWebViewController controller, {
  required int expected,
}) async {
  for (
    var attempt = 0;
    attempt < 100 && controller.loadedHtml.length < expected;
    attempt++
  ) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _TestWebViewPlatform extends WebViewPlatform {
  late final _TestPlatformWebViewController controller;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    controller = _TestPlatformWebViewController(params);
    return controller;
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _TestPlatformWebViewWidget(params);
}

class _TestPlatformWebViewController extends PlatformWebViewController {
  _TestPlatformWebViewController(super.params) : super.implementation();

  final List<String> loadedHtml = [];

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    loadedHtml.add(html);
  }

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}
}

class _TestPlatformWebViewWidget extends PlatformWebViewWidget {
  _TestPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox();
}
