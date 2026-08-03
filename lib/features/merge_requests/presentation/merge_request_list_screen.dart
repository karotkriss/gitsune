import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/merge_request_models.dart';
import '../data/merge_requests_repository.dart';
import 'merge_request_components.dart';
import 'merge_request_detail_screen.dart';

class MergeRequestListScreen extends StatefulWidget {
  const MergeRequestListScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.repository,
    this.onMergeRequestTap,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final MergeRequestsRepository repository;
  final ValueChanged<MergeRequest>? onMergeRequestTap;
  final DateTime? now;

  @override
  State<MergeRequestListScreen> createState() => _MergeRequestListScreenState();
}

class _MergeRequestListScreenState extends State<MergeRequestListScreen> {
  final _scrollController = ScrollController();
  final _mergeRequests = <MergeRequest>[];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _initialError = false;
  bool _nextPageError = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadFirstPage();
  }

  @override
  void didUpdateWidget(covariant MergeRequestListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.repository != widget.repository) {
      _mergeRequests.clear();
      _loadFirstPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 240) {
      return;
    }
    _loadNextPage();
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _initialError = false;
      _nextPageError = false;
    });
    try {
      final page = await widget.repository.loadFirstPage(widget.projectId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _mergeRequests
          ..clear()
          ..addAll(page.items);
        _hasMore = page.hasMore;
        _loading = false;
      });
      _scheduleViewportFill();
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _initialError = true;
      });
      if (_mergeRequests.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh merge requests.')),
        );
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _nextPageError = false;
    });
    final generation = _generation;
    try {
      final page = await widget.repository.loadNextPage(widget.projectId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _mergeRequests.addAll(page.items);
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
      _scheduleViewportFill();
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loadingMore = false;
        _nextPageError = true;
      });
    }
  }

  void _scheduleViewportFill() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.extentAfter <= 240) {
        _loadNextPage();
      }
    });
  }

  void _openMergeRequest(MergeRequest mergeRequest) {
    final callback = widget.onMergeRequestTap;
    if (callback != null) {
      callback(mergeRequest);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MergeRequestDetailScreen(
          projectId: widget.projectId,
          projectPath: widget.projectPath,
          mergeIid: mergeRequest.iid,
          repository: widget.repository,
          initialMergeRequest: mergeRequest,
          now: widget.now,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: gs.surfaceApp,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: Navigator.of(context).pop,
                icon: GsIcon(
                  GsIconGlyph.chevronLeft,
                  size: 20,
                  color: gs.accent,
                ),
              )
            : null,
        title: Text(
          'Merge Requests',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFirstPage,
        color: gs.accent,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Text(
                  widget.projectPath,
                  style: gs.mono.copyWith(color: gs.textSubtle),
                ),
              ),
            ),
            if (_loading && _mergeRequests.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_initialError && _mergeRequests.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MergeRequestListMessage(
                  title: 'Unable to load merge requests.',
                  detail: 'Check your connection, then try again.',
                  actionLabel: 'Try again',
                  onAction: _loadFirstPage,
                ),
              )
            else if (_mergeRequests.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _MergeRequestListMessage(
                  title: 'No merge requests yet.',
                  detail: 'Merge requests for this project will appear here.',
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: _mergeRequests.length,
                  itemBuilder: (context, index) => _MergeRequestListRow(
                    key: ValueKey(
                      'merge-request-row-${_mergeRequests[index].iid}',
                    ),
                    mergeRequest: _mergeRequests[index],
                    now: widget.now ?? DateTime.now(),
                    isFirst: index == 0,
                    isLast: index == _mergeRequests.length - 1,
                    onTap: () => _openMergeRequest(_mergeRequests[index]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _PaginationFooter(
                  loading: _loadingMore,
                  failed: _nextPageError,
                  onRetry: _loadNextPage,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MergeRequestListRow extends StatelessWidget {
  const _MergeRequestListRow({
    super.key,
    required this.mergeRequest,
    required this.now,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final MergeRequest mergeRequest;
  final DateTime now;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );
    final updated = formatMergeRequestRelativeTime(mergeRequest.updatedAt, now);
    return Semantics(
      button: true,
      onTap: onTap,
      label:
          '${mergeRequest.displayStateLabel} merge request '
          '${mergeRequest.reference}: ${mergeRequest.title}. '
          'Source branch ${mergeRequest.sourceBranch}, target branch '
          '${mergeRequest.targetBranch}. ${mergeRequest.userNotesCount} '
          'comments. Updated $updated by ${mergeRequest.author.username}.',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gs.surfaceCard,
            border: Border(
              top: isFirst
                  ? BorderSide(color: gs.borderSubtle)
                  : BorderSide.none,
              left: BorderSide(color: gs.borderSubtle),
              right: BorderSide(color: gs.borderSubtle),
              bottom: BorderSide(color: gs.borderSubtle),
            ),
            borderRadius: radius,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 88),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mergeRequest.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: gs.textHeading,
                              ),
                            ),
                            const SizedBox(height: 8),
                            MergeRequestBranchPath(
                              source: mergeRequest.sourceBranch,
                              target: mergeRequest.targetBranch,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                MergeRequestStateBadge(
                                  state: mergeRequest.state,
                                  draft: mergeRequest.draft,
                                ),
                                Text(
                                  mergeRequest.reference,
                                  style: gs.mono.copyWith(color: gs.textSubtle),
                                ),
                                Text(
                                  '${mergeRequest.author.username} · $updated',
                                  style: gs.caption.copyWith(
                                    color: gs.textSubtle,
                                  ),
                                ),
                                if (mergeRequest.userNotesCount > 0)
                                  _CommentCount(
                                    count: mergeRequest.userNotesCount,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GsIcon(
                        GsIconGlyph.chevronRight,
                        size: 16,
                        color: gs.statusNeutral,
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

class _CommentCount extends StatelessWidget {
  const _CommentCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GsIcon(GsIconGlyph.comments, size: 12, color: gs.textSubtle),
        const SizedBox(width: 3),
        Text('$count', style: gs.caption.copyWith(color: gs.textSubtle)),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (failed) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(
            onPressed: onRetry,
            child: const Text('Unable to load more. Try again'),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _MergeRequestListMessage extends StatelessWidget {
  const _MergeRequestListMessage({
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
