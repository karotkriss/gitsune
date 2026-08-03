import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/markdown/gs_markdown.dart';
import '../../../core/theme/app_theme.dart';
import '../data/releases_repository.dart';
import 'release_components.dart';

/// One release of a project (E11.1): name, tag, date, the release notes
/// rendered as markdown, and the release's asset links. Reads the
/// offline-first cache stream, so a release opened from the list renders
/// without waiting on the network.
class ReleaseDetailScreen extends StatefulWidget {
  const ReleaseDetailScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.tagName,
    required this.repository,
  });

  final int projectId;
  final String projectPath;
  final String tagName;
  final ReleasesRepository repository;

  @override
  State<ReleaseDetailScreen> createState() => _ReleaseDetailScreenState();
}

class _ReleaseDetailScreenState extends State<ReleaseDetailScreen> {
  late Stream<ReleaseEntry?> _release;

  @override
  void initState() {
    super.initState();
    _bindRepository();
  }

  @override
  void didUpdateWidget(covariant ReleaseDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.tagName != widget.tagName) {
      _bindRepository();
    }
  }

  void _bindRepository() {
    _release = widget.repository.watchRelease(widget.projectId, widget.tagName);
    unawaited(widget.repository.refreshReleases(widget.projectId));
  }

  Future<void> _openLink(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);

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
              'Release',
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
      body: StreamBuilder<ReleaseEntry?>(
        stream: _release,
        builder: (context, snapshot) {
          final release = snapshot.data;
          if (release == null) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Text(
                      'Release not found.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gs.textSubtle,
                      ),
                    ),
                  );
          }
          return _ReleaseDetailBody(release: release, onLinkTap: _openLink);
        },
      ),
    );
  }
}

class _ReleaseDetailBody extends StatelessWidget {
  const _ReleaseDetailBody({required this.release, required this.onLinkTap});

  final ReleaseEntry release;
  final ValueChanged<Uri> onLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final assetLinks = releaseAssetLinks(release);
    final authorName = release.authorName;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(release.name, style: gs.screenTitle),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            GsIcon(GsIconGlyph.rocket, size: 14, color: gs.accent),
            Text(
              release.tagName,
              style: gs.mono.copyWith(color: gs.textSubtle, fontSize: 12),
            ),
            Text(
              formatReleaseDate(release.releasedAt),
              style: gs.caption.copyWith(color: gs.textSubtle),
            ),
            if (authorName != null && authorName.isNotEmpty)
              Text(
                'by $authorName',
                style: gs.caption.copyWith(color: gs.textSubtle),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: gs.borderSubtle),
        const SizedBox(height: 16),
        if (release.description.isEmpty)
          Text(
            'No release notes.',
            style: theme.textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
          )
        else
          GsMarkdown(data: release.description, onLinkTap: onLinkTap),
        if (assetLinks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Assets',
            style: theme.textTheme.titleSmall?.copyWith(color: gs.textHeading),
          ),
          const SizedBox(height: 8),
          for (final link in assetLinks)
            _AssetLinkRow(
              link: link,
              onTap: () => onLinkTap(Uri.parse(link.url)),
            ),
        ],
      ],
    );
  }
}

class _AssetLinkRow extends StatelessWidget {
  const _AssetLinkRow({required this.link, required this.onTap});

  final ReleaseAssetLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      button: true,
      label: 'Asset ${link.name}',
      child: ExcludeSemantics(
        child: InkWell(
          key: ValueKey('release-asset-${link.name}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  GsIcon(GsIconGlyph.externalLink, size: 16, color: gs.link),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      link.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gs.link,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
