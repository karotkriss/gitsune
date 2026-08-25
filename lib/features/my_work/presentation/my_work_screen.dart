import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../issues/data/issue_models.dart';
import '../../issues/presentation/issue_list_screen.dart';
import '../../merge_requests/data/merge_request_models.dart';
import '../../merge_requests/presentation/merge_request_list_screen.dart';
import '../data/my_work_repository.dart';

/// The Home "Issues" tile's destination: the signed-in user's open issues
/// across every project, toggling between assigned and authored scopes.
class MyIssuesScreen extends StatelessWidget {
  const MyIssuesScreen({
    super.key,
    required this.repository,
    this.onIssueTap,
    this.now,
  });

  final MyWorkRepository repository;
  final ValueChanged<Issue>? onIssueTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return _MyWorkList<Issue>(
      title: 'My Issues',
      itemNoun: 'issues',
      emptyDetailOf: (scope) => switch (scope) {
        MyWorkScope.assigned => 'Open issues assigned to you appear here.',
        MyWorkScope.authored => 'Open issues you opened appear here.',
      },
      loadFirst: (scope) async {
        final page = await repository.loadFirstIssuesPage(scope);
        return (items: page.items, hasMore: page.hasMore);
      },
      loadNext: (scope) async {
        final page = await repository.loadNextIssuesPage(scope);
        return (items: page.items, hasMore: page.hasMore);
      },
      rowBuilder: (context, issue, {required isFirst, required isLast}) =>
          IssueListRow(
            key: ValueKey('my-issue-row-${issue.id}'),
            issue: issue,
            now: now ?? DateTime.now(),
            isFirst: isFirst,
            isLast: isLast,
            onTap: () => onIssueTap?.call(issue),
          ),
    );
  }
}

/// The Home "Merge Requests" tile's destination: the signed-in user's open
/// merge requests across every project, toggling between assigned and
/// authored scopes.
class MyMergeRequestsScreen extends StatelessWidget {
  const MyMergeRequestsScreen({
    super.key,
    required this.repository,
    this.onMergeRequestTap,
    this.now,
  });

  final MyWorkRepository repository;
  final ValueChanged<MergeRequest>? onMergeRequestTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return _MyWorkList<MergeRequest>(
      title: 'My Merge Requests',
      itemNoun: 'merge requests',
      emptyDetailOf: (scope) => switch (scope) {
        MyWorkScope.assigned =>
          'Open merge requests assigned to you appear here.',
        MyWorkScope.authored => 'Open merge requests you opened appear here.',
      },
      loadFirst: (scope) async {
        final page = await repository.loadFirstMergeRequestsPage(scope);
        return (items: page.items, hasMore: page.hasMore);
      },
      loadNext: (scope) async {
        final page = await repository.loadNextMergeRequestsPage(scope);
        return (items: page.items, hasMore: page.hasMore);
      },
      rowBuilder:
          (context, mergeRequest, {required isFirst, required isLast}) =>
              MergeRequestListRow(
                key: ValueKey('my-mr-row-${mergeRequest.id}'),
                mergeRequest: mergeRequest,
                now: now ?? DateTime.now(),
                isFirst: isFirst,
                isLast: isLast,
                onTap: () => onMergeRequestTap?.call(mergeRequest),
              ),
    );
  }
}

typedef _MyWorkPage<T> = ({List<T> items, bool hasMore});

typedef _MyWorkRowBuilder<T> =
    Widget Function(
      BuildContext context,
      T item, {
      required bool isFirst,
      required bool isLast,
    });

/// The shared My Work list scaffold: an assigned/authored scope toggle over
/// the same paginated card-list treatment as the project issue and merge
/// request lists.
class _MyWorkList<T> extends StatefulWidget {
  const _MyWorkList({
    required this.title,
    required this.itemNoun,
    required this.emptyDetailOf,
    required this.loadFirst,
    required this.loadNext,
    required this.rowBuilder,
  });

  final String title;
  final String itemNoun;
  final String Function(MyWorkScope scope) emptyDetailOf;
  final Future<_MyWorkPage<T>> Function(MyWorkScope scope) loadFirst;
  final Future<_MyWorkPage<T>> Function(MyWorkScope scope) loadNext;
  final _MyWorkRowBuilder<T> rowBuilder;

  @override
  State<_MyWorkList<T>> createState() => _MyWorkListState<T>();
}

class _MyWorkListState<T> extends State<_MyWorkList<T>> {
  final _scrollController = ScrollController();
  final _items = <T>[];
  var _scope = MyWorkScope.assigned;
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
      final page = await widget.loadFirst(_scope);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items
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
      if (_items.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to refresh ${widget.itemNoun}.')),
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
      final page = await widget.loadNext(_scope);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items.addAll(page.items);
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

  void _switchScope(MyWorkScope scope) {
    if (scope == _scope) return;
    setState(() {
      _scope = scope;
      _items.clear();
    });
    _loadFirstPage();
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
          widget.title,
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
                child: SegmentedButton<MyWorkScope>(
                  segments: const [
                    ButtonSegment(
                      value: MyWorkScope.assigned,
                      label: Text('Assigned to me'),
                    ),
                    ButtonSegment(
                      value: MyWorkScope.authored,
                      label: Text('Authored by me'),
                    ),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (selection) =>
                      _switchScope(selection.single),
                ),
              ),
            ),
            if (_loading && _items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_initialError && _items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MyWorkMessage(
                  title: 'Unable to load ${widget.itemNoun}.',
                  detail: 'Check your connection, then try again.',
                  actionLabel: 'Try again',
                  onAction: _loadFirstPage,
                ),
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MyWorkMessage(
                  title: 'Nothing here yet.',
                  detail: widget.emptyDetailOf(_scope),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) => widget.rowBuilder(
                    context,
                    _items[index],
                    isFirst: index == 0,
                    isLast: index == _items.length - 1,
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

class _MyWorkMessage extends StatelessWidget {
  const _MyWorkMessage({
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
