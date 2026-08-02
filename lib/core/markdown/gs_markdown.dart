import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../theme/app_theme.dart';
import 'gitlab_references.dart';
import 'math/gs_math_builder.dart';
import 'math/gs_math_syntax.dart';
import 'mermaid/gs_mermaid_builder.dart';
import 'mermaid/gs_mermaid_syntax.dart';

/// GitLab-flavored markdown body, themed from the token layer.
///
/// Body text inherits GitLab Sans from the app [TextTheme]; code spans and
/// blocks use the [GsTheme.mono] style on [GsTheme.codeBg]. GitLab references
/// (`#123`, `!456`, `@user`, `~label`) render as tappable links via
/// [gitLabReferenceSyntaxes] and surface through [onReferenceTap]; ordinary
/// links surface through [onLinkTap]. Navigation belongs to the calling
/// screen, not here.
///
/// Math (`$...$` inline, `$$...$$` block) renders via [GsMathInlineBuilder]
/// and [GsMathBlockBuilder]; Mermaid fenced code blocks (` ```mermaid `)
/// render via [GsMermaidBlockBuilder]. Both degrade to the raw source in a
/// code block rather than throwing; see `docs/plan/task-breakdown.md` E4.2.
class GsMarkdown extends StatelessWidget {
  const GsMarkdown({
    super.key,
    required this.data,
    this.onReferenceTap,
    this.onLinkTap,
  });

  final String data;
  final ValueChanged<GitLabReference>? onReferenceTap;
  final ValueChanged<Uri>? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return MarkdownBody(
      data: data,
      inlineSyntaxes: [...gitLabReferenceSyntaxes(), GsMathInlineSyntax()],
      blockSyntaxes: const [GsMermaidBlockSyntax(), GsMathBlockSyntax()],
      builders: {
        gsMermaidBlockTag: GsMermaidBlockBuilder(),
        gsMathBlockTag: GsMathBlockBuilder(),
        gsMathFallbackTag: GsMathFallbackBuilder(),
        gsMathInlineTag: GsMathInlineBuilder(),
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        a: TextStyle(color: gs.link),
        code: gs.mono.copyWith(backgroundColor: gs.codeBg),
        codeblockDecoration: BoxDecoration(
          color: gs.codeBg,
          borderRadius: BorderRadius.circular(4),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: gs.borderStrong, width: 3)),
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: gs.borderDefault)),
        ),
      ),
      onTapLink: (text, href, title) {
        final ref = GitLabReference.fromHref(href);
        if (ref != null) {
          onReferenceTap?.call(ref);
        } else {
          final uri = href == null ? null : Uri.tryParse(href);
          if (uri != null) onLinkTap?.call(uri);
        }
      },
    );
  }
}
