import 'package:flutter/material.dart';

import '../../../core/ci/ci_status_badge.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/markdown/gs_markdown.dart';
import '../../../core/repository/recently_viewed_repository.dart';
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
    this.recentlyViewedCache,
    this.initialMergeRequest,
    this.onShowChanges,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final int mergeIid;
  final MergeRequestsRepository repository;

  /// Serves this merge request's core content offline after a previous view;
  /// null leaves the screen network-only until the composition root wires
  /// the cache. Pipelines and approvals stay network-only.
  final RecentlyViewedCache? recentlyViewedCache;
  final MergeRequest? initialMergeRequest;

  /// Opens the changes (diff) screen for the merge request; the card stays
  /// non-tappable when null.
  final void Function(MergeRequest mergeRequest)? onShowChanges;
  final DateTime? now;

  @override
  State<MergeRequestDetailScreen> createState() =>
      _MergeRequestDetailScreenState();
}

class _MergeRequestDetailScreenState extends State<MergeRequestDetailScreen> {
  MergeRequest? _mergeRequest;
  List<MergeRequestPipeline>? _pipelines;
  MergeRequestApprovals? _approvals;
  bool _loading = true;
  bool _failed = false;
  bool _pipelinesLoading = true;
  bool _pipelinesFailed = false;
  bool _pipelinesHaveMore = false;
  bool _loadingMorePipelines = false;
  bool _approvalsLoading = true;
  bool _approvalsFailed = false;
  int _generation = 0;
  RecentItemRepository<MergeRequest>? _recentMergeRequest;

  @override
  void initState() {
    super.initState();
    _mergeRequest = widget.initialMergeRequest;
    _rebuildRecentMergeRequest();
    _load();
  }

