import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/diff/diff_file.dart';
import '../../../core/diff/diff_hunk_parser.dart';
import '../../../core/diff/gs_diff_view.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../issues/presentation/issue_components.dart';
import '../data/merge_request_discussion_models.dart';
import '../data/merge_request_models.dart';
import '../data/merge_requests_repository.dart';

/// The merge request changes screen: the full multi-file diff rendered by
/// [GsDiffView], with inline comment threads anchored to their diff lines,
/// a jump-to-file sheet, and the oversized-diff web fallback.
///
/// Tapping a diff line opens a composer that starts a new thread on that
/// line; tapping a thread row opens the thread with its markdown-rendered
/// notes and, for resolvable threads, a resolve/unresolve action. Both
/// writes fold the discussion the server returns straight into local state.
class MergeRequestChangesScreen extends StatefulWidget {
  const MergeRequestChangesScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.mergeIid,
    required this.repository,
    this.webUrl,
    this.openWebUrl,
    this.now,
  });

  final int projectId;
  final String projectPath;
  final int mergeIid;
  final MergeRequestsRepository repository;

  /// The merge request's web URL, when the navigating screen already has it;
  /// otherwise the merge request is fetched to resolve it.
  final String? webUrl;

  /// Overrides how the web fallback opens a URL; defaults to the system
  /// browser via `url_launcher`.
  final Future<void> Function(Uri url)? openWebUrl;

  /// Overrides the reference time for relative note timestamps in tests.
  final DateTime? now;

  @override
  State<MergeRequestChangesScreen> createState() =>
      _MergeRequestChangesScreenState();
}

