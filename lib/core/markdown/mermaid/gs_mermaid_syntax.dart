import 'package:markdown/markdown.dart' as md;

/// Tag used for a Mermaid fenced code block, keyed by a Mermaid builder.
const gsMermaidBlockTag = 'gs-mermaid-block';

/// Parses ` ```mermaid ` (or `~~~mermaid`) fenced code blocks into their own
/// element, ahead of the default fenced-code-block syntax, so every other
/// fenced code block (` ```dart `, plain ` ``` `, ...) is untouched.
class GsMermaidBlockSyntax extends md.BlockSyntax {
  const GsMermaidBlockSyntax();

  static final _open = RegExp(r'^(`{3,}|~{3,})\s*mermaid\s*$');

  @override
  RegExp get pattern => _open;

  @override
  md.Node parse(md.BlockParser parser) {
    final opener = _open.firstMatch(parser.current.content)!.group(1)!;
    final close = RegExp(
      '^${RegExp.escape(opener[0])}{${opener.length},}\\s*\$',
    );
    parser.advance();
    final lines = <String>[];
    while (!parser.isDone && !close.hasMatch(parser.current.content)) {
      lines.add(parser.current.content);
      parser.advance();
    }
    if (!parser.isDone) parser.advance();
    return md.Element.text(gsMermaidBlockTag, lines.join('\n'));
  }
}