  @override
  void didUpdateWidget(covariant MergeRequestDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.mergeIid != widget.mergeIid ||
        oldWidget.repository != widget.repository) {
      _mergeRequest = widget.initialMergeRequest;
      _pipelines = null;
      _approvals = null;
      _rebuildRecentMergeRequest();
      _load();
    }
  }

  void _rebuildRecentMergeRequest() {
    final cache = widget.recentlyViewedCache;
    _recentMergeRequest = cache == null
        ? null
        : RecentItemRepository(
            cache: cache,
            type: RecentlyViewedType.mergeRequest,
            projectId: widget.projectId,
            itemId: widget.mergeIid,
            fetch: () => widget.repository.loadMergeRequest(
              widget.projectId,
              widget.mergeIid,
            ),
            decode: MergeRequest.fromJson,
            encode: (mergeRequest) => mergeRequest.toJson(),
          );
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
      _pipelinesLoading = true;
      _pipelinesFailed = false;
      _loadingMorePipelines = false;
      _approvalsLoading = true;
      _approvalsFailed = false;
    });
    await Future.wait([
      _loadCore(generation),
      _loadPipelines(generation),
      _loadApprovals(generation),
    ]);
  }

  Future<void> _loadCore(int generation) async {
    final recent = _recentMergeRequest;
    if (recent != null && _mergeRequest == null) {
      // Stale-while-revalidate: serve the cached merge request immediately
      // while the network refresh below continues in the background.
      final cached = await recent.readCached();
      if (!mounted || generation != _generation) return;
      if (cached != null && _mergeRequest == null) {
        setState(() => _mergeRequest = cached);
      }
    }
    try {
      final mergeRequest = recent != null
          ? await recent.load()
          : await widget.repository.loadMergeRequest(
              widget.projectId,
              widget.mergeIid,
            );
      if (!mounted || generation != _generation) return;
      setState(() {
        _mergeRequest = mergeRequest;
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

  Future<void> _loadPipelines(int generation) async {
    try {
      final page = await widget.repository.loadFirstPipelinePage(
        widget.projectId,
        widget.mergeIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _pipelines = page.items;
        _pipelinesHaveMore = page.hasMore;
        _pipelinesLoading = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _pipelinesLoading = false;
        _pipelinesFailed = true;
      });
    }
  }

  Future<void> _loadApprovals(int generation) async {
    try {
      final approvals = await widget.repository.loadApprovals(
        widget.projectId,
        widget.mergeIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _approvals = approvals;
        _approvalsLoading = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _approvalsLoading = false;
        _approvalsFailed = true;
      });
    }
  }

  Future<void> _loadMorePipelines() async {
    if (_loadingMorePipelines || !_pipelinesHaveMore) return;
    final generation = _generation;
    setState(() => _loadingMorePipelines = true);
    try {
      final page = await widget.repository.loadNextPipelinePage(
        widget.projectId,
        widget.mergeIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _pipelines = [...?_pipelines, ...page.items];
        _pipelinesHaveMore = page.hasMore;
        _loadingMorePipelines = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() => _loadingMorePipelines = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load more pipelines.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final mergeRequest = _mergeRequest;
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
                          _ChangedFilesCard(
                            mergeRequest: mergeRequest,
                            onTap: widget.onShowChanges == null
                                ? null
                                : () => widget.onShowChanges!(mergeRequest),
                          ),
                          const SizedBox(height: 12),
                          _PipelineSectionState(
                            pipelines: _pipelines,
                            loading: _pipelinesLoading,
                            failed: _pipelinesFailed,
                            hasMore: _pipelinesHaveMore,
                            loadingMore: _loadingMorePipelines,
                            now: widget.now ?? DateTime.now(),
                            onRetry: _load,
                            onLoadMore: _loadMorePipelines,
                          ),
                          const SizedBox(height: 12),
                          _ApprovalsSectionState(
                            approvals: _approvals,
                            loading: _approvalsLoading,
                            failed: _approvalsFailed,
                            onRetry: _load,
                          ),
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
  const _ChangedFilesCard({required this.mergeRequest, this.onTap});

  final MergeRequest mergeRequest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      container: true,
      button: onTap != null,
      onTap: onTap,
      label: mergeRequest.changedFilesLabel,
      child: ExcludeSemantics(
        child: _Card(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('changed-files-card'),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
                      if (onTap != null)
                        GsIcon(
                          GsIconGlyph.chevronRight,
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
    );
  }
}

class _PipelineSectionState extends StatelessWidget {
  const _PipelineSectionState({
    required this.pipelines,
    required this.loading,
    required this.failed,
    required this.hasMore,
    required this.loadingMore,
    required this.now,
    required this.onRetry,
    required this.onLoadMore,
  });

  final List<MergeRequestPipeline>? pipelines;
  final bool loading;
  final bool failed;
  final bool hasMore;
  final bool loadingMore;
  final DateTime now;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final loadedPipelines = pipelines;
    if (loadedPipelines == null) {
      return _SupplementSectionState(
        title: 'Pipelines',
        loading: loading,
        failed: failed,
        onRetry: onRetry,
      );
    }
    final summary = loadedPipelines.isEmpty
        ? 'No pipelines'
        : '${loadedPipelines.first.status.label} · ${loadedPipelines.length} '
              '${loadedPipelines.length == 1 ? 'pipeline' : 'pipelines'}';
    return CollapsibleMergeRequestSection(
      key: const ValueKey('pipelines-section'),
      title: 'Pipelines',
      summary: summary,
      leading: loadedPipelines.isEmpty
          ? null
          : CiStatusBadge(
              status: loadedPipelines.first.status,
              size: 20,
              excludeFromSemantics: true,
            ),
      child: loadedPipelines.isEmpty
          ? const _EmptySectionMessage(
              message: 'No pipelines are attached to this merge request.',
            )
          : Column(
              children: [
                for (var index = 0; index < loadedPipelines.length; index++)
                  _PipelineRow(
                    pipeline: loadedPipelines[index],
                    now: now,
                    showDivider: index < loadedPipelines.length - 1 || hasMore,
                  ),
                if (hasMore)
                  TextButton(
                    key: const ValueKey('load-more-pipelines'),
                    onPressed: loadingMore ? null : onLoadMore,
                    child: Text(loadingMore ? 'Loading...' : 'Load more'),
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
    final updatedAt = pipeline.updatedAt;
    final updated = updatedAt == null
        ? null
        : formatMergeRequestRelativeTime(updatedAt, now);
    return Semantics(
      container: true,
      label:
          'Pipeline ${pipeline.id}, ${pipeline.status.label}, '
          'reference ${pipeline.ref}, commit ${pipeline.shortSha}'
          '${updated == null ? '.' : ', updated $updated ago.'}',
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
              if (updated != null)
                Text(updated, style: gs.caption.copyWith(color: gs.textSubtle)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalsSectionState extends StatelessWidget {
  const _ApprovalsSectionState({
    required this.approvals,
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final MergeRequestApprovals? approvals;
  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedApprovals = approvals;
    if (loadedApprovals == null) {
      return _SupplementSectionState(
        title: 'Approvals',
        loading: loading,
        failed: failed,
        onRetry: onRetry,
      );
    }
    final gs = Theme.of(context).extension<GsTheme>()!;
    return CollapsibleMergeRequestSection(
      key: const ValueKey('approvals-section'),
      title: 'Approvals',
      summary: loadedApprovals.summary,
      leading: GsIcon(
        GsIconGlyph.approval,
        size: 20,
        color: loadedApprovals.complete ? gs.statusSuccess : gs.textSubtle,
      ),
      child: loadedApprovals.approvedBy.isEmpty
          ? const _EmptySectionMessage(message: 'No approvals yet.')
          : Column(
              children: [
                for (
                  var index = 0;
                  index < loadedApprovals.approvedBy.length;
                  index++
                )
                  _ApprovalRow(
                    approver: loadedApprovals.approvedBy[index],
                    showDivider: index < loadedApprovals.approvedBy.length - 1,
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

class _SupplementSectionState extends StatelessWidget {
  const _SupplementSectionState({
    required this.title,
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final String title;
  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                failed ? 'Unable to load $title.' : 'Loading $title...',
              ),
            ),
            if (loading)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (failed)
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
