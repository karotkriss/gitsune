import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/markdown/gs_markdown.dart';
import '../../../core/theme/app_theme.dart';
import '../data/issue_models.dart';

class IssueStateBadge extends StatelessWidget {
  const IssueStateBadge({super.key, required this.state});

  final IssueState state;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final isOpen = state == IssueState.opened;
    final background = isOpen ? gs.feedbackSuccessBg : gs.surfaceStrong;
    final foreground = isOpen ? gs.feedbackSuccessText : gs.textDefault;
    return Semantics(
      label: 'Issue state: ${state.label}',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GsIcon(
                  isOpen ? GsIconGlyph.issueOpen : GsIconGlyph.issueClosed,
                  size: 12,
                  color: foreground,
                ),
                const SizedBox(width: 4),
                Text(
                  state.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IssueLabelPill extends StatelessWidget {
  const IssueLabelPill({super.key, required this.label});

  final IssueLabel label;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final background = _parseHex(label.colorHex) ?? gs.statusInfo;
    final foreground =
        _parseHex(label.textColorHex) ??
        (background.computeLuminance() > 0.55 ? gs.surfaceApp : gs.textHeading);
    final style = gs.caption.copyWith(height: 16 / 12);

    return Semantics(
      label: 'Label: ${label.name}',
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: label.isScoped ? gs.surfaceCard : background,
              border: label.isScoped
                  ? Border.all(color: background, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(999),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: label.isScoped
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ColoredBox(
                            color: background,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(7, 1, 6, 1),
                              child: Text(
                                label.scope,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style.copyWith(color: foreground),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 7, 0),
                            child: Text(
                              label.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style.copyWith(color: gs.textDefault),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        label.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.copyWith(color: foreground),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class IssueMetadataPill extends StatelessWidget {
  const IssueMetadataPill({super.key, required this.label, this.icon});

  final String label;
  final GsIconGlyph? icon;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gs.surfaceStrong,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  GsIcon(icon!, size: 12, color: gs.textSubtle),
                  const SizedBox(width: 4),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: gs.caption.copyWith(color: gs.textSubtle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IssueAvatar extends StatelessWidget {
  const IssueAvatar({super.key, required this.author, this.size = 32});

  final IssueAuthor author;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Semantics(
      label: author.name,
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gs.feedbackInfoBg,
            shape: BoxShape.circle,
          ),
          child: Text(
            author.initials,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: gs.feedbackInfoText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class IssueCommentCard extends StatelessWidget {
  const IssueCommentCard({
    super.key,
    required this.author,
    required this.timeLabel,
    required this.body,
    this.opening = false,
    this.internal = false,
  });

  final IssueAuthor author;
  final String timeLabel;
  final String body;
  final bool opening;
  final bool internal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      container: true,
      label: opening
          ? 'Issue description by ${author.name}'
          : 'Comment by ${author.name}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gs.surfaceCard,
          border: Border.all(color: gs.borderSubtle),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IssueAvatar(author: author),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          author.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gs.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          opening
                              ? 'opened $timeLabel'
                              : 'commented $timeLabel',
                          style: gs.caption.copyWith(color: gs.textSubtle),
                        ),
                        if (internal)
                          const IssueMetadataPill(label: 'Internal'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (body.trim().isEmpty)
                      Text(
                        'No description provided.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: gs.textSubtle,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      GsMarkdown(data: body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live [GsMarkdown] rendering of an in-progress draft, used by the issue
/// composer surfaces. Collapses to nothing while the draft is empty.
class IssueDraftPreview extends StatelessWidget {
  const IssueDraftPreview({super.key, required this.draft});

  final String draft;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    if (draft.trim().isEmpty) return const SizedBox.shrink();
    return Semantics(
      container: true,
      label: 'Markdown preview',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gs.surfaceCard,
          border: Border.all(color: gs.borderSubtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: gs.caption.copyWith(color: gs.textSubtle)),
            const SizedBox(height: 8),
            GsMarkdown(data: draft),
          ],
        ),
      ),
    );
  }
}

class IssueSystemEvent extends StatelessWidget {
  const IssueSystemEvent({
    super.key,
    required this.note,
    required this.timeLabel,
  });

  final IssueNote note;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Semantics(
      container: true,
      label: '${note.author.name} ${note.body}, $timeLabel',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: GsIcon(
                GsIconGlyph.issueOpen,
                size: 14,
                color: gs.statusNeutral,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: note.author.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' ${note.body} · $timeLabel'),
                  ],
                ),
                style: gs.caption.copyWith(color: gs.textSubtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color? _parseHex(String? value) {
  if (value == null) return null;
  final normalized = value.trim().replaceFirst('#', '');
  final expanded = normalized.length == 3
      ? normalized.split('').map((character) => '$character$character').join()
      : normalized;
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(expanded)) return null;
  return Color(int.parse('FF$expanded', radix: 16));
}

String formatIssueRelativeTime(DateTime timestamp, DateTime now) {
  final elapsed = now.toUtc().difference(timestamp.toUtc());
  if (elapsed.isNegative || elapsed.inMinutes < 1) return 'now';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}m';
  if (elapsed.inDays < 1) return '${elapsed.inHours}h';
  if (elapsed.inDays < 7) return '${elapsed.inDays}d';
  final value = timestamp.toLocal();
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
