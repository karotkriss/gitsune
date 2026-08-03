import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons/gs_icons.dart';
import '../syntax/gs_syntax_theme.dart';
import '../syntax/language_detection.dart';
import '../syntax/syntax_highlighter.dart';
import '../theme/app_theme.dart';
import 'diff_file.dart';
import 'diff_hunk_parser.dart';

/// Renders a multi-file unified diff in lazily built row chunks, with
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
///
/// [annotations] anchor fixed-height widgets (such as comment thread rows)
/// directly beneath specific diff lines, and [onLineTap] surfaces line taps
/// so a composing screen can attach line-level actions; both stay generic so
/// this renderer keeps knowing nothing about merge requests.
class GsDiffView extends StatefulWidget {
  const GsDiffView({
    super.key,
    required this.files,
    required this.onOpenInBrowser,
    this.controller,
    this.annotations = const [],
    this.onLineTap,
  });

  final List<DiffFile> files;

  /// Invoked by the oversized-diff fallback's "Open in browser" affordance.
  final VoidCallback onOpenInBrowser;

  final ScrollController? controller;

  /// Fixed-height widgets anchored beneath specific diff lines.
  final List<DiffLineAnnotation> annotations;

  /// Invoked when a diff line row is tapped.
  final void Function(DiffFile file, DiffLine line)? onLineTap;

  /// The fixed height of every [DiffLineAnnotation] row.
  static const double annotationHeight = 44;

  static const double _fileHeaderHeight = 44;
  static const double _hunkHeaderHeight = 24;
  static const double _lineHeight = 20;
  static const double _fileGap = 12;
  static const int _rowsPerChunk = 40;

  /// The fixed vertical extent of [file]'s rendered block, including any
  /// [annotations] anchored to its lines.
  static double extentForFile(
    DiffFile file, {
    List<DiffLineAnnotation> annotations = const [],
  }) {
    var extent = _fileHeaderHeight + _fileGap;
    for (final hunk in file.hunks) {
      extent += _hunkHeaderHeight + hunk.lines.length * _lineHeight;
      if (annotations.isEmpty) continue;
      for (final line in hunk.lines) {
        extent +=
            annotations.where((a) => a.matches(file, line)).length *
            annotationHeight;
      }
    }
    return extent;
  }

  /// The scroll offset at which the file at [index] starts.
  static double offsetForFile(
    List<DiffFile> files,
    int index, {
    List<DiffLineAnnotation> annotations = const [],
  }) {
    var offset = 0.0;
    for (var i = 0; i < index; i++) {
      offset += extentForFile(files[i], annotations: annotations);
    }
    return offset;
  }

  @override
  State<GsDiffView> createState() => _GsDiffViewState();

  static List<_DiffListItem> _buildItems(
    List<DiffFile> files,
    List<_HorizontalScrollGroup> scrollGroups,
    TextStyle monoStyle,
    TextDirection textDirection,
    TextScaler textScaler,
    List<DiffLineAnnotation> annotations,
    void Function(DiffFile file, DiffLine line)? onLineTap,
  ) {
    final items = <_DiffListItem>[];
    for (var fileIndex = 0; fileIndex < files.length; fileIndex++) {
      final file = files[fileIndex];
      final scrollGroup = scrollGroups[fileIndex];
      final contentWidth = _contentWidthForFile(
        file,
        monoStyle,
        textDirection,
        textScaler,
      );
      items.add(_FileHeaderItem(file));
      final languageId = detectLanguageId(file.languagePath);
      var rows = <_DiffContentRow>[];
      var chunkIndex = 0;

      void flushRows() {
        if (rows.isEmpty) return;
        items.add(
          _DiffRowsItem(
            rows,
            languageId,
            scrollGroup,
            contentWidth,
            ValueKey('diff-horizontal-$fileIndex-${chunkIndex++}'),
          ),
        );
        rows = <_DiffContentRow>[];
      }

      for (final hunk in file.hunks) {
        if (rows.length >= _rowsPerChunk) flushRows();
        rows.add(_HunkContentRow(hunk));
        for (final line in hunk.lines) {
          if (rows.length >= _rowsPerChunk) flushRows();
          rows.add(
            _LineContentRow(
              line,
              onLineTap == null ? null : () => onLineTap(file, line),
            ),
          );
          final lineAnnotations = annotations.where(
            (a) => a.matches(file, line),
          );
          if (lineAnnotations.isNotEmpty) {
            // Annotations render outside the horizontal scroll group so they
            // stay pinned to the viewport width.
            flushRows();
            for (final annotation in lineAnnotations) {
              items.add(_AnnotationItem(annotation));
            }
          }
        }
        if (rows.length >= _rowsPerChunk) flushRows();
      }
      flushRows();
      items.add(const _FileGapItem());
    }
    return items;
  }

