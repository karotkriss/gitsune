import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../search/data/search_models.dart';
import '../data/projects_repository.dart';

/// The Home "Projects" tile's destination: the projects the signed-in user
/// is a member of, most recently active first, in the same paginated
/// card-list treatment as the project issue and merge request lists.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({
    super.key,
    required this.repository,
    this.onProjectTap,
  });

  final ProjectsRepository repository;
  final ValueChanged<SearchProject>? onProjectTap;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _scrollController = ScrollController();
  final _projects = <SearchProject>[];
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
      final page = await widget.repository.loadFirstPage();
      if (!mounted || generation != _generation) return;
      setState(() {
        _projects
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
      if (_projects.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh projects.')),
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
      final page = await widget.repository.loadNextPage();
      if (!mounted || generation != _generation) return;
      setState(() {
        _projects.addAll(page.items);
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
          'Projects',
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
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (_loading && _projects.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_initialError && _projects.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ProjectsMessage(
                  title: 'Unable to load projects.',
                  detail: 'Check your connection, then try again.',
                  actionLabel: 'Try again',
                  onAction: _loadFirstPage,
                ),
              )
            else if (_projects.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _ProjectsMessage(
                  title: 'No projects yet.',
                  detail: 'Projects you are a member of appear here.',
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) => _ProjectRow(
                    key: ValueKey('project-row-${_projects[index].id}'),
                    project: _projects[index],
                    isFirst: index == 0,
                    isLast: index == _projects.length - 1,
                    onTap: () => widget.onProjectTap?.call(_projects[index]),
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

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    super.key,
    required this.project,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final SearchProject project;
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
    final metadata = StringBuffer(
      '${project.nameWithNamespace}. ${project.starCount} stars.',
    );
    if (project.description.isNotEmpty) {
      metadata.write(' ${project.description}');
    }
    return Semantics(
      button: true,
      onTap: onTap,
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
                constraints: const BoxConstraints(minHeight: 64),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
                  child: Row(
                    children: [
                      Expanded(
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
                            Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GsIcon(
                                  GsIconGlyph.star,
                                  size: 12,
                                  color: gs.textSubtle,
                                ),
                                Text(
                                  '${project.starCount}',
                                  style: gs.caption.copyWith(
                                    color: gs.textSubtle,
                                  ),
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

class _ProjectsMessage extends StatelessWidget {
  const _ProjectsMessage({
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
