import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/markdown/mermaid/gs_mermaid.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

Widget host(String data) => MaterialApp(
  theme: buildAppTheme(),
  home: Scaffold(body: GsMarkdown(data: data)),
);

Widget mermaidHost(String source) => MaterialApp(
  theme: buildAppTheme(),
  home: Scaffold(body: GsMermaid(source: source)),
);

const _diagram = 'graph TD;\nA-->B;';

void main() {
  testWidgets('a mermaid block degrades to the raw source when rendering is '
      'unavailable, without throwing', (tester) async {
    await tester.pumpWidget(host('```mermaid\n$_diagram\n```'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final gs = buildAppTheme().extension<GsTheme>()!;
    final text = tester.widget<Text>(find.text(_diagram));
    expect(text.style?.fontFamily, gs.mono.fontFamily);
  });

  testWidgets('an ordinary fenced code block still renders as plain code', (
    tester,
  ) async {
    await tester.pumpWidget(host('```dart\nfinal x = 1;\n```'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('final x = 1;'), findsOneWidget);
  });

  testWidgets('a Mermaid fence closes only with a matching long-enough run', (
    tester,
  ) async {
    const source = '''````mermaid
graph TD;
A-->B;
~~~
after tilde
```
after short backticks
````
outside''';

    await tester.pumpWidget(host(source));
    await tester.pump();

    expect(
      find.text(
        'graph TD;\nA-->B;\n~~~\nafter tilde\n```\nafter short backticks',
      ),
      findsOneWidget,
    );
    expect(find.text('outside'), findsOneWidget);
  });

  testWidgets('asynchronous WebView setup failures show the fallback', (
    tester,
  ) async {
    WebViewPlatform.instance = _TestWebViewPlatform(failSetup: true);

    await tester.pumpWidget(mermaidHost(_diagram));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(_diagram), findsOneWidget);
  });

  testWidgets('renders the new source when a retained widget updates', (
    tester,
  ) async {
    final platform = _TestWebViewPlatform();
    WebViewPlatform.instance = platform;

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GsMermaid(source: 'graph TD;\nfirst-->node;'),
      ),
    );
    await tester.runAsync(() => _waitUntil(() => platform.scripts.length == 1));

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GsMermaid(source: 'graph LR;\nsecond-->node;'),
      ),
    );
    await tester.runAsync(() => _waitUntil(() => platform.scripts.length == 2));

    expect(platform.controllers, hasLength(2));
    expect(platform.scripts.last, contains(r'graph LR;\nsecond-->node;'));
    expect(platform.scripts.last, isNot(contains('first')));
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 100 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _TestWebViewPlatform extends WebViewPlatform {
  _TestWebViewPlatform({this.failSetup = false});

  final bool failSetup;
  final List<_TestPlatformWebViewController> controllers = [];

  List<String> get scripts => [
    for (final controller in controllers) ...controller.scripts,
  ];

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = _TestPlatformWebViewController(
      params,
      failSetup: failSetup,
    );
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _TestPlatformNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _TestPlatformWebViewWidget(params);
}

class _TestPlatformWebViewController extends PlatformWebViewController {
  _TestPlatformWebViewController(super.params, {required this.failSetup})
    : super.implementation();

  final bool failSetup;
  final List<String> scripts = [];
  _TestPlatformNavigationDelegate? navigationDelegate;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    if (failSetup) throw StateError('setup failed');
  }

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    navigationDelegate = handler as _TestPlatformNavigationDelegate;
  }

  @override
  Future<void> loadFlutterAsset(String key) async {
    navigationDelegate?.onPageFinished?.call(key);
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    scripts.add(javaScript);
  }
}

class _TestPlatformNavigationDelegate extends PlatformNavigationDelegate {
  _TestPlatformNavigationDelegate(super.params) : super.implementation();

  PageEventCallback? onPageFinished;

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    this.onPageFinished = onPageFinished;
  }
}

class _TestPlatformWebViewWidget extends PlatformWebViewWidget {
  _TestPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox();
}
