import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/repository/recently_viewed_repository.dart';
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
    this.recentlyViewedCache,
    this.initialIssue,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final int issueIid;
  final IssuesRepository repository;

  /// Serves this issue offline after a previous view; null leaves the screen
  /// network-only until the composition root wires the cache.
  final RecentlyViewedCache? recentlyViewedCache;
  final Issue? initialIssue;
  final DateTime? now;

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  static const _localActor = IssueAuthor(id: 0, username: 'you', name: 'You');

  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _loadedNotes = <IssueNote>[];
  final _createdNotes = <int, IssueNote>{};
  final _localEvents = <IssueNote>[];
  List<IssueLabel> _projectLabels = const [];
  int _nextLocalEventId = -1000000000;
  bool _sendingComment = false;
  bool _triaging = false;
  Issue? _issue;
  bool _issueLoading = true;
  bool _issueFailed = false;
  bool _notesLoading = true;
  bool _notesLoadingMore = false;
  bool _notesInitialFailed = false;
  bool _notesNextFailed = false;
  bool _notesHaveMore = false;
  int _generation = 0;
  int _issueGeneration = 0;
  int _issueStateRevision = 0;
  RecentItemRepository<Issue>? _recentIssue;

  @override
  void initState() {
    super.initState();
    _issue = widget.initialIssue;
    _scrollController.addListener(_handleScroll);
    _rebuildRecentIssue();
    _reload();
  }

  void _rebuildRecentIssue() {
    final cache = widget.recentlyViewedCache;
    _recentIssue = cache == null
        ? null
        : RecentItemRepository(
            cache: cache,
            type: RecentlyViewedType.issue,
            projectId: widget.projectId,
            itemId: widget.issueIid,
            fetch: () =>
                widget.repository.loadIssue(widget.projectId, widget.issueIid),
            decode: Issue.fromJson,
            encode: (issue) => issue.toJson(),
            updatedAt: (issue) => issue.updatedAt,
          );
  }

  @override
  void didUpdateWidget(covariant IssueDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cacheChanged =
        oldWidget.recentlyViewedCache != widget.recentlyViewedCache;
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.issueIid != widget.issueIid ||
        oldWidget.repository != widget.repository ||
        cacheChanged) {
      _issueGeneration++;
      _issueStateRevision++;
      _issue = cacheChanged ? null : widget.initialIssue;
      _loadedNotes.clear();
      _createdNotes.clear();
      _localEvents.clear();
      _projectLabels = const [];
      _commentController.clear();
      _sendingComment = false;
      _triaging = false;
      _notesHaveMore = false;
      _rebuildRecentIssue();
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
    final body = normalizeIssueDraft(_commentController.text);
    if (body.isEmpty || _sendingComment) return;
    final issueGeneration = _issueGeneration;
    setState(() => _sendingComment = true);
    try {
      final note = await widget.repository.createNote(
        widget.projectId,
        widget.issueIid,
        body,
      );
      if (!mounted || issueGeneration != _issueGeneration) return;
      setState(() {
        _createdNotes[note.id] = note;
        _sendingComment = false;
        _commentController.clear();
      });
    } on Object {
      if (!mounted || issueGeneration != _issueGeneration) return;
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
    final issueStateRevision = _issueStateRevision;
    final recent = _recentIssue;
    if (recent != null) {
      // Stale-while-revalidate: serve the cached issue immediately while the
      // network refresh below continues in the background.
      final cached = await recent.readCached();
      if (!mounted ||
          generation != _generation ||
          issueStateRevision != _issueStateRevision) {
        return;
      }
      if (cached != null && _issue == null) {
        setState(() {
          _issue = cached;
          _issueLoading = true;
        });
      }
    }
    try {
      final issue = recent != null
          ? await recent.load()
          : await widget.repository.loadIssue(
              widget.projectId,
              widget.issueIid,
            );
      if (!mounted ||
          generation != _generation ||
          issueStateRevision != _issueStateRevision) {
        return;
      }
      setState(() {
        _issueStateRevision++;
        _issue = issue;
        _issueLoading = false;
      });
    } on Object {
      if (!mounted ||
          generation != _generation ||
          issueStateRevision != _issueStateRevision) {
        return;
      }
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
    final localEventIds = _localEvents.map((event) => event.id).toSet();
    try {
      final page = await widget.repository.loadFirstNotesPage(
        widget.projectId,
        widget.issueIid,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _loadedNotes
          ..clear()
          ..addAll(page.items);
        _localEvents.removeWhere((event) => localEventIds.contains(event.id));
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
        _loadedNotes.addAll(page.items);
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

  Future<void> _editLabels() async {
    final issue = _issue;
    if (issue == null) return;
    final issueGeneration = _issueGeneration;
    final issueStateRevision = _issueStateRevision;
    final List<IssueLabel> options;
    try {
      options = await widget.repository.loadProjectLabels(widget.projectId);
    } on Object {
      if (!mounted ||
          issueGeneration != _issueGeneration ||
          issueStateRevision != _issueStateRevision) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load project labels.')),
      );
      return;
    }
    if (!mounted ||
        issueGeneration != _issueGeneration ||
        issueStateRevision != _issueStateRevision) {
      return;
    }
    final optionsByName = {
      for (final label in issue.labels) label.name: label,
      for (final label in options) label.name: label,
    };
    _projectLabels = optionsByName.values.toList(growable: false);
    final selection = await _showTriagePicker<String>(
      title: 'Labels',
      options: [for (final label in _projectLabels) (label.name, label.name)],
      initial: issue.labels.map((label) => label.name).toSet(),
    );
    if (!mounted ||
        issueGeneration != _issueGeneration ||
        issueStateRevision != _issueStateRevision ||
        selection == null) {
      return;
    }
    await _applyTriage(labels: selection);
  }

  Future<void> _editAssignees() async {
    final issue = _issue;
    if (issue == null) return;
    final issueGeneration = _issueGeneration;
    final issueStateRevision = _issueStateRevision;
    final List<IssueAuthor> options;
    try {
      options = await widget.repository.loadProjectMembers(widget.projectId);
    } on Object {
      if (!mounted ||
          issueGeneration != _issueGeneration ||
          issueStateRevision != _issueStateRevision) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load project members.')),
      );
      return;
    }
    if (!mounted ||
        issueGeneration != _issueGeneration ||
        issueStateRevision != _issueStateRevision) {
      return;
    }
    final optionsById = {
      for (final assignee in issue.assignees) assignee.id: assignee,
      for (final member in options) member.id: member,
    };
    final selection = await _showTriagePicker<int>(
      title: 'Assignees',
      options: [
        for (final member in optionsById.values) (member.id, member.name),
      ],
      initial: issue.assignees.map((assignee) => assignee.id).toSet(),
    );
    if (!mounted ||
        issueGeneration != _issueGeneration ||
        issueStateRevision != _issueStateRevision ||
        selection == null) {
      return;
    }
    await _applyTriage(assigneeIds: selection);
  }

  Future<List<T>?> _showTriagePicker<T>({
    required String title,
    required List<(T, String)> options,
    required Set<T> initial,
  }) {
    final selected = {...initial};
    return showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleSmall,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final (value, label) in options)
                      CheckboxListTile(
                        value: selected.contains(value),
                        title: Text(label),
                        onChanged: (checked) => setSheetState(() {
                          checked ?? false
                              ? selected.add(value)
                              : selected.remove(value);
                        }),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop([
                    for (final (value, _) in options)
                      if (selected.contains(value)) value,
                  ]),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyTriage({
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  }) async {
    final before = _issue;
    if (before == null || _triaging) return;
    final issueGeneration = _issueGeneration;
    setState(() => _triaging = true);
    try {
      final updated = await widget.repository.updateIssue(
        widget.projectId,
        widget.issueIid,
        labels: labels,
        assigneeIds: assigneeIds,
        stateEvent: stateEvent,
      );
      if (!mounted || issueGeneration != _issueGeneration) return;
      final folded = updated.withLabelDetailsFrom([
        ...before.labels,
        ..._projectLabels,
      ]);
      await _recentIssue?.writeThrough(folded);
      if (!mounted || issueGeneration != _issueGeneration) return;
      setState(() {
        _issueStateRevision++;
        _localEvents.addAll(_triageEvents(before, folded));
        _issue = folded;
        _issueLoading = false;
        _issueFailed = false;
        _triaging = false;
      });
    } on Object {
      if (!mounted || issueGeneration != _issueGeneration) return;
      setState(() => _triaging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update the issue.')),
      );
    }
  }

  /// Local stand-ins for the system notes GitLab records server-side, so the
  /// thread reflects a triage change without a refetch.
  List<IssueNote> _triageEvents(Issue before, Issue after) {
    final bodies = <String>[];
    final beforeLabels = before.labels.map((label) => label.name).toSet();
    final afterLabels = after.labels.map((label) => label.name).toSet();
    for (final name in afterLabels.difference(beforeLabels)) {
      bodies.add('added $name label');
    }
    for (final name in beforeLabels.difference(afterLabels)) {
      bodies.add('removed $name label');
    }
    final beforeAssignees = {
      for (final assignee in before.assignees) assignee.id: assignee,
    };
    final afterAssignees = {
      for (final assignee in after.assignees) assignee.id: assignee,
    };
    for (final assignee in afterAssignees.values) {
      if (!beforeAssignees.containsKey(assignee.id)) {
        bodies.add('assigned to @${assignee.username}');
      }
    }
    for (final assignee in beforeAssignees.values) {
      if (!afterAssignees.containsKey(assignee.id)) {
        bodies.add('unassigned @${assignee.username}');
      }
    }
    if (before.state != after.state) {
      bodies.add(after.state == IssueState.closed ? 'closed' : 'reopened');
    }
    final createdAt = widget.now ?? DateTime.now();
    return [
      for (final body in bodies)
        IssueNote(
          id: _nextLocalEventId++,
          body: body,
          author: _localActor,
          createdAt: createdAt,
          system: true,
          internal: false,
        ),
    ];
  }

  List<IssueNote> get _notes {
    final notesById = <int, IssueNote>{
      for (final note in _loadedNotes) note.id: note,
      ..._createdNotes,
      for (final event in _localEvents) event.id: event,
    };
    return notesById.values.toList(growable: false)..sort((left, right) {
      final byCreatedAt = left.createdAt.compareTo(right.createdAt);
      return byCreatedAt != 0 ? byCreatedAt : left.id.compareTo(right.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final issue = _issue;
    final notes = _notes;
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
        actions: [
          if (issue != null)
            PopupMenuButton<_TriageAction>(
              tooltip: 'Issue actions',
              enabled: !_triaging,
              icon: GsIcon(GsIconGlyph.pencil, size: 20, color: gs.accent),
              onSelected: (action) => switch (action) {
                _TriageAction.labels => _editLabels(),
                _TriageAction.assignees => _editAssignees(),
                _TriageAction.state => _applyTriage(
                  stateEvent: issue.state == IssueState.opened
                      ? 'close'
                      : 'reopen',
                ),
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: _TriageAction.labels,
                  child: Text('Edit labels'),
                ),
                const PopupMenuItem(
                  value: _TriageAction.assignees,
                  child: Text('Edit assignees'),
                ),
                PopupMenuItem(
                  value: _TriageAction.state,
                  child: Text(
                    issue.state == IssueState.opened
                        ? 'Close issue'
                        : 'Reopen issue',
                  ),
                ),
              ],
            ),
        ],
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
                            itemCount: notes.length + 2,
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
                              if (index <= notes.length) {
                                final note = notes[index - 1];
                                final timeLabel = formatIssueRelativeTime(
                                  note.createdAt,
                                  now,
                                );
                                return Padding(
                                  key: ValueKey('issue-note-${note.id}'),
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
                                hasNotes: notes.isNotEmpty,
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

enum _TriageAction { labels, assignees, state }

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
    final body = normalizeIssueDraft(controller.text);
    final canSend = !sending && body.isNotEmpty;
    return ColoredBox(
      color: gs.surfaceApp,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (body.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: SingleChildScrollView(
                    child: IssueDraftPreview(draft: body),
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
