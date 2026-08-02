import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import '../gs_markdown_fallback.dart';

/// Renders a `$$...$$` math block as centered display-style TeX, degrading to
/// the raw source on any parse or build error.
class GsMathBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final source = element.textContent;
    return Center(
      child: Math.tex(
        source,
        mathStyle: MathStyle.display,
        onErrorFallback: (_) => gsRawSourceFallback(context, source),
      ),
    );
  }
}

class GsMathFallbackBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) => gsRawSourceFallback(context, element.textContent);
}

/// Renders a `$...$` inline math span as text-style TeX inline with
/// surrounding prose, degrading to the raw source on any parse or build
/// error.
class GsMathInlineBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final source = element.textContent;
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          source,
          mathStyle: MathStyle.text,
          textStyle: parentStyle,
          onErrorFallback: (_) => gsRawSourceFallback(context, source),
        ),
      ),
    );
  }
}
