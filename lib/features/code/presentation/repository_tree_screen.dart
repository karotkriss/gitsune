import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/icons/gs_file_icons.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/repository_tree_repository.dart';

/// One directory level of a project's repository tree (E9.1): a breadcrumb
/// for the current [path] and the directory's entries, folders first as
/// GitLab orders them. Tapping a folder drills one level down via
/// [onDirectoryTap]; tapping a breadcrumb ancestor jumps back up via
/// [onAncestorTap] (`''` is the repository root); tapping a file opens it
/// via [onFileTap] (the E9.2 file view).
class RepositoryTreeScreen extends StatefulWidget {
  const RepositoryTreeScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.repository,
    this.ref = '',
    this.path = '',
    this.onDirectoryTap,
    this.onFileTap,
    this.onAncestorTap,
  });

  final int projectId;
  final String projectPath;
  final RepositoryTreeRepository repository;

  /// The ref being browsed, `''` for the project's default branch.
  final String ref;

  /// The directory being listed, `''` for the repository root.
  final String path;

  final ValueChanged<RepositoryTreeEntry>? onDirectoryTap;
  final ValueChanged<RepositoryTreeEntry>? onFileTap;
  final ValueChanged<String>? onAncestorTap;

  @override
  State<RepositoryTreeScreen> createState() => _RepositoryTreeScreenState();
}

class _RepositoryTreeScreenState extends State<RepositoryTreeScreen> {
  late Stream<List<RepositoryTreeEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _bindRepository();
  }

  @override
  void didUpdateWidget(covariant RepositoryTreeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.ref != widget.ref ||
        oldWidget.path != widget.path) {
      _bindRepository();
    }
  }

  void _bindRepository() {
    _entries = widget.repository.watchDirectory(
      widget.projectId,
      ref: widget.ref,
      path: widget.path,
    );
    unawaited(_refresh());
  }

  Future<void> _refresh() => widget.repository.refreshDirectory(
    widget.projectId,
    ref: widget.ref,
    path: widget.path,
  );

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
          'Repository',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: gs.accent,
        child: StreamBuilder<List<RepositoryTreeEntry>>(
          stream: _entries,
          builder: (context, snapshot) {
            final entries = snapshot.data;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Breadcrumb(
                    projectPath: widget.projectPath,
                    path: widget.path,
                    onAncestorTap: widget.onAncestorTap,
                  ),
                ),
                if (entries == null)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (entries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'This directory is empty.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) => _TreeEntryRow(
                        key: ValueKey('tree-entry-${entries[index].path}'),
                        entry: entries[index],
                        isFirst: index == 0,
                        isLast: index == entries.length - 1,
                        onTap: entries[index].entryType == 'tree'
                            ? () => widget.onDirectoryTap?.call(entries[index])
                            : () => widget.onFileTap?.call(entries[index]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The tappable path back up the tree: the project name (repository root)
/// followed by one crumb per directory segment of the current path.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.projectPath,
    required this.path,
    required this.onAncestorTap,
  });

  final String projectPath;
  final String path;
  final ValueChanged<String>? onAncestorTap;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final segments = path.isEmpty ? const <String>[] : path.split('/');
    final projectName = projectPath.split('/').last;
    final crumbs = <Widget>[
      _crumb(
        context,
        label: projectName,
        ancestorPath: '',
        isCurrent: segments.isEmpty,
      ),
    ];
    for (var i = 0; i < segments.length; i++) {
      crumbs
        ..add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('/', style: gs.mono.copyWith(color: gs.textSubtle)),
          ),
        )
        ..add(
          _crumb(
            context,
            label: segments[i],
            ancestorPath: segments.sublist(0, i + 1).join('/'),
            isCurrent: i == segments.length - 1,
          ),
        );
    }
    // Reversed so a deep path starts scrolled to the current directory; the
    // minWidth constraint keeps a short path left-aligned despite that.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth - 32),
          child: Row(children: crumbs),
        ),
      ),
    );
  }

  Widget _crumb(
    BuildContext context, {
    required String label,
    required String ancestorPath,
    required bool isCurrent,
  }) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    if (isCurrent) {
      return Text(label, style: gs.mono.copyWith(color: gs.textHeading));
    }
    return InkWell(
      onTap: () => onAncestorTap?.call(ancestorPath),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(label, style: gs.mono.copyWith(color: gs.accent)),
      ),
    );
  }
}

class _TreeEntryRow extends StatelessWidget {
  const _TreeEntryRow({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final RepositoryTreeEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final isDirectory = entry.entryType == 'tree';
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );
    return Semantics(
      button: isDirectory,
      label: isDirectory ? 'Directory ${entry.name}' : 'File ${entry.name}',
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
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      if (isDirectory)
                        GsIcon(
                          GsIconGlyph.folderOutline,
                          size: 16,
                          color: gs.textSubtle,
                        )
                      else
                        GsFileIcon(fileIconGlyphFor(entry.name)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: gs.textHeading,
                          ),
                        ),
                      ),
                      if (isDirectory) ...[
                        const SizedBox(width: 8),
                        GsIcon(
                          GsIconGlyph.chevronRight,
                          size: 16,
                          color: gs.statusNeutral,
                        ),
                      ],
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