class _MergeRequestChangesScreenState extends State<MergeRequestChangesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<DiffFile>? _files;
  List<Discussion> _discussions = const [];
  DiffRefs? _diffRefs;
  String? _webUrl;
  bool _loading = true;
  bool _failed = false;
  bool _discussionsFailed = false;
  bool _openingWeb = false;

  @override
  void initState() {
    super.initState();
    _webUrl = widget.webUrl;
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    late final List<DiffFile> files;
    try {
      files = await widget.repository.loadDiffs(
        widget.projectId,
        widget.mergeIid,
      );
      if (!mounted) return;
      setState(() {
        _files = files;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }

    await _loadDiscussions();
  }

  Future<void> _loadDiscussions() async {
    setState(() => _discussionsFailed = false);
    try {
      final discussions = await widget.repository.loadDiscussions(
        widget.projectId,
        widget.mergeIid,
      );
      if (!mounted) return;
      setState(() {
        _discussions = _mergeDiscussions(discussions, _discussions);
      });
    } on Object {
      if (!mounted) return;
      setState(() => _discussionsFailed = true);
    }
  }

  static List<Discussion> _mergeDiscussions(
    List<Discussion> loaded,
    List<Discussion> local,
  ) {
    final localById = {
      for (final discussion in local) discussion.id: discussion,
    };
    return [
      for (final discussion in loaded)
        localById.remove(discussion.id) ?? discussion,
      ...localById.values,
    ];
  }

  Future<void> _openInBrowser() async {
    if (_openingWeb) return;
    _openingWeb = true;
    try {
      var diffsUri = _diffsUri(_webUrl);
      if (diffsUri == null) {
        final webUrl = (await widget.repository.loadMergeRequest(
          widget.projectId,
          widget.mergeIid,
        )).webUrl;
        if (!mounted) return;
        diffsUri = _diffsUri(webUrl);
        if (diffsUri == null) {
          throw StateError('Merge request has no valid web URL.');
        }
        _webUrl = webUrl;
      }
      final open = widget.openWebUrl ?? _launchExternally;
      await open(diffsUri);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open these changes in a browser.'),
        ),
      );
    } finally {
      _openingWeb = false;
    }
  }

  static Uri? _diffsUri(String? webUrl) {
    final value = webUrl?.trim();
    if (value == null || value.isEmpty) return null;
    final base = Uri.tryParse(value);
    if (base == null ||
        (base.scheme != 'http' && base.scheme != 'https') ||
        base.host.isEmpty) {
      return null;
    }
    final directory = base.path.endsWith('/')
        ? base
        : base.replace(path: '${base.path}/');
    return directory.resolve('diffs');
  }

  static Future<void> _launchExternally(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _showFileList(List<DiffFile> files) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: gs.surfaceSheet,
      builder: (sheetContext) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: files.length,
          itemBuilder: (context, index) => ListTile(
            dense: true,
            title: Text(
              files[index].displayPath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: gs.mono.copyWith(color: gs.textDefault),
            ),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _jumpToFile(files, index);
            },
          ),
        ),
      ),
    );
  }

  void _jumpToFile(List<DiffFile> files, int index) {
    final offset = GsDiffView.offsetForFile(
      files,
      index,
      annotations: _annotations(),
    ).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  List<DiffLineAnnotation> _annotations() => [
    for (final discussion in _discussions)
      if (discussion.isDiffThread)
        DiffLineAnnotation(
          path: discussion.position!.newLine != null
              ? discussion.position!.newPath
              : discussion.position!.oldPath,
          oldLine: discussion.position!.oldLine,
          newLine: discussion.position!.newLine,
          builder: (context) => _ThreadRow(
            key: ValueKey('diff-thread-${discussion.id}'),
            discussion: discussion,
            onTap: () => _openThread(discussion.id),
          ),
        ),
  ];

  Future<void> _openThread(String discussionId) async {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final now = widget.now ?? DateTime.now();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: gs.surfaceSheet,
      builder: (sheetContext) {
        final discussion = _discussions.firstWhere(
          (candidate) => candidate.id == discussionId,
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final note in discussion.notes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: IssueCommentCard(
                            author: note.author,
                            timeLabel: formatIssueRelativeTime(
                              note.createdAt,
                              now,
                            ),
                            body: note.body,
                          ),
                        ),
                    ],
                  ),
                ),
                if (discussion.resolvable)
                  FilledButton(
                    key: const ValueKey('toggle-resolved'),
                    onPressed: () => _toggleResolved(sheetContext, discussion),
                    child: Text(
                      discussion.resolved
                          ? 'Unresolve thread'
                          : 'Resolve thread',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleResolved(
    BuildContext sheetContext,
    Discussion discussion,
  ) async {
    try {
      final updated = await widget.repository.setDiscussionResolved(
        widget.projectId,
        widget.mergeIid,
        discussion.id,
        resolved: !discussion.resolved,
      );
      if (!mounted) return;
      setState(() {
        _discussions = [
          for (final existing in _discussions)
            if (existing.id == updated.id) updated else existing,
        ];
      });
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update this thread.')),
      );
    }
  }

  Future<void> _startThread(DiffFile file, DiffLine line) async {
    final gs = Theme.of(context).extension<GsTheme>()!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: gs.surfaceSheet,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _InlineCommentSheet(
          lineLabel:
              '${file.displayPath}:'
              '${line.newLineNumber ?? line.oldLineNumber}',
          onSubmit: (body) => _createThread(file, line, body),
        ),
      ),
    );
  }

  Future<void> _createThread(DiffFile file, DiffLine line, String body) async {
    final diffRefs = _diffRefs ??= (await widget.repository.loadMergeRequest(
      widget.projectId,
      widget.mergeIid,
    )).diffRefs;
    if (diffRefs == null) {
      throw StateError('Merge request has no diff refs to position a comment.');
    }
    final created = await widget.repository.createDiffDiscussion(
      widget.projectId,
      widget.mergeIid,
      body: body,
      position: DiffPosition(
        baseSha: diffRefs.baseSha,
        startSha: diffRefs.startSha,
        headSha: diffRefs.headSha,
        oldPath: file.oldPath,
        newPath: file.newPath,
        oldLine: line.oldLineNumber,
        newLine: line.newLineNumber,
      ),
    );
    if (!mounted) return;
    setState(() => _discussions = [..._discussions, created]);
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final files = _files;
    final unresolvedCount = _discussions
        .where((discussion) => discussion.resolvable && !discussion.resolved)
        .length;
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
          'Changes · !${widget.mergeIid}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(
            color: gs.textHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (files != null && files.length > 1 && !isOversizedDiff(files))
            IconButton(
              key: const ValueKey('jump-to-file'),
              tooltip: 'Jump to file',
              onPressed: () => _showFileList(files),
              icon: GsIcon(GsIconGlyph.fileTree, size: 20, color: gs.accent),
            ),
        ],
        bottom: unresolvedCount == 0
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Container(
                  height: 24,
                  width: double.infinity,
                  color: gs.feedbackWarningBg,
                  alignment: Alignment.center,
                  child: Text(
                    '$unresolvedCount unresolved '
                    '${unresolvedCount == 1 ? 'thread' : 'threads'}',
                    key: const ValueKey('unresolved-threads'),
                    style: gs.caption.copyWith(color: gs.feedbackWarningText),
                  ),
                ),
              ),
      ),
      body: switch (files) {
        null when _loading => const Center(child: CircularProgressIndicator()),
        null => _ChangesFailedState(failed: _failed, onRetry: _load),
        final loaded => SafeArea(
          top: false,
          child: Column(
            children: [
              if (_discussionsFailed)
                _DiscussionLoadFailure(onRetry: _loadDiscussions),
              Expanded(
                child: switch (loaded) {
                  [] => Center(
                    child: Text(
                      'No changes in this merge request.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
                    ),
                  ),
                  _ => GsDiffView(
                    files: loaded,
                    controller: _scrollController,
                    onOpenInBrowser: _openInBrowser,
                    annotations: _annotations(),
                    onLineTap: _startThread,
                  ),
                },
              ),
            ],
          ),
        ),
      },
    );
  }
}

