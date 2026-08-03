import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/merge_request_models.dart';

/// Pajamas state badge treatment for a merge request.
class MergeRequestStateBadge extends StatelessWidget {
  const MergeRequestStateBadge({
    super.key,
    required this.state,
    this.draft = false,
  });

  final MergeRequestState state;
  final bool draft;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final label = draft ? 'Draft' : state.label;
    final glyph = draft
        ? GsIconGlyph.mergeRequestOpen
        : switch (state) {
            MergeRequestState.opened => GsIconGlyph.mergeRequestOpen,
            MergeRequestState.merged => GsIconGlyph.merge,
            MergeRequestState.closed ||
            MergeRequestState.locked => GsIconGlyph.mergeRequestClosed,
          };
    final colors = draft
        ? (gs.surfaceStrong, gs.textDefault)
        : switch (state) {
            MergeRequestState.opened => (
              gs.feedbackSuccessBg,
              gs.feedbackSuccessText,
            ),
            MergeRequestState.merged => (
              gs.feedbackInfoBg,
              gs.feedbackInfoText,
            ),
            MergeRequestState.closed => (gs.surfaceStrong, gs.textDefault),
            MergeRequestState.locked => (
              gs.feedbackWarningBg,
              gs.feedbackWarningText,
            ),
          };
    return Semantics(
      label: 'Merge request state: $label',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.$1,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GsIcon(glyph, size: 12, color: colors.$2),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.$2,
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

/// Source and target branch tokens, with every git reference in GitLab Mono.
class MergeRequestBranchPath extends StatelessWidget {
  const MergeRequestBranchPath({
    super.key,
    required this.source,
    required this.target,
  });

  final String source;
  final String target;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Semantics(
      label: 'Source branch $source, target branch $target',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: MergeRequestBranchChip(label: source)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GsIcon(
                GsIconGlyph.longArrow,
                size: 14,
                color: gs.textSubtle,
              ),
            ),
            Flexible(child: MergeRequestBranchChip(label: target)),
          ],
        ),
      ),
    );
  }
}

class MergeRequestBranchChip extends StatelessWidget {
  const MergeRequestBranchChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gs.surfaceStrong,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(fontSize: 12, color: gs.textDefault),
        ),
      ),
    );
  }
}

class MergeRequestAvatar extends StatelessWidget {
  const MergeRequestAvatar({super.key, required this.author, this.size = 28});

  final MergeRequestAuthor author;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Semantics(
      image: true,
      label: author.name,
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

String formatMergeRequestRelativeTime(DateTime timestamp, DateTime now) {
  final elapsed = now.difference(timestamp);
  if (elapsed.isNegative || elapsed.inMinutes < 1) return 'now';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes}m';
  if (elapsed.inDays < 1) return '${elapsed.inHours}h';
  if (elapsed.inDays < 30) return '${elapsed.inDays}d';
  final month = timestamp.month.toString().padLeft(2, '0');
  final day = timestamp.day.toString().padLeft(2, '0');
  return '${timestamp.year}-$month-$day';
}
