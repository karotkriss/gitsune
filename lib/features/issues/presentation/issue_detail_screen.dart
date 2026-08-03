import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/issue_models.dart';
import '../data/issues_repository.dart';
import 'issue_components.dart';

class IssueDetailScreen extends StatefulWidget {
  const IssueDetailScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.issueIid,
    required this.repository,
    this.initialIssue,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final int issueIid;
  final IssuesRepository repository;
  final Issue? initialIssue;
  final DateTime? now;

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _notes = <IssueNote>[];
  bool _sendingComment = false;
  Issue? _issue;
  bool _issueLoading = true;
  bool _issueFailed = false;
  bool _notesLoading = true;
  bool _notesLoadingMore = false;
  bool _notesInitialFailed = false;
  bool _notesNextFailed = false;
  bool _notesHaveMore = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _issue = widget.initialIssue;
    _scrollController.addListener(_handleScroll);
    _reload();
  }

  @override
  void didUpdateWidget(covariant IssueDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.issueIid != widget.issueIid ||
        oldWidget.repository != widget.repository) {
      _issue = widget.initialIssue;
      _notes.clear();
      _notesHaveMore = false;
      _reload();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _sendingComment) return;
    setState(() => _sendingComment = true);
    try {
      final note = await widget.repository.createNote(
        widget.projectId,
        widget.issueIid,
        body,
      );
      if (!mounted) return;
      setState(() {
        _notes.add(note);
        _sendingComment = false;
        _commentController.clear();
      });
    } on Object {
      if (!mounted) return;
      setState(() => _sendingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to post the comment.')),
      );
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 240) {
      return;
    }
    _loadNextNotesPage();
  }

  Future<void> _reload() async {
    final generation = ++_generation;
    setState(() {
      _issueLoading = true;
      _issueFailed = false;
      _notesLoading = true;
      _notesLoadingMore = false;
      _notesInitialFailed = false;
      _notesNextFailed = false;
    });
    await Future.wait([_refreshIssue(generation), _refreshNotes(generation)]);
  }

  Future<void> _refreshIssue(int generation) async {
    try {
      final issue = await widget.repository.loadIssue(
        widget.projectId,
        widget.issueIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _issue = issue;
        _issueLoading = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _issueLoading = false;
        _issueFailed = true;
      });
      if (_issue != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh this issue.')),
        );
      }
    }
  }

  Future<void> _refreshNotes(int generation) async {
    try {
      final page = await widget.repository.loadFirstNotesPage(
        widget.projectId,
        widget.issueIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _notes
          ..clear()
          ..addAll(page.items);
        _notesHaveMore = page.hasMore;
        _notesLoading = false;
      });
      _scheduleNotesFill();
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _notesLoading = false;
        _notesInitialFailed = true;
      });
      if (_notes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh comments.')),
        );
      }
    }
  }

  Future<void> _retryFirstNotesPage() async {
    final generation = _generation;
    setState(() {
      _notesLoading = true;
      _notesInitialFailed = false;
    });
    await _refreshNotes(generation);
  }

  Future<void> _loadNextNotesPage() async {
    if (_notesLoading ||
        _notesLoadingMore ||
        _notesInitialFailed ||
        !_notesHaveMore ||
        _notesNextFailed) {
      return;
    }
    final generation = _generation;
    setState(() {
      _notesLoadingMore = true;
      _notesNextFailed = false;
    });
    try {
      final page = await widget.repository.loadNextNotesPage(
        widget.projectId,
        widget.issueIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _notes.addAll(page.items);
        _notesHaveMore = page.hasMore;
        _notesLoadingMore = false;
      });
      _scheduleNotesFill();
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _notesLoadingMore = false;
        _notesNextFailed = true;
      });
    }
  }

  void _retryNextNotesPage() {
    setState(() => _notesNextFailed = false);
    _loadNextNotesPage();
  }

  void _scheduleNotesFill() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.extentAfter <= 240) {
        _loadNextNotesPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final issue = _issue;
    final now = widget.now ?? DateTime.now();
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
          '${widget.projectPath} · #${widget.issueIid}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(
            color: gs.textHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: issue == null
          ? _DetailInitialState(
              loading: _issueLoading,
              failed: _issueFailed,
              onRetry: _reload,
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _reload,
                    color: gs.accent,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (_issueLoading)
                          const SliverToBoxAdapter(
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                        SliverToBoxAdapter(
                          child: _IssueHeader(
                            issue: issue,
                            projectPath: widget.projectPath,
                            now: now,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          sliver: SliverList.builder(
                            itemCount: _notes.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: IssueCommentCard(
                                    author: issue.author,
                                    timeLabel: formatIssueRelativeTime(
                                      issue.createdAt,
                                      now,
                                    ),
                                    body: issue.description,
                                    opening: true,
                                  ),
                                );
                              }
                              if (index <= _notes.length) {
                                final note = _notes[index - 1];
                                final timeLabel = formatIssueRelativeTime(
                                  note.createdAt,
                                  now,
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: note.system
                                      ? IssueSystemEvent(
                                          note: note,
                                          timeLabel: timeLabel,
                                        )
                                      : IssueCommentCard(
                                          author: note.author,
                                          timeLabel: timeLabel,
                                          body: note.body,
                                          internal: note.internal,
                                        ),
                                );
                              }
                              return _NotesFooter(
                                hasNotes: _notes.isNotEmpty,
                                loading: _notesLoading || _notesLoadingMore,
                                firstPageFailed: _notesInitialFailed,
                                nextPageFailed: _notesNextFailed,
                                onRetryFirst: _retryFirstNotesPage,
                                onRetryNext: _retryNextNotesPage,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _CommentComposer(
                  controller: _commentController,
                  sending: _sendingComment,
                  onChanged: (_) => setState(() {}),
                  onSend: _sendComment,
                ),
              ],
            ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.sending,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final canSend = !sending && controller.text.trim().isNotEmpty;
    return ColoredBox(
      color: gs.surfaceApp,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.trim().isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: SingleChildScrollView(
                    child: IssueDraftPreview(draft: controller.text),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !sending,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment (Markdown supported)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (sending)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: 'Send comment',
                      onPressed: canSend ? onSend : null,
                      icon: GsIcon(
                        GsIconGlyph.paperAirplane,
                        size: 20,
                        color: canSend ? gs.accent : gs.statusNeutral,
                      ),
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

class _IssueHeader extends StatelessWidget {
  const _IssueHeader({
    required this.issue,
    required this.projectPath,
    required this.now,
  });

  final Issue issue;
  final String projectPath;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return ColoredBox(
      color: gs.surfaceApp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IssueStateBadge(state: issue.state),
                Text(
                  '${issue.author.username} opened '
                  '${formatIssueRelativeTime(issue.createdAt, now)}',
                  style: gs.caption.copyWith(color: gs.textSubtle),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Semantics(
              header: true,
              child: Text(
                issue.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: gs.textHeading,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Issue metadata',
              container: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    IssueMetadataPill(label: projectPath),
                    for (final label in issue.labels) ...[
                      const SizedBox(width: 6),
                      IssueLabelPill(label: label),
                    ],
                    if (issue.milestoneTitle case final milestone?) ...[
                      const SizedBox(width: 6),
                      IssueMetadataPill(
                        label: milestone,
                        icon: GsIconGlyph.milestone,
                      ),
                    ],
                    for (final assignee in issue.assignees) ...[
                      const SizedBox(width: 6),
                      IssueMetadataPill(
                        label: assignee.name,
                        icon: GsIconGlyph.assignee,
                      ),
                    ],
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
    if (failed) return _DetailError(onRetry: onRetry);
    return const SizedBox.shrink();
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

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
              'Unable to load this issue.',
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

class _NotesFooter extends StatelessWidget {
  const _NotesFooter({
    required this.hasNotes,
    required this.loading,
    required this.firstPageFailed,
    required this.nextPageFailed,
    required this.onRetryFirst,
    required this.onRetryNext,
  });

  final bool hasNotes;
  final bool loading;
  final bool firstPageFailed;
  final bool nextPageFailed;
  final VoidCallback onRetryFirst;
  final VoidCallback onRetryNext;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (firstPageFailed) {
      return _CommentsError(
        message: 'Unable to load comments.',
        onRetry: onRetryFirst,
      );
    }
    if (nextPageFailed) {
      return _CommentsError(
        message: 'Unable to load more comments.',
        onRetry: onRetryNext,
      );
    }
    if (!hasNotes) return const _NoComments();
    return const SizedBox(height: 16);
  }
}

class _CommentsError extends StatelessWidget {
  const _CommentsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(onPressed: onRetry, child: Text('$message Try again')),
  );
}

class _NoComments extends StatelessWidget {
  const _NoComments();

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'No comments yet.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
      ),
    );
  }
}