class _DiscussionLoadFailure extends StatelessWidget {
  const _DiscussionLoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Material(
      key: const ValueKey('discussion-load-failed'),
      color: gs.feedbackWarningBg,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Unable to load comments.',
                  style: gs.caption.copyWith(color: gs.feedbackWarningText),
                ),
              ),
              TextButton(
                key: const ValueKey('retry-discussions'),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The fixed-height inline row for one comment thread, anchored beneath the
/// diff line the thread discusses.
class _ThreadRow extends StatelessWidget {
  const _ThreadRow({super.key, required this.discussion, required this.onTap});

  final Discussion discussion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final resolved = discussion.resolved;
    final count = discussion.notes.length;
    return Material(
      color: gs.surfaceCard,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GsIcon(
                resolved ? GsIconGlyph.checkCircle : GsIconGlyph.comments,
                size: 16,
                color: resolved ? gs.textSuccess : gs.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${discussion.notes.first.author.name} · '
                  '$count ${count == 1 ? 'comment' : 'comments'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: gs.textDefault,
                  ),
                ),
              ),
              if (resolved)
                Text(
                  'Resolved',
                  style: gs.caption.copyWith(color: gs.textSuccess),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The composer sheet for starting a new thread on a diff line.
class _InlineCommentSheet extends StatefulWidget {
  const _InlineCommentSheet({required this.lineLabel, required this.onSubmit});

  final String lineLabel;
  final Future<void> Function(String body) onSubmit;

  @override
  State<_InlineCommentSheet> createState() => _InlineCommentSheetState();
}

class _InlineCommentSheetState extends State<_InlineCommentSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.onSubmit(body);
      if (mounted) Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to post this comment.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Comment on ${widget.lineLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: gs.caption.copyWith(color: gs.textSubtle),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('inline-comment-field'),
              controller: _controller,
              enabled: !_sending,
              autofocus: true,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Write a comment (Markdown supported)',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _sending
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const ValueKey('inline-comment-submit'),
                  onPressed: _sending ? null : _submit,
                  child: const Text('Comment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangesFailedState extends StatelessWidget {
  const _ChangesFailedState({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              'Unable to load these changes.',
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
