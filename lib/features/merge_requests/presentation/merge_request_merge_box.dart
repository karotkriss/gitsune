import 'package:flutter/material.dart';

import '../../../core/ci/ci_status.dart';
import '../../../core/ci/ci_status_badge.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/merge_request_models.dart';

/// The merge box (E7.4): one panel that folds the four merge-readiness
/// inputs - pipeline status, approval state, mergeability, and the
/// unresolved-discussion count - into review actions.
///
/// Merge stays blocked until every loaded input is ready; a null input with
/// its loading flag cleared means that input failed to load, which also
/// blocks merging.
class MergeRequestMergeBox extends StatelessWidget {
  const MergeRequestMergeBox({
    super.key,
    required this.mergeRequest,
    required this.mergeRequestLoading,
    required this.mergeRequestFailed,
    required this.pipelineStatus,
    required this.pipelinesLoading,
    required this.pipelinesFailed,
    required this.approvals,
    required this.approvalsLoading,
    required this.approvalsFailed,
    required this.unresolvedCount,
    required this.discussionsLoading,
    required this.discussionsFailed,
    required this.actionInFlight,
    required this.onApprove,
    required this.onUnapprove,
    required this.onMerge,
  });

  final MergeRequest mergeRequest;
  final bool mergeRequestLoading;
  final bool mergeRequestFailed;

  /// Latest pipeline status; null with [pipelinesLoading] false means the
  /// merge request has no pipeline or the pipelines failed to load.
  final CiStatus? pipelineStatus;
  final bool pipelinesLoading;
  final bool pipelinesFailed;
  final MergeRequestApprovals? approvals;
  final bool approvalsLoading;
  final bool approvalsFailed;
  final int? unresolvedCount;
  final bool discussionsLoading;
  final bool discussionsFailed;
  final bool actionInFlight;
  final VoidCallback onApprove;
  final VoidCallback onUnapprove;
  final VoidCallback onMerge;

  bool get _pipelineOk =>
      pipelineStatus != CiStatus.failed && pipelineStatus != CiStatus.canceled;

  bool get _open => mergeRequest.state == MergeRequestState.opened;

