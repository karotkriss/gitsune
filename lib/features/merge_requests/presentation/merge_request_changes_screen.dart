import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/diff/diff_file.dart';
import '../../../core/diff/gs_diff_view.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/merge_requests_repository.dart';

/// The merge request changes screen: the full multi-file diff rendered by
/// [GsDiffView], with a jump-to-file sheet and the oversized-diff web
/// fallback.
class MergeRequestChangesScreen extends StatefulWidget {
  const MergeRequestChangesScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.mergeIid,
    required this.repository,
    this.webUrl,
    this.openWebUrl,
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

  @override
  State<MergeRequestChangesScreen> createState() =>
      _MergeRequestChangesScreenState();
}

class _MergeRequestChangesScreenState extends State<MergeRequestChangesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<DiffFile>? _files;
  String? _webUrl;
  bool _loading = true;
  bool _failed = false;

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
    try {
      final files = await widget.repository.loadDiffs(
        widget.projectId,
        widget.mergeIid,
      );
      if (_webUrl == null && isOversizedDiff(files)) {
        _webUrl = (await widget.repository.loadMergeRequest(
          widget.projectId,
          widget.mergeIid,
        )).webUrl;
      }
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
    }
  }

  Future<void> _openInBrowser() async {
    final webUrl = _webUrl;
    if (webUrl == null) return;
    final open = widget.openWebUrl ?? _launchExternally;
    await open(Uri.parse('$webUrl/diffs'));
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
    ).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final files = _files;
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
      ),
      body: switch (files) {
        null when _loading => const Center(child: CircularProgressIndicator()),
        null => _ChangesFailedState(failed: _failed, onRetry: _load),
        [] => Center(
          child: Text(
            'No changes in this merge request.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
          ),
        ),
        final loaded => SafeArea(
          top: false,
          child: GsDiffView(
            files: loaded,
            controller: _scrollController,
            onOpenInBrowser: _openInBrowser,
          ),
        ),
      },
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