  static double _contentWidthForFile(
    DiffFile file,
    TextStyle monoStyle,
    TextDirection textDirection,
    TextScaler textScaler,
  ) {
    var longestHeader = '';
    var longestLineColumns = 0;
    for (final hunk in file.hunks) {
      if (_displayColumns(hunk.header) > _displayColumns(longestHeader)) {
        longestHeader = hunk.header;
      }
      for (final line in hunk.lines) {
        longestLineColumns = math.max(
          longestLineColumns,
          _displayColumns(line.content),
        );
      }
    }
    final italicStyle = monoStyle.copyWith(fontStyle: FontStyle.italic);
    final characterWidth = ['M', 'W', '漢', '😀'].fold(0.0, (width, glyph) {
      return math.max(
        width,
        math.max(
          _measureText(glyph, monoStyle, textDirection, textScaler),
          _measureText(glyph, italicStyle, textDirection, textScaler),
        ),
      );
    });
    final headerWidth = _measureText(
      longestHeader,
      monoStyle.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
      textDirection,
      textScaler,
    );
    return math.max(
          longestLineColumns * characterWidth * 1.05 + 104,
          headerWidth + 32,
        ) +
        1;
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

  static int _displayColumns(String text) {
    var columns = 0;
    for (final rune in text.runes) {
      columns = rune == 9 ? (columns ~/ 8 + 1) * 8 : columns + 1;
    }
    return columns;
  }
}

class _GsDiffViewState extends State<GsDiffView> {
  late List<_HorizontalScrollGroup> _scrollGroups = _newScrollGroups();

  List<_HorizontalScrollGroup> _newScrollGroups() => List.generate(
    widget.files.length,
    (_) => _HorizontalScrollGroup(),
    growable: false,
  );

  @override
  void didUpdateWidget(GsDiffView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.files, oldWidget.files)) {
      _scrollGroups = _newScrollGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isOversizedDiff(widget.files)) {
      return _OversizedDiffFallback(
        files: widget.files,
        onOpenInBrowser: widget.onOpenInBrowser,
      );
    }
    final gs = Theme.of(context).extension<GsTheme>()!;
    final syntaxTheme = gsSyntaxTextTheme(gs);
    final items = GsDiffView._buildItems(
      widget.files,
      _scrollGroups,
      gs.mono,
      Directionality.of(context),
      MediaQuery.textScalerOf(context),
      widget.annotations,
      widget.onLineTap,
    );
    return ListView.builder(
      controller: widget.controller,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemExtentBuilder: (index, dimensions) => items[index].extent,
      itemBuilder: (context, index) => items[index].build(context, syntaxTheme),
    );
  }
}

/// A fixed-height widget anchored directly beneath one diff line, addressed
/// with GitLab position semantics: the file [path] plus the [newLine] number
/// (right side) or, when [newLine] is absent, the [oldLine] number (left
/// side). Its widget must lay out within [GsDiffView.annotationHeight].
class DiffLineAnnotation {
  const DiffLineAnnotation({
    required this.path,
    this.oldLine,
    this.newLine,
    required this.builder,
  });

  final String path;
  final int? oldLine;
  final int? newLine;
  final WidgetBuilder builder;

  bool matches(DiffFile file, DiffLine line) {
    if (path != file.newPath && path != file.oldPath) return false;
    if (newLine != null) return line.newLineNumber == newLine;
    return oldLine != null && line.oldLineNumber == oldLine;
  }
}

sealed class _DiffListItem {
  const _DiffListItem();

  double get extent;

  Widget build(BuildContext context, Map<String, TextStyle> syntaxTheme);
}

class _FileHeaderItem extends _DiffListItem {
  const _FileHeaderItem(this.file);

  final DiffFile file;

  @override
  double get extent => GsDiffView._fileHeaderHeight;

  @override
  Widget build(BuildContext context, Map<String, TextStyle> syntaxTheme) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final changeKind = file.changeKindLabel;
    return SizedBox(
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
    );
  }
}

class _DiffRowsItem extends _DiffListItem {
  const _DiffRowsItem(
    this.rows,
    this.languageId,
    this.scrollGroup,
    this.contentWidth,
    this.scrollKey,
  );

  final List<_DiffContentRow> rows;
  final String languageId;
  final _HorizontalScrollGroup scrollGroup;
  final double contentWidth;
  final Key scrollKey;

  @override
  double get extent => rows.fold(0, (sum, row) => sum + row.extent);

