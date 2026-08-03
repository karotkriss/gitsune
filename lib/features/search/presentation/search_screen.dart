import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/syntax/gs_syntax_theme.dart';
import '../../../core/syntax/language_detection.dart';
import '../../../core/syntax/syntax_highlighter.dart';
import '../../../core/theme/app_theme.dart';
import '../../issues/data/issue_models.dart';
import '../../issues/presentation/issue_components.dart';
import '../data/search_models.dart';
import '../data/search_repository.dart';

/// Explore/Search tab: a query field and results grouped by the entity
/// types GitLab's search API covers here (projects, issues, merge
/// requests, and code). Code search needs the instance's Advanced Search;
/// where the tier lacks it, the code section offers the instance's web
/// search instead.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.repository,
    this.now,
    this.openWebUrl,
  });

  final SearchRepository repository;
  final DateTime? now;

  /// Test seam for the code-search web fallback; the default opens the
  /// URL in the external browser via `url_launcher`.
  final Future<void> Function(Uri url)? openWebUrl;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SectionState<T> {
  List<T> items = const [];
  bool hasMore = false;
  bool loadingMore = false;
  bool loadMoreFailed = false;

  void reset() {
    items = const [];
    hasMore = false;
    loadingMore = false;
    loadMoreFailed = false;
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  String? _searchedTerm;
  bool _loading = false;
  bool _initialError = false;
  int _generation = 0;

  final _projects = _SectionState<SearchProject>();
  final _issues = _SectionState<Issue>();
  final _mergeRequests = _SectionState<SearchMergeRequest>();
  final _code = _SectionState<SearchBlob>();
  bool _codeSearchUnsupported = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String rawTerm) async {
    final term = rawTerm.trim();
    if (term.isEmpty) return;
    final generation = ++_generation;
    setState(() {
      _searchedTerm = term;
      _loading = true;
      _initialError = false;
      _projects.reset();
      _issues.reset();
      _mergeRequests.reset();
      _code.reset();
      _codeSearchUnsupported = false;
    });
    try {
      final results = await Future.wait<Object?>([
        widget.repository.loadFirstProjectsPage(term),
        widget.repository.loadFirstIssuesPage(term),
        widget.repository.loadFirstMergeRequestsPage(term),
        // Null marks the instance as lacking code search, which is a
        // fallback state for the code section, not a failed search.
        widget.repository
            .loadFirstBlobsPage(term)
            .then<SearchPage<SearchBlob>?>((page) => page)
            .catchError(
              (Object _) => null,
              test: (error) => error is CodeSearchUnsupportedException,
            ),
      ]);
      if (!mounted || generation != _generation) return;
      final projectPage = results[0] as SearchPage<SearchProject>;
      final issuePage = results[1] as SearchPage<Issue>;
      final mrPage = results[2] as SearchPage<SearchMergeRequest>;
      final blobPage = results[3] as SearchPage<SearchBlob>?;
      setState(() {
        _projects
          ..items = projectPage.items
          ..hasMore = projectPage.hasMore;
        _issues
          ..items = issuePage.items
          ..hasMore = issuePage.hasMore;
        _mergeRequests
          ..items = mrPage.items
          ..hasMore = mrPage.hasMore;
        if (blobPage == null) {
          _codeSearchUnsupported = true;
        } else {
          _code
            ..items = blobPage.items
            ..hasMore = blobPage.hasMore;
        }
        _loading = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _initialError = true;
      });
    }
  }

  Future<void> _loadMore<T>(
    _SectionState<T> section,
    Future<SearchPage<T>> Function(String term) loadNextPage,
  ) async {
    final term = _searchedTerm;
    if (term == null || section.loadingMore || !section.hasMore) return;
    final generation = _generation;
    setState(() {
      section.loadingMore = true;
      section.loadMoreFailed = false;
    });
    try {
      final page = await loadNextPage(term);
      if (!mounted || generation != _generation) return;
      setState(() {
        section
          ..items = [...section.items, ...page.items]
          ..hasMore = page.hasMore
          ..loadingMore = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        section.loadingMore = false;
        section.loadMoreFailed = true;
      });
    }
  }

  Future<void> _loadMoreProjects() =>
      _loadMore(_projects, widget.repository.loadNextProjectsPage);

  Future<void> _loadMoreIssues() =>
      _loadMore(_issues, widget.repository.loadNextIssuesPage);

  Future<void> _loadMoreMergeRequests() =>
      _loadMore(_mergeRequests, widget.repository.loadNextMergeRequestsPage);

  Future<void> _loadMoreCode() =>
      _loadMore(_code, widget.repository.loadNextBlobsPage);

  Future<void> _openWebCodeSearch() async {
    final term = _searchedTerm;
    if (term == null) return;
    final open = widget.openWebUrl ?? _launchExternally;
    await open(widget.repository.codeSearchWebUrl(term));
  }

  static Future<void> _launchExternally(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  bool get _hasAnyResults =>
      _projects.items.isNotEmpty ||
      _issues.items.isNotEmpty ||
      _mergeRequests.items.isNotEmpty ||
      _code.items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final now = widget.now ?? DateTime.now();
    final term = _searchedTerm;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search', style: gs.screenTitle),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _runSearch,
                      decoration: InputDecoration(
                        hintText:
                            'Search projects, issues, merge requests, '
                            'and code',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: GsIcon(
                            GsIconGlyph.search,
                            size: 18,
                            color: gs.textSubtle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (term == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchMessage(
                  title: 'Search Gitsune',
                  detail:
                      'Find projects, issues, merge requests, and code '
                      'across your GitLab instance.',
                ),
              )
            else if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_initialError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchMessage(
                  title: 'Unable to search.',
                  detail: 'Check your connection, then try again.',
                  actionLabel: 'Try again',
                  onAction: () => _runSearch(term),
                ),
              )
            else if (!_hasAnyResults && !_codeSearchUnsupported)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchMessage(
                  title: 'No results.',
                  detail: 'Nothing matched "$term".',
                ),
              )
            else ...[
              if (_projects.items.isNotEmpty)
                _ResultSection(
                  title: 'Projects',
                  itemCount: _projects.items.length,
                  itemBuilder: (context, index) =>
                      _ProjectResultRow(project: _projects.items[index]),
                  hasMore: _projects.hasMore,
                  loadingMore: _projects.loadingMore,
                  loadMoreFailed: _projects.loadMoreFailed,
                  onLoadMore: _loadMoreProjects,
                ),
              if (_issues.items.isNotEmpty)
                _ResultSection(
                  title: 'Issues',
                  itemCount: _issues.items.length,
                  itemBuilder: (context, index) =>
                      _IssueResultRow(issue: _issues.items[index], now: now),
                  hasMore: _issues.hasMore,
                  loadingMore: _issues.loadingMore,
                  loadMoreFailed: _issues.loadMoreFailed,
                  onLoadMore: _loadMoreIssues,
                ),
              if (_mergeRequests.items.isNotEmpty)
                _ResultSection(
                  title: 'Merge requests',
                  itemCount: _mergeRequests.items.length,
                  itemBuilder: (context, index) => _MergeRequestResultRow(
                    mergeRequest: _mergeRequests.items[index],
                    now: now,
                  ),
                  hasMore: _mergeRequests.hasMore,
                  loadingMore: _mergeRequests.loadingMore,
                  loadMoreFailed: _mergeRequests.loadMoreFailed,
                  onLoadMore: _loadMoreMergeRequests,
                ),
              if (_code.items.isNotEmpty)
                _ResultSection(
                  title: 'Code',
                  itemCount: _code.items.length,
                  itemBuilder: (context, index) =>
                      _BlobResultRow(blob: _code.items[index]),
                  hasMore: _code.hasMore,
                  loadingMore: _code.loadingMore,
                  loadMoreFailed: _code.loadMoreFailed,
                  onLoadMore: _loadMoreCode,
                ),
              if (_codeSearchUnsupported)
                SliverToBoxAdapter(
                  child: _CodeSearchFallback(onOpenWeb: _openWebCodeSearch),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.hasMore,
    required this.loadingMore,
    required this.loadMoreFailed,
    required this.onLoadMore,
  });

  final String title;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: gs.textHeading),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
        if (hasMore)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: loadingMore
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: onLoadMore,
                        child: Text(
                          loadMoreFailed
                              ? 'Unable to load more. Try again'
                              : 'Load more',
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProjectResultRow extends StatelessWidget {
  const _ProjectResultRow({required this.project});

  final SearchProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      label: '${project.nameWithNamespace}. ${project.starCount} stars.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.nameWithNamespace,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: gs.textHeading,
                ),
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: gs.textSubtle,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${project.starCount} stars',
                style: gs.caption.copyWith(color: gs.textSubtle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IssueResultRow extends StatelessWidget {
  const _IssueResultRow({required this.issue, required this.now});

  final Issue issue;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      label:
          '${issue.state.label} issue ${issue.reference}: ${issue.title}. '
          'Opened by ${issue.author.username}. '
          'Updated ${formatIssueRelativeTime(issue.updatedAt, now)}.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IssueStateBadge(state: issue.state),
                  IssueMetadataPill(
                    label: issue.reference,
                    icon: GsIconGlyph.comments,
                  ),
                  Text(
                    '${issue.author.username} · '
                    '${formatIssueRelativeTime(issue.updatedAt, now)}',
                    style: gs.caption.copyWith(color: gs.textSubtle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MergeRequestResultRow extends StatelessWidget {
  const _MergeRequestResultRow({required this.mergeRequest, required this.now});

  final SearchMergeRequest mergeRequest;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      label:
          '${mergeRequest.state.label} merge request '
          '${mergeRequest.reference}: ${mergeRequest.title}. '
          'Opened by ${mergeRequest.author.username}. '
          'Updated ${formatIssueRelativeTime(mergeRequest.updatedAt, now)}.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MergeRequestStateBadge(state: mergeRequest.state),
                  IssueMetadataPill(
                    label: mergeRequest.reference,
                    icon: GsIconGlyph.comments,
                  ),
                  Text(
                    '${mergeRequest.author.username} · '
                    '${formatIssueRelativeTime(mergeRequest.updatedAt, now)}',
                    style: gs.caption.copyWith(color: gs.textSubtle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlobResultRow extends StatelessWidget {
  const _BlobResultRow({required this.blob});

  final SearchBlob blob;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final languageId = detectLanguageId(blob.path);
    final base = gs.mono.copyWith(color: gs.textDefault);
    final syntaxTheme = gsSyntaxTextTheme(gs);
    final lines = blob.data.trimRight().split('\n');
    return Semantics(
      label: 'Code match in ${blob.path}.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blob.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: gs.mono.copyWith(color: gs.textHeading),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gs.surfaceStrong,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in lines)
                      Text.rich(
                        highlightCodeLine(
                          line,
                          languageId: languageId,
                          base: base,
                          theme: syntaxTheme,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

/// The honest stand-in for the code section on instances whose tier lacks
/// Advanced Search: says why there are no in-app code results and offers
/// the instance's web search instead.
class _CodeSearchFallback extends StatelessWidget {
  const _CodeSearchFallback({required this.onOpenWeb});

  final VoidCallback onOpenWeb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Code',
            style: theme.textTheme.titleSmall?.copyWith(color: gs.textHeading),
          ),
          const SizedBox(height: 8),
          Text(
            'Code search needs Advanced Search, which this GitLab '
            'instance does not offer. You can search code on the web '
            'instead.',
            style: theme.textTheme.bodySmall?.copyWith(color: gs.textSubtle),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onOpenWeb,
            child: const Text('Search code in browser'),
          ),
        ],
      ),
    );
  }
}

/// A merge-request-state pill mirroring [IssueStateBadge], but covering the
/// merged/locked states issues don't have.
class _MergeRequestStateBadge extends StatelessWidget {
  const _MergeRequestStateBadge({required this.state});

  final SearchMergeRequestState state;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final (background, foreground) = switch (state) {
      SearchMergeRequestState.opened => (
        gs.feedbackSuccessBg,
        gs.feedbackSuccessText,
      ),
      SearchMergeRequestState.merged => (
        gs.feedbackInfoBg,
        gs.feedbackInfoText,
      ),
      SearchMergeRequestState.closed ||
      SearchMergeRequestState.locked => (gs.surfaceStrong, gs.textDefault),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          state.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
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
