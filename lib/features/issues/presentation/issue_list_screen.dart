import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/issue_models.dart';
import '../data/issues_repository.dart';
import 'issue_components.dart';
import 'issue_detail_screen.dart';

class IssueListScreen extends StatefulWidget {
  const IssueListScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.repository,
    this.onIssueTap,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final IssuesRepository repository;
  final ValueChanged<Issue>? onIssueTap;
  final DateTime? now;

  @override
  State<IssueListScreen> createState() => _IssueListScreenState();
}

class _IssueListScreenState extends State<IssueListScreen> {
  final _scrollController = ScrollController();
  final _issues = <Issue>[];
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
  void didUpdateWidget(covariant IssueListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.repository != widget.repository) {
      _issues.clear();
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
        _issues
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
      if (_issues.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh issues.')),
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
        _issues.addAll(page.items);
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

  void _openIssue(Issue issue) {
    final callback = widget.onIssueTap;
    if (callback != null) {
      callback(issue);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => IssueDetailScreen(
          projectId: widget.projectId,
          projectPath: widget.projectPath,
          issueIid: issue.iid,
          repository: widget.repository,
          initialIssue: issue,
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
          'Issues',
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
            if (_loading && _issues.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_initialError && _issues.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _IssueListMessage(
                  title: 'Unable to load issues.',
                  detail: 'Check your connection, then try again.',
                  actionLabel: 'Try again',
                  onAction: _loadFirstPage,
                ),
              )
            else if (_issues.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _IssueListMessage(
                  title: 'No issues yet.',
                  detail: 'Issues for this project will appear here.',
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: _issues.length,
                  itemBuilder: (context, index) => _IssueListRow(
                    key: ValueKey('issue-row-${_issues[index].iid}'),
                    issue: _issues[index],
                    now: widget.now ?? DateTime.now(),
                    isFirst: index == 0,
                    isLast: index == _issues.length - 1,
                    onTap: () => _openIssue(_issues[index]),
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

class _IssueListRow extends StatelessWidget {
  const _IssueListRow({
    super.key,
    required this.issue,
    required this.now,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final Issue issue;
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
    final labels = issue.labels.map((label) => label.name).join(', ');
    final metadata = StringBuffer(
      '${issue.state.label} issue ${issue.reference}: ${issue.title}. '
      '${issue.userNotesCount} comments. '
      'Opened by ${issue.author.username}. '
      'Updated ${formatIssueRelativeTime(issue.updatedAt, now)}.',
    );
    if (labels.isNotEmpty) metadata.write(' Labels: $labels.');
    return Semantics(
      button: true,
      label: metadata.toString(),
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
                constraints: const BoxConstraints(minHeight: 72),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issue.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: gs.textHeading,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                IssueStateBadge(state: issue.state),
                                IssueMetadataPill(
                                  label: '${issue.userNotesCount}',
                                  icon: GsIconGlyph.comments,
                                ),
                                Text(
                                  '${issue.author.username} · '
                                  '${formatIssueRelativeTime(issue.updatedAt, now)}',
                                  style: gs.caption.copyWith(
                                    color: gs.textSubtle,
                                  ),
                                ),
                              ],
                            ),
                            if (issue.labels.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final label in issue.labels)
                                    IssueLabelPill(label: label),
                                ],
                              ),
                            ],
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

class _IssueListMessage extends StatelessWidget {
  const _IssueListMessage({
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