  bool get _mergeAllowed =>
      _open &&
      !mergeRequest.draft &&
      !actionInFlight &&
      !mergeRequestLoading &&
      !mergeRequestFailed &&
      _pipelineOk &&
      !pipelinesLoading &&
      !pipelinesFailed &&
      !approvalsLoading &&
      !approvalsFailed &&
      (approvals?.complete ?? false) &&
      mergeRequest.mergeable &&
      !discussionsLoading &&
      !discussionsFailed &&
      unresolvedCount == 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gs.surfaceCard,
        border: Border.all(color: gs.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Merge readiness',
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 12),
            _pipelineRow(gs),
            _approvalsRow(gs),
            _mergeabilityRow(gs),
            _discussionsRow(gs),
            const SizedBox(height: 12),
            if (_open) _actions(gs) else _closedNotice(theme, gs),
          ],
        ),
      ),
    );
  }

  Widget _pipelineRow(GsTheme gs) {
    final status = pipelineStatus;
    if (pipelinesLoading) {
      return _MergeBoxRow.pending(gs, 'Checking pipeline status');
    }
    if (pipelinesFailed) {
      return _MergeBoxRow.unavailable(gs, 'Pipeline state unavailable');
    }
    if (status == null) {
      return _MergeBoxRow(
        leading: GsIcon(GsIconGlyph.clock, size: 16, color: gs.textSubtle),
        text: 'No pipeline',
        color: gs.textSubtle,
      );
    }
    return _MergeBoxRow(
      leading: CiStatusBadge(status: status, size: 16),
      text: 'Pipeline ${status.label.toLowerCase()}',
      color: _pipelineOk ? gs.textDefault : gs.textDanger,
    );
  }

  Widget _approvalsRow(GsTheme gs) {
    final loadedApprovals = approvals;
    if (approvalsLoading) {
      return _MergeBoxRow.pending(gs, 'Checking approvals');
    }
    if (approvalsFailed || loadedApprovals == null) {
      return _MergeBoxRow.unavailable(gs, 'Approval state unavailable');
    }
    final complete = loadedApprovals.complete;
    return _MergeBoxRow(
      leading: GsIcon(
        GsIconGlyph.approval,
        size: 16,
        color: complete ? gs.statusSuccess : gs.textSubtle,
      ),
      text: loadedApprovals.summary,
      color: complete ? gs.textDefault : gs.textSubtle,
    );
  }

  Widget _mergeabilityRow(GsTheme gs) {
    if (mergeRequestLoading) {
      return _MergeBoxRow.pending(gs, 'Checking mergeability');
    }
    if (mergeRequestFailed) {
      return _MergeBoxRow.unavailable(gs, 'Mergeability unavailable');
    }
    final mergeable = mergeRequest.mergeable;
    return _MergeBoxRow(
      leading: GsIcon(
        GsIconGlyph.merge,
        size: 16,
        color: mergeable ? gs.statusSuccess : gs.statusDanger,
      ),
      text: mergeable ? 'Can be merged' : 'Cannot be merged yet',
      color: mergeable ? gs.textDefault : gs.textDanger,
    );
  }

  Widget _discussionsRow(GsTheme gs) {
    final count = unresolvedCount;
    if (discussionsLoading) {
      return _MergeBoxRow.pending(gs, 'Checking discussions');
    }
    if (discussionsFailed || count == null) {
      return _MergeBoxRow.unavailable(gs, 'Discussion state unavailable');
    }
    final resolved = count == 0;
    return _MergeBoxRow(
      leading: GsIcon(
        GsIconGlyph.comments,
        size: 16,
        color: resolved ? gs.statusSuccess : gs.statusWarning,
      ),
      text: resolved
          ? 'All discussions resolved'
          : '$count unresolved ${count == 1 ? 'discussion' : 'discussions'}',
      color: resolved ? gs.textDefault : gs.textSubtle,
    );
  }

  Widget _actions(GsTheme gs) {
    final loadedApprovals = approvals;
    final showApprove =
        loadedApprovals != null &&
        (loadedApprovals.userHasApproved || loadedApprovals.userCanApprove);
    return Row(
      children: [
        if (showApprove) ...[
          Expanded(
            child: OutlinedButton(
              key: const ValueKey('approve-button'),
              onPressed: actionInFlight || approvalsLoading || approvalsFailed
                  ? null
                  : loadedApprovals.userHasApproved
                  ? onUnapprove
                  : onApprove,
              child: Text(
                loadedApprovals.userHasApproved ? 'Unapprove' : 'Approve',
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: FilledButton(
            key: const ValueKey('merge-button'),
            onPressed: _mergeAllowed ? onMerge : null,
            child: const Text('Merge'),
          ),
        ),
      ],
    );
  }

  Widget _closedNotice(ThemeData theme, GsTheme gs) {
    final merged = mergeRequest.state == MergeRequestState.merged;
    return Row(
      children: [
        GsIcon(
          merged ? GsIconGlyph.merge : GsIconGlyph.mergeRequestClosed,
          size: 16,
          color: merged ? gs.statusSuccess : gs.textSubtle,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            merged
                ? 'This merge request has been merged.'
                : 'This merge request is closed.',
            style: theme.textTheme.bodyMedium?.copyWith(color: gs.textDefault),
          ),
        ),
      ],
    );
  }
}

class _MergeBoxRow extends StatelessWidget {
  const _MergeBoxRow({
    required this.leading,
    required this.text,
    required this.color,
  });

  _MergeBoxRow.pending(GsTheme gs, String text)
    : this(
        leading: GsIcon(GsIconGlyph.clock, size: 16, color: gs.textSubtle),
        text: '$text...',
        color: gs.textSubtle,
      );

  _MergeBoxRow.unavailable(GsTheme gs, String text)
    : this(
        leading: GsIcon(GsIconGlyph.cancel, size: 16, color: gs.textDanger),
        text: text,
        color: gs.textSubtle,
      );

  final Widget leading;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
