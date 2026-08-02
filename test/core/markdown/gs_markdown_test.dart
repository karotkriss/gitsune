import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/markdown/gitlab_references.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/theme/app_theme.dart';

Widget host(String data, {ValueChanged<GitLabReference>? onReferenceTap, ValueChanged<Uri>? onLinkTap}) =>
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: GsMarkdown(
          data: data,
          onReferenceTap: onReferenceTap,
          onLinkTap: onLinkTap,
        ),
      ),
    );

void main() {
  testWidgets('tapping a reference invokes onReferenceTap with the typed reference', (tester) async {
    GitLabReference? tapped;
    await tester.pumpWidget(
      host('Fixes #123 for @dev', onReferenceTap: (ref) => tapped = ref),
    );
    await tester.tapOnText(find.textRange.ofSubstring('#123'));
    expect(tapped, const GitLabReference(GitLabReferenceType.issue, '123'));

    await tester.tapOnText(find.textRange.ofSubstring('@dev'));
    expect(tapped, const GitLabReference(GitLabReferenceType.user, 'dev'));
  });

  testWidgets('tapping an ordinary link invokes onLinkTap', (tester) async {
    Uri? tapped;
    await tester.pumpWidget(
      host('[docs](https://example.com)', onLinkTap: (uri) => tapped = uri),
    );
    await tester.tapOnText(find.textRange.ofSubstring('docs'));
    expect(tapped, Uri.parse('https://example.com'));
  });

  testWidgets('code spans render in GitLab Mono on the code background', (tester) async {
    await tester.pumpWidget(host('run `flutter test` now'));
    final gs = buildAppTheme().extension<GsTheme>()!;
    final codeStyle = _spanStyleFor(tester, 'flutter test');
    expect(codeStyle?.fontFamily, gs.mono.fontFamily);
    expect(codeStyle?.backgroundColor, gs.codeBg);
  });

  testWidgets('body text renders in the UI font from the theme', (tester) async {
    await tester.pumpWidget(host('plain body text'));
    final style = _spanStyleFor(tester, 'plain body text');
    expect(style?.fontFamily, buildAppTheme().textTheme.bodyMedium!.fontFamily);
  });
}

/// Finds the [TextStyle] of the text span whose text is exactly [text].
TextStyle? _spanStyleFor(WidgetTester tester, String text) {
  TextStyle? found;
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    richText.text.visitChildren((span) {
      if (span is TextSpan && span.text == text) {
        found = span.style;
        return false;
      }
      return true;
    });
  }
  return found;
}
