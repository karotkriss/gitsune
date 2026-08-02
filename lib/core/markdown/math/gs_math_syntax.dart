import 'package:markdown/markdown.dart' as md;

/// Tag used for a `$$...$$` math block, keyed by [GsMathBlockBuilder].
const gsMathBlockTag = 'gs-math-block';

/// Tag used for a `$...$` inline math span, keyed by [GsMathInlineBuilder].
const gsMathInlineTag = 'gs-math-inline';

/// Parses GitLab-flavored `$$...$$` math blocks, either on a single line or
/// spanning multiple lines between two `$$` delimiter lines.
class GsMathBlockSyntax extends md.BlockSyntax {
  const GsMathBlockSyntax();

  static final _open = RegExp(r'^\$\$');
  static final _singleLine = RegExp(r'^\$\$(.+)\$\$\s*$');
  static final _closing = RegExp(r'^\$\$\s*$');

  @override
  RegExp get pattern => _open;

  @override
  md.Node parse(md.BlockParser parser) {
    final singleLine = _singleLine.firstMatch(parser.current.content);
    if (singleLine != null) {
      parser.advance();
      return md.Element.text(gsMathBlockTag, singleLine[1]!.trim());
    }

    parser.advance();
    final lines = <String>[];
    while (!parser.isDone) {
      if (_closing.hasMatch(parser.current.content)) {
        parser.advance();
        break;
      }
      lines.add(parser.current.content);
      parser.advance();
    }
    return md.Element.text(gsMathBlockTag, lines.join('\n').trim());
  }
}

/// Parses GitLab-flavored `$...$` inline math spans.
///
/// Requires a lone `$` (not `$$`, which is reserved for [GsMathBlockSyntax])
/// with non-empty, single-line content.
class GsMathInlineSyntax extends md.InlineSyntax {
  GsMathInlineSyntax() : super(_pattern);

  static const _pattern = r'(?<!\$)\$(?!\$)([^\n$]+?)(?<!\$)\$(?!\$)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text(gsMathInlineTag, match[1]!));
    return true;
  }
}
