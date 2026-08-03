import 'package:flutter/material.dart';

import '../icons/gs_icons.dart';
import '../syntax/gs_syntax_theme.dart';
import '../syntax/language_detection.dart';
import '../syntax/syntax_highlighter.dart';
import '../theme/app_theme.dart';
import 'diff_file.dart';
import 'diff_hunk_parser.dart';

/// Renders a multi-file unified diff, one lazily built block per file, with
/// per-line added/removed/context backgrounds and per-line syntax
/// highlighting from the token layer.
///
/// This is the reusable renderer the merge request changes screen (and later
/// the commit view) composes; it knows nothing about merge requests. When
/// [isOversizedDiff] reports the diff exceeds the in-app limits, it renders
/// a web-fallback affordance that invokes [onOpenInBrowser] instead of the
/// diff itself.
///
/// Every row has a fixed height, so a file block's extent is a pure function
/// of its hunk shape ([extentForFile]) and a composing screen can jump to a
/// file by scrolling [controller] to [offsetForFile].
class GsDiffView extends StatelessWidget {
  const GsDiffView({
    super.key,
    required this.files,
    required this.onOpenInBrowser,
    this.controller,
  });

  final List<DiffFile> files;

  /// Invoked by the oversized-diff fallback's "Open in browser" affordance.
  final VoidCallback onOpenInBrowser;

  final ScrollController? controller;

  static const double _fileHeaderHeight = 44;
  static const double _hunkHeaderHeight = 24;
  static const double _lineHeight = 20;
  static const double _fileGap = 12;

  /// The fixed vertical extent of [file]'s rendered block.
  static double extentForFile(DiffFile file) {
    var extent = _fileHeaderHeight + _fileGap;
    for (final hunk in file.hunks) {
      extent += _hunkHeaderHeight + hunk.lines.length * _lineHeight;
    }
    return extent;
  }

  /// The scroll offset at which the file at [index] starts.
  static double offsetForFile(List<DiffFile> files, int index) {
    var offset = 0.0;
    for (var i = 0; i < index; i++) {
      offset += extentForFile(files[i]);
    }
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    if (isOversizedDiff(files)) {
      return _OversizedDiffFallback(
        files: files,
        onOpenInBrowser: onOpenInBrowser,
      );
    }
    final gs = Theme.of(context).extension<GsTheme>()!;
    final syntaxTheme = gsSyntaxTextTheme(gs);
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: files.length,
      itemExtentBuilder: (index, dimensions) => extentForFile(files[index]),
      itemBuilder: (context, index) => _DiffFileBlock(
        file: files[index],
        syntaxTheme: syntaxTheme,
      ),
    );
  }
}

class _DiffFileBlock extends StatelessWidget {
  const _DiffFileBlock({required this.file, required this.syntaxTheme});

  final DiffFile file;
  final Map<String, TextStyle> syntaxTheme;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final languageId = detectLanguageId(file.languagePath);
    final changeKind = file.changeKindLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: GsDiffView._fileHeaderHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    file.displayPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: gs.mono.copyWith(
                      color: gs.textHeading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (changeKind != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    changeKind,
                    style: gs.caption.copyWith(
                      color: switch (changeKind) {
                        'new' => gs.textSuccess,
                        'deleted' => gs.textDanger,
                        _ => gs.textSubtle,
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: gs.codeBg,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final hunk in file.hunks) ...[
                          _HunkHeaderRow(hunk: hunk),
                          for (final line in hunk.lines)
                            _DiffLineRow(
                              line: line,
                              languageId: languageId,
                              syntaxTheme: syntaxTheme,
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
        const SizedBox(height: GsDiffView._fileGap),
      ],
    );
  }
}

class _HunkHeaderRow extends StatelessWidget {
  const _HunkHeaderRow({required this.hunk});

  final DiffHunk hunk;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return SizedBox(
      height: GsDiffView._hunkHeaderHeight,
      child: ColoredBox(
        color: gs.surfaceStrong,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              hunk.header,
              maxLines: 1,
              softWrap: false,
              style: gs.mono.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: gs.codeComment,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _DiffLineRow extends StatelessWidget {
  const _DiffLineRow({
    required this.line,
    required this.languageId,
    required this.syntaxTheme,
  });

  final DiffLine line;
  final String languageId;
  final Map<String, TextStyle> syntaxTheme;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final (background, marker) = switch (line.type) {
      DiffLineType.addition => (gs.diffAddBg, '+'),
      DiffLineType.deletion => (gs.diffDelBg, '-'),
      DiffLineType.context => (null, ' '),
    };
    final gutterStyle = gs.mono.copyWith(fontSize: 11, color: gs.textSubtle);
    final row = SizedBox(
      height: GsDiffView._lineHeight,
      child: Row(
        children: [
          _GutterNumber(number: line.oldLineNumber, style: gutterStyle),
          _GutterNumber(number: line.newLineNumber, style: gutterStyle),
          SizedBox(
            width: 16,
            child: Text(
              marker,
              textAlign: TextAlign.center,
              style: gutterStyle,
            ),
          ),
          Text.rich(
            highlightDiffLine(
              line,
              languageId: languageId,
              base: gs.mono.copyWith(color: gs.textDefault),
              theme: syntaxTheme,
            ),
            maxLines: 1,
            softWrap: false,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
    return background == null ? row : ColoredBox(color: background, child: row);
  }
}

class _GutterNumber extends StatelessWidget {
  const _GutterNumber({required this.number, required this.style});

  final int? number;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Text(
          number?.toString() ?? '',
          textAlign: TextAlign.right,
          style: style,
        ),
      ),
    );
  }
}

class _OversizedDiffFallback extends StatelessWidget {
  const _OversizedDiffFallback({
    required this.files,
    required this.onOpenInBrowser,
  });

  final List<DiffFile> files;
  final VoidCallback onOpenInBrowser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final lineCount = files.fold(0, (sum, file) => sum + file.lineCount);
    return Center(
      key: const ValueKey('diff-web-fallback'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This diff is too large to view here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${files.length} files and $lineCount diff lines exceed what '
              'reads well on this screen. View it on the web instead.',
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
