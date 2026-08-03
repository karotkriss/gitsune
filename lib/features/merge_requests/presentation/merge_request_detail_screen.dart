import 'package:flutter/material.dart';

import '../../../core/ci/ci_status_badge.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/markdown/gs_markdown.dart';
import '../../../core/theme/app_theme.dart';
import '../data/merge_request_models.dart';
import '../data/merge_requests_repository.dart';
import 'merge_request_components.dart';

class MergeRequestDetailScreen extends StatefulWidget {
  const MergeRequestDetailScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.mergeIid,
    required this.repository,
    this.initialMergeRequest,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final int mergeIid;
  final MergeRequestsRepository repository;
  final MergeRequest? initialMergeRequest;
  final DateTime? now;

  @override
  State<MergeRequestDetailScreen> createState() =>
      _MergeRequestDetailScreenState();
}

class _MergeRequestDetailScreenState extends State<MergeRequestDetailScreen> {
  MergeRequest? _mergeRequest;
  MergeRequestDetails? _details;
  bool _loading = true;
  bool _failed = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _mergeRequest = widget.initialMergeRequest;
    _load();
  }

  @override
  void didUpdateWidget(covariant MergeRequestDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.mergeIid != widget.mergeIid ||
        oldWidget.repository != widget.repository) {
      _mergeRequest = widget.initialMergeRequest;
      _details = null;
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final details = await widget.repository.loadMergeRequest(
        widget.projectId,
        widget.mergeIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _details = details;
        _mergeRequest = details.mergeRequest;
        _loading = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      if (_mergeRequest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to refresh this merge request.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final mergeRequest = _mergeRequest;
    final details = _details;
    return Scaffold(
      backgroundColor: gs.surfaceSubtle,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: gs.surfaceApp,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: GsIcon(
                  GsIconGlyph.chevronLeft,
                  size: 20,
                  color: gs.accent,
                ),
              )
            : null,
        title: Text(
          '${widget.projectPath} · !${widget.mergeIid}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(
            color: gs.textHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: mergeRequest == null
          ? _DetailInitialState(
              loading: _loading,
              failed: _failed,
              onRetry: _load,
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: gs.accent,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_loading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  SliverToBoxAdapter(
                    child: _MergeRequestHeader(
                      mergeRequest: mergeRequest,
                      now: widget.now ?? DateTime.now(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _DescriptionCard(mergeRequest: mergeRequest),
                          const SizedBox(height: 12),
                          _ChangedFilesCard(mergeRequest: mergeRequest),
                          const SizedBox(height: 12),
                          if (details != null) ...[
                            _PipelineSection(
                              pipelines: details.pipelines,
                              now: widget.now ?? DateTime.now(),
                            ),
                            const SizedBox(height: 12),
                            _ApprovalsSection(approvals: details.approvals),
                          ] else
                            _DetailDataState(failed: _failed, onRetry: _load),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MergeRequestHeader extends StatelessWidget {
  const _MergeRequestHeader({required this.mergeRequest, required this.now});

  final MergeRequest mergeRequest;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final updated = formatMergeRequestRelativeTime(mergeRequest.updatedAt, now);
    final updatedLabel = updated == 'now'
        ? 'updated now'
        : 'updated $updated ago';
    return ColoredBox(
      color: gs.surfaceApp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MergeRequestStateBadge(
                  state: mergeRequest.state,
                  draft: mergeRequest.draft,
                ),
                Text(
                  '${mergeRequest.author.username} $updatedLabel',
                  style: gs.caption.copyWith(color: gs.textSubtle),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Semantics(
              header: true,
              child: Text(
                mergeRequest.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: gs.textHeading,
                ),
              ),
            ),
            const SizedBox(height: 12),
            MergeRequestBranchPath(
              source: mergeRequest.sourceBranch,
              target: mergeRequest.targetBranch,
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.mergeRequest});

  final MergeRequest mergeRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            if (mergeRequest.description.trim().isEmpty)
              Text(
                'No description provided.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: gs.textSubtle,
                ),
              )
            else
              GsMarkdown(data: mergeRequest.description),
          ],
        ),
      ),
    );
  }
}

class _ChangedFilesCard extends StatelessWidget {
  const _ChangedFilesCard({required this.mergeRequest});

  final MergeRequest mergeRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      container: true,
      label: mergeRequest.changedFilesLabel,
      child: ExcludeSemantics(
        child: _Card(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GsIcon(
                    GsIconGlyph.mergeRequestOpen,
                    size: 18,
                    color: gs.textSubtle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mergeRequest.changedFilesLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gs.textDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PipelineSection extends StatelessWidget {
  const _PipelineSection({required this.pipelines, required this.now});

  final List<MergeRequestPipeline> pipelines;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final summary = pipelines.isEmpty
        ? 'No pipelines'
        : '${pipelines.first.status.label} · ${pipelines.length} '
              '${pipelines.length == 1 ? 'pipeline' : 'pipelines'}';
    return CollapsibleMergeRequestSection(
      key: const ValueKey('pipelines-section'),
      title: 'Pipelines',
      summary: summary,
      leading: pipelines.isEmpty
          ? null
          : CiStatusBadge(
              status: pipelines.first.status,
              size: 20,
              excludeFromSemantics: true,
            ),
      child: pipelines.isEmpty
          ? const _EmptySectionMessage(
              message: 'No pipelines are attached to this merge request.',
            )
          : Column(
              children: [
                for (var index = 0; index < pipelines.length; index++)
                  _PipelineRow(
                    pipeline: pipelines[index],
                    now: now,
                    showDivider: index < pipelines.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.pipeline,
    required this.now,
    required this.showDivider,
  });

  final MergeRequestPipeline pipeline;
  final DateTime now;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final updated = formatMergeRequestRelativeTime(pipeline.updatedAt, now);
    return Semantics(
      container: true,
      label:
          'Pipeline ${pipeline.id}, ${pipeline.status.label}, '
          'reference ${pipeline.ref}, commit ${pipeline.shortSha}, '
          'updated $updated ago.',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: gs.borderSubtle))
                : null,
          ),
          child: Row(
            children: [
              CiStatusBadge(
                status: pipeline.status,
                size: 20,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: gs.textDefault,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pipeline #${pipeline.id}',
                            style: gs.mono.copyWith(
                              color: gs.textDefault,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' · ${pipeline.status.label}'),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pipeline.ref} · ${pipeline.shortSha}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: gs.mono.copyWith(
                        fontSize: 12,
                        color: gs.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(updated, style: gs.caption.copyWith(color: gs.textSubtle)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalsSection extends StatelessWidget {
  const _ApprovalsSection({required this.approvals});

  final MergeRequestApprovals approvals;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return CollapsibleMergeRequestSection(
      key: const ValueKey('approvals-section'),
      title: 'Approvals',
      summary: approvals.summary,
      leading: GsIcon(
        GsIconGlyph.approval,
        size: 20,
        color: approvals.complete ? gs.statusSuccess : gs.textSubtle,
      ),
      child: approvals.approvedBy.isEmpty
          ? const _EmptySectionMessage(message: 'No approvals yet.')
          : Column(
              children: [
                for (
                  var index = 0;
                  index < approvals.approvedBy.length;
                  index++
                )
                  _ApprovalRow(
                    approver: approvals.approvedBy[index],
                    showDivider: index < approvals.approvedBy.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _ApprovalRow extends StatelessWidget {
  const _ApprovalRow({required this.approver, required this.showDivider});

  final MergeRequestAuthor approver;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      container: true,
      label: '${approver.name}, approved',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(bottom: BorderSide(color: gs.borderSubtle))
                : null,
          ),
          child: Row(
            children: [
              MergeRequestAvatar(author: approver),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approver.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gs.textDefault,
                      ),
                    ),
                    Text(
                      '@${approver.username}',
                      style: gs.caption.copyWith(color: gs.textSubtle),
                    ),
                  ],
                ),
              ),
              Text(
                'Approved',
                style: gs.caption.copyWith(color: gs.textSuccess),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollapsibleMergeRequestSection extends StatefulWidget {
  const CollapsibleMergeRequestSection({
    super.key,
    required this.title,
    required this.summary,
    required this.child,
    this.leading,
    this.initiallyExpanded = true,
  });

  final String title;
  final String summary;
  final Widget child;
  final Widget? leading;
  final bool initiallyExpanded;

  @override
  State<CollapsibleMergeRequestSection> createState() =>
      _CollapsibleMergeRequestSectionState();
}

class _CollapsibleMergeRequestSectionState
    extends State<CollapsibleMergeRequestSection> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return _Card(
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            onTap: _toggleExpanded,
            label: '${widget.title}, ${widget.summary}',
            child: ExcludeSemantics(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: _expanded ? Radius.zero : const Radius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: ValueKey('${widget.title.toLowerCase()}-section-toggle'),
                  onTap: _toggleExpanded,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          if (widget.leading != null) ...[
                            widget.leading!,
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: gs.textHeading,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  widget.summary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: gs.caption.copyWith(
                                    color: gs.textSubtle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GsIcon(
                            _expanded
                                ? GsIconGlyph.chevronUp
                                : GsIconGlyph.chevronDown,
                            size: 16,
                            color: gs.textSubtle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: gs.borderSubtle)),
                    ),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gs.surfaceCard,
        border: Border.all(color: gs.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }
}

class _EmptySectionMessage extends StatelessWidget {
  const _EmptySectionMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
        ),
      ),
    );
  }
}

class _DetailDataState extends StatelessWidget {
  const _DetailDataState({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!failed) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Unable to load pipelines and approvals.'),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _DetailInitialState extends StatelessWidget {
  const _DetailInitialState({
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (!failed) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load this merge request.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection, then try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
