/// Parses the per-file unified-diff hunk text returned by GitLab's merge
/// request changes/diffs APIs (the `diff` field on each diff entry) into a
/// line-by-line model that a UI can render without re-parsing diff syntax.
library;

/// Whether a [DiffLine] was added, removed, or is unchanged context.
enum DiffLineType { context, addition, deletion }

/// A single rendered line within a [DiffHunk].
///
/// [oldLineNumber] is null for additions, [newLineNumber] is null for
/// deletions; context lines carry both.
class DiffLine {
  const DiffLine({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
    this.noNewlineAtEndOfFile = false,
  });

  final DiffLineType type;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;

  /// True when this line was immediately followed by a unified-diff
  /// `\ No newline at end of file` marker.
  final bool noNewlineAtEndOfFile;
}

/// One `@@ ... @@` hunk of a unified diff, with its lines already resolved
/// to old/new line numbers.
class DiffHunk {
  const DiffHunk({
    required this.header,
    required this.oldStart,
    required this.oldLineCount,
    required this.newStart,
    required this.newLineCount,
    required this.sectionHeading,
    required this.lines,
  });

  /// The raw `@@ -a,b +c,d @@ ...` header line.
  final String header;
  final int oldStart;
  final int oldLineCount;
  final int newStart;
  final int newLineCount;

  /// Trailing context GitLab/git appends to the header (often the enclosing
  /// function signature); empty when absent.
  final String sectionHeading;
  final List<DiffLine> lines;
}

final RegExp _hunkHeaderPattern = RegExp(
  r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@ ?(.*)$',
);

/// Parses a GitLab diff-entry `diff` string into its hunks.
///
/// Returns an empty list for a pure rename with no content change, where
/// GitLab reports an empty `diff` string.
List<DiffHunk> parseDiffHunks(String diff) {
  final rawLines = diff.split('\n');
  if (rawLines.isNotEmpty && rawLines.last.isEmpty) {
    rawLines.removeLast();
  }

  final hunks = <DiffHunk>[];
  List<DiffLine>? currentLines;
  var header = '';
  var sectionHeading = '';
  var oldStart = 0, oldLineCount = 0, newStart = 0, newLineCount = 0;
  var oldLine = 0, newLine = 0;

  void flush() {
    final lines = currentLines;
    if (lines != null) {
      hunks.add(
        DiffHunk(
          header: header,
          oldStart: oldStart,
          oldLineCount: oldLineCount,
          newStart: newStart,
          newLineCount: newLineCount,
          sectionHeading: sectionHeading,
          lines: lines,
        ),
      );
    }
  }

  for (final line in rawLines) {
    final headerMatch = _hunkHeaderPattern.firstMatch(line);
    if (headerMatch != null) {
      flush();
      header = line;
      oldStart = int.parse(headerMatch.group(1)!);
      oldLineCount = int.parse(headerMatch.group(2) ?? '1');
      newStart = int.parse(headerMatch.group(3)!);
      newLineCount = int.parse(headerMatch.group(4) ?? '1');
      sectionHeading = headerMatch.group(5) ?? '';
      oldLine = oldStart;
      newLine = newStart;
      currentLines = <DiffLine>[];
      continue;
    }

    final lines = currentLines;
    if (lines == null) continue;

    if (line.startsWith(r'\')) {
      if (lines.isNotEmpty) {
        final last = lines.removeLast();
        lines.add(
          DiffLine(
            type: last.type,
            content: last.content,
            oldLineNumber: last.oldLineNumber,
            newLineNumber: last.newLineNumber,
            noNewlineAtEndOfFile: true,
          ),
        );
      }
      continue;
    }

    final marker = line.isEmpty ? ' ' : line[0];
    final content = line.isEmpty ? '' : line.substring(1);
    switch (marker) {
      case '+':
        lines.add(
          DiffLine(
            type: DiffLineType.addition,
            content: content,
            newLineNumber: newLine++,
          ),
        );
      case '-':
        lines.add(
          DiffLine(
            type: DiffLineType.deletion,
            content: content,
            oldLineNumber: oldLine++,
          ),
        );
      default:
        lines.add(
          DiffLine(
            type: DiffLineType.context,
            content: content,
            oldLineNumber: oldLine++,
            newLineNumber: newLine++,
          ),
        );
    }
  }

  flush();
  return hunks;
}