  @override
  Widget build(BuildContext context, Map<String, TextStyle> syntaxTheme) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return ColoredBox(
      color: gs.codeBg,
      child: LayoutBuilder(
        builder: (context, constraints) => _SynchronizedHorizontalScrollView(
          scrollKey: scrollKey,
          group: scrollGroup,
          width: math.max(contentWidth, constraints.maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final row in rows)
                row.build(context, languageId, syntaxTheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalScrollGroup {
  static const double _offsetEpsilon = 0.01;

  final Set<ScrollController> _controllers = {};
  double offset = 0;
  bool _synchronizing = false;

  void attach(ScrollController controller) => _controllers.add(controller);

  void detach(ScrollController controller) => _controllers.remove(controller);

  void update(ScrollController source, double nextOffset) {
    if (_synchronizing) return;
    offset = nextOffset;
    _synchronizing = true;
    try {
      for (final controller in _controllers) {
        if (identical(controller, source) || !controller.hasClients) continue;
        final target = nextOffset
            .clamp(
              controller.position.minScrollExtent,
              controller.position.maxScrollExtent,
            )
            .toDouble();
        if ((controller.offset - target).abs() > _offsetEpsilon) {
          controller.jumpTo(target);
        }
      }
    } finally {
      _synchronizing = false;
    }
  }
}

class _SynchronizedHorizontalScrollView extends StatefulWidget {
  const _SynchronizedHorizontalScrollView({
    required this.scrollKey,
    required this.group,
    required this.width,
    required this.child,
  });

  final Key scrollKey;
  final _HorizontalScrollGroup group;
  final double width;
  final Widget child;

  @override
  State<_SynchronizedHorizontalScrollView> createState() =>
      _SynchronizedHorizontalScrollViewState();
}

class _SynchronizedHorizontalScrollViewState
    extends State<_SynchronizedHorizontalScrollView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: widget.group.offset);
    widget.group.attach(_controller);
  }

  @override
  void didUpdateWidget(_SynchronizedHorizontalScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.group, oldWidget.group)) {
      oldWidget.group.detach(_controller);
      widget.group.attach(_controller);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) return;
        _controller.jumpTo(
          widget.group.offset
              .clamp(
                _controller.position.minScrollExtent,
                _controller.position.maxScrollExtent,
              )
              .toDouble(),
        );
      });
    }
  }

  @override
  void dispose() {
    widget.group.detach(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        widget.group.update(_controller, notification.metrics.pixels);
        return false;
      },
      child: SingleChildScrollView(
        key: widget.scrollKey,
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: widget.width, child: widget.child),
      ),
    );
  }
}

class _FileGapItem extends _DiffListItem {
  const _FileGapItem();

  @override
  double get extent => GsDiffView._fileGap;

  @override
  Widget build(BuildContext context, Map<String, TextStyle> syntaxTheme) =>
      const SizedBox(height: GsDiffView._fileGap);
}

sealed class _DiffContentRow {
  const _DiffContentRow();

  double get extent;

  Widget build(
    BuildContext context,
    String languageId,
    Map<String, TextStyle> syntaxTheme,
  );
}

class _HunkContentRow extends _DiffContentRow {
  const _HunkContentRow(this.hunk);

  final DiffHunk hunk;

  @override
  double get extent => GsDiffView._hunkHeaderHeight;

  @override
  Widget build(
    BuildContext context,
    String languageId,
    Map<String, TextStyle> syntaxTheme,
  ) => _HunkHeaderRow(hunk: hunk);
}

class _LineContentRow extends _DiffContentRow {
  const _LineContentRow(this.line, this.onTap);

  final DiffLine line;
  final VoidCallback? onTap;

  @override
  double get extent => GsDiffView._lineHeight;

  @override
  Widget build(
    BuildContext context,
    String languageId,
    Map<String, TextStyle> syntaxTheme,
  ) => _DiffLineRow(
    line: line,
    languageId: languageId,
    syntaxTheme: syntaxTheme,
    onTap: onTap,
  );
}

class _AnnotationItem extends _DiffListItem {
  const _AnnotationItem(this.annotation);

  final DiffLineAnnotation annotation;

  @override
  double get extent => GsDiffView.annotationHeight;

  @override
  Widget build(BuildContext context, Map<String, TextStyle> syntaxTheme) =>
      SizedBox(
        height: GsDiffView.annotationHeight,
        child: annotation.builder(context),
      );
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
    this.onTap,
  });

  final DiffLine line;
  final String languageId;
  final Map<String, TextStyle> syntaxTheme;
  final VoidCallback? onTap;

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
    final colored = background == null
        ? row
        : ColoredBox(color: background, child: row);
    if (onTap == null) return colored;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: colored,
    );
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
    final hasSuppressedContent = files.any((file) => file.requiresWebFallback);
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
              hasSuppressedContent
                  ? 'GitLab omitted part of this diff. View it on the web '
                        'instead.'
                  : '${files.length} files and $lineCount diff lines exceed '
                        'what reads well on this screen. View it on the web '
                        'instead.',
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
