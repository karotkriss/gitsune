import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/releases_repository.dart';
import 'release_components.dart';

/// A project's releases (E11.1), newest first as GitLab orders them, bound
/// to the offline-first repository's reactive cache stream. Tapping a row
/// opens the release via [onReleaseTap].
class ReleaseListScreen extends StatefulWidget {
  const ReleaseListScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.repository,
    this.onReleaseTap,
  });

  final int projectId;
  final String projectPath;
  final ReleasesRepository repository;
  final ValueChanged<ReleaseEntry>? onReleaseTap;

  @override
  State<ReleaseListScreen> createState() => _ReleaseListScreenState();
}

class _ReleaseListScreenState extends State<ReleaseListScreen> {
  late Stream<List<ReleaseEntry>> _releases;

  @override
  void initState() {
    super.initState();
    _bindRepository();
  }

  @override
  void didUpdateWidget(covariant ReleaseListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.projectId != widget.projectId) {
      _bindRepository();
    }
  }

  void _bindRepository() {
    _releases = widget.repository.watchReleases(widget.projectId);
    unawaited(_refresh());
  }

  Future<void> _refresh() =>
      widget.repository.refreshReleases(widget.projectId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Releases',
              style: theme.textTheme.titleMedium?.copyWith(
                color: gs.textHeading,
              ),
            ),
            Text(
              widget.projectPath,
              style: gs.caption.copyWith(color: gs.textSubtle),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: gs.accent,
        child: StreamBuilder<List<ReleaseEntry>>(
          stream: _releases,
          builder: (context, snapshot) {
            final releases = snapshot.data;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (releases == null)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (releases.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No releases yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: gs.textSubtle,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: releases.length,
                      itemBuilder: (context, index) => _ReleaseRow(
                        key: ValueKey('release-row-${releases[index].tagName}'),
                        release: releases[index],
                        isFirst: index == 0,
                        isLast: index == releases.length - 1,
                        onTap: widget.onReleaseTap == null
                            ? null
                            : () => widget.onReleaseTap!(releases[index]),
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

class _ReleaseRow extends StatelessWidget {
  const _ReleaseRow({
    super.key,
    required this.release,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final ReleaseEntry release;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );
    return Semantics(
      button: onTap != null,
      label:
          'Release ${release.name}, tag ${release.tagName}, '
          '${formatReleaseDate(release.releasedAt)}',
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
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GsIcon(GsIconGlyph.rocket, size: 16, color: gs.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              release.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: gs.textHeading,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: release.tagName,
                                    style: gs.mono.copyWith(
                                      color: gs.textSubtle,
                                      fontSize: 12,
                                      height: 16 / 12,
                                    ),
                                  ),
                                  const TextSpan(text: ' · '),
                                  TextSpan(
                                    text: formatReleaseDate(
                                      release.releasedAt,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: gs.caption.copyWith(color: gs.textSubtle),
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
