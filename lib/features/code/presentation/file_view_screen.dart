import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/syntax/gs_syntax_theme.dart';
import '../../../core/syntax/language_detection.dart';
import '../../../core/syntax/syntax_highlighter.dart';
import '../../../core/theme/app_theme.dart';
import '../data/repository_tree_repository.dart';

/// A repository file's contents (E9.2): every line syntax-highlighted by the
/// same per-line engine the diff view uses, with a line-number gutter and a
/// soft-wrap toggle in the app bar.
///
/// Wrapping is off by default: lines stay unbroken and the body pans
/// horizontally, the same reading model as the diff view's per-file
/// horizontal viewport. Toggling wrap on breaks long lines at the screen
/// edge instead.
///
/// A file longer than [kNativeSyntaxCharThreshold] characters is not
/// rendered in-app at all: past that size the per-line native highlighter
/// stops being comfortable (see the threshold's own documentation).
/// Consistent with the diff view's oversized fallback, the screen offers to
/// open the blob in the web browser, where GitLab's viewer handles large files
/// better than a phone screen would.
class FileViewScreen extends StatefulWidget {
  const FileViewScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.filePath,
    required this.repository,
    this.ref = '',
    this.openWebUrl,
  });

  final int projectId;

  /// The project's namespaced path, used to build the browser-fallback URL.
  final String projectPath;

  /// The file's path within the repository.
  final String filePath;

  final RepositoryTreeRepository repository;

  /// The ref being browsed, `''` for the project's default branch.
  final String ref;

  /// Overrides how the oversized-file fallback opens a URL; defaults to the
  /// system browser via `url_launcher`.
  final Future<void> Function(Uri url)? openWebUrl;

  @override
  State<FileViewScreen> createState() => _FileViewScreenState();
}

class _FileViewScreenState extends State<FileViewScreen> {
  String? _content;
  bool _loading = true;
  bool _failed = false;
  bool _wrap = false;
  int _loadGeneration = 0;

  String get _fileName => widget.filePath.split('/').last;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant FileViewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.filePath != widget.filePath ||
        oldWidget.ref != widget.ref ||
        oldWidget.repository != widget.repository) {
      _content = null;
      _load();
    }
  }

  Future<void> _load() async {
    final loadGeneration = ++_loadGeneration;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final content = await widget.repository.loadFileContent(
        widget.projectId,
        path: widget.filePath,
        ref: widget.ref,
      );
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _content = content;
        _loading = false;
      });
    } on Object {
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _openInBrowser() async {
    final url = widget.repository.fileWebUrl(
      projectPath: widget.projectPath,
      path: widget.filePath,
      ref: widget.ref,
    );
    final open = widget.openWebUrl ?? _launchExternally;
    await open(url);
  }

  static Future<void> _launchExternally(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final content = _content;
    final oversized =
        content != null && content.length > kNativeSyntaxCharThreshold;
    return Scaffold(
      backgroundColor: gs.codeBg,
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
          _fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(
            color: gs.textHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (content != null && !oversized)
            IconButton(
              key: const ValueKey('file-wrap-toggle'),
              tooltip: _wrap ? 'Unwrap lines' : 'Wrap lines',
              onPressed: () => setState(() => _wrap = !_wrap),
              icon: GsIcon(
                _wrap ? GsIconGlyph.softUnwrap : GsIconGlyph.softWrap,
                size: 20,
                color: gs.accent,
              ),
            ),
        ],
      ),
      body: switch ((content, oversized)) {
        (null, _) => _FileInitialState(
          loading: _loading,
          failed: _failed,
          onRetry: _load,
        ),
        (_, true) => _OversizedFileFallback(onOpenInBrowser: _openInBrowser),
        (final String content, false) => _FileBody(
          content: content,
          filePath: widget.filePath,
          wrap: _wrap,
        ),
      },
    );
  }
}

class _FileBody extends StatelessWidget {
  const _FileBody({
    required this.content,
    required this.filePath,
    required this.wrap,
  });

  final String content;
  final String filePath;
  final bool wrap;

  static const double _lineHeight = 20;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final languageId = detectLanguageId(filePath);
    final syntaxTheme = gsSyntaxTextTheme(gs);
    final base = gs.mono.copyWith(color: gs.textDefault);
    final gutterStyle = gs.mono.copyWith(fontSize: 11, color: gs.textSubtle);

    final lines = content.split('\n');
    // A trailing newline terminates the last line rather than starting an
    // empty one, matching how GitLab's own blob viewer counts lines.
    if (lines.length > 1 && lines.last.isEmpty) lines.removeLast();

    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final gutterWidth =
        _measureText(
          '${lines.length}',
          gutterStyle,
          textDirection,
          textScaler,
        ) +
        20;

    if (content.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'This file is empty.',
            style: base.copyWith(color: gs.textSubtle),
          ),
        ],
      );
    }

    if (wrap) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: lines.length,
        itemBuilder: (context, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gutter(index, gutterWidth, gutterStyle),
            Expanded(
              child: Text.rich(
                highlightCodeLine(
                  lines[index],
                  languageId: languageId,
                  base: base,
                  theme: syntaxTheme,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      );
    }

    final contentWidth =
        gutterWidth +
        _longestLineColumns(lines) *
            _characterWidth(base, textDirection, textScaler) *
            1.05 +
        16;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        key: const ValueKey('file-horizontal-scroll'),
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(contentWidth, constraints.maxWidth),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemExtent: _lineHeight,
            itemCount: lines.length,
            itemBuilder: (context, index) => Row(
              children: [
                _gutter(index, gutterWidth, gutterStyle),
                Text.rich(
                  highlightCodeLine(
                    lines[index],
                    languageId: languageId,
                    base: base,
                    theme: syntaxTheme,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gutter(int index, double width, TextStyle style) => SizedBox(
    width: width,
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text('${index + 1}', textAlign: TextAlign.right, style: style),
    ),
  );

  /// Display columns of the widest line, expanding tabs to 8-column stops,
  /// mirroring the diff view's width model.
  static int _longestLineColumns(List<String> lines) {
    var longest = 0;
    for (final line in lines) {
      var columns = 0;
      for (final rune in line.runes) {
        columns = rune == 9 ? (columns ~/ 8 + 1) * 8 : columns + 1;
      }
      longest = math.max(longest, columns);
    }
    return longest;
  }

  /// The widest plausible glyph advance for [style], covering wide CJK and
  /// emoji glyphs the way the diff view does.
  static double _characterWidth(
    TextStyle style,
    TextDirection textDirection,
    TextScaler textScaler,
  ) {
    return ['M', 'W', '漢', '😀'].fold(
      0.0,
      (width, glyph) => math.max(
        width,
        _measureText(glyph, style, textDirection, textScaler),
      ),
    );
  }

  static double _measureText(
    String text,
    TextStyle style,
    TextDirection textDirection,
    TextScaler textScaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

class _FileInitialState extends StatelessWidget {
  const _FileInitialState({
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
              'Unable to load this file.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _OversizedFileFallback extends StatelessWidget {
  const _OversizedFileFallback({required this.onOpenInBrowser});

  final VoidCallback onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Center(
      key: const ValueKey('file-web-fallback'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This file is too large to view here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'View it on the web instead.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onOpenInBrowser,
              icon: GsIcon(
                GsIconGlyph.externalLink,
                size: 16,
                color: gs.onAccent,
              ),
              label: const Text('Open in browser'),
            ),
          ],
        ),
      ),
    );
  }
}
