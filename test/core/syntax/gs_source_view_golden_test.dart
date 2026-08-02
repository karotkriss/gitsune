import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/syntax/gs_source_view.dart';
import 'package:gitsune/core/theme/app_theme.dart';

/// Highlighted-source golden (dark theme, GitLab Mono): a small Dart file
/// through the native `re_highlight` path, exercising every mapped token
/// (keyword, string, comment, function name, number). Fails on any
/// unintended change to token colors or the highlighting mapping.
void main() {
  testWidgets('highlighted full-file source matches golden', (tester) async {
    const source = '''
class Greeter {
  // who to greet
  final String name;
  const Greeter(this.name);

  String greet() => 'Hello, \$name!';
}

const answer = 42;
''';

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 240,
            child: GsSourceView(source: source, path: 'lib/greeter.dart'),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(GsSourceView),
      matchesGoldenFile('goldens/highlighted_source.png'),
    );
  });
}
