/// The per-file entry of a multi-file GitLab diff, plus the in-app rendering
/// size limit.
///
/// GitLab returns the same diff-entry JSON shape from the merge request
/// diffs endpoint (`/merge_requests/:iid/diffs`) and the commit diff
/// endpoint (`/repository/commits/:sha/diff`), so this model is shared
/// infrastructure rather than a merge-request feature type.
library;

import 'diff_hunk_parser.dart';

/// One changed file within a diff: its paths, change kind, and parsed hunks.
class DiffFile {
  DiffFile({
    required this.oldPath,
    required this.newPath,
    required this.newFile,
    required this.renamedFile,
    required this.deletedFile,
    required this.hunks,
    this.collapsed = false,
    this.tooLarge = false,
    this.diffBodyOmitted = false,
  }) : lineCount = hunks.fold(0, (sum, hunk) => sum + hunk.lines.length);

  factory DiffFile.fromJson(Map<String, dynamic> json) {
    final diff = json['diff'] as String?;
    return DiffFile(
      oldPath: json['old_path'] as String,
      newPath: json['new_path'] as String,
      newFile: json['new_file'] as bool? ?? false,
      renamedFile: json['renamed_file'] as bool? ?? false,
      deletedFile: json['deleted_file'] as bool? ?? false,
      hunks: parseDiffHunks(diff ?? ''),
      collapsed: json['collapsed'] as bool? ?? false,
      tooLarge: json['too_large'] as bool? ?? false,
      diffBodyOmitted: diff == null || diff.isEmpty,
    );
  }

  final String oldPath;
  final String newPath;
  final bool newFile;
  final bool renamedFile;
  final bool deletedFile;
  final List<DiffHunk> hunks;
  final bool collapsed;
  final bool tooLarge;
  final bool diffBodyOmitted;

  /// Total rendered diff lines across all hunks (context, added, removed).
  final int lineCount;

  bool get requiresWebFallback => tooLarge || (collapsed && diffBodyOmitted);

  /// The path shown for this file: the new path, prefixed with the old path
  /// for renames.
  String get displayPath =>
      renamedFile && oldPath != newPath ? '$oldPath -> $newPath' : newPath;

  /// The path used for syntax-highlighting language detection: the surviving
  /// side of the change.
  String get languagePath => deletedFile ? oldPath : newPath;

  /// The change-kind chip label, or null for a plain modification.
  String? get changeKindLabel {
    if (newFile) return 'new';
    if (deletedFile) return 'deleted';
    if (renamedFile) return 'renamed';
    return null;
  }
}

/// In-app rendering limits for a multi-file diff.
///
/// Beyond either limit the app shows a web-fallback affordance instead of
/// rendering the diff. The numbers are a mobile reading budget, not a
/// rendering ceiling: GitLab's own web viewer starts collapsing and
/// truncating diffs at a similar scale, and past roughly a hundred files or
/// five thousand diff lines a phone-width, sequentially scrolled diff stops
/// being reviewable. The web UI's virtualized, collapsible viewer serves it
/// better. Five thousand 20px rows is also a 100k-pixel scroll extent, which
/// keeps jump-to-file offsets and scroll performance comfortably bounded.
const int maxInAppDiffFiles = 100;

/// See [maxInAppDiffFiles].
const int maxInAppDiffLines = 5000;

/// Whether [files] exceeds the in-app rendering limits and should fall back
/// to the web viewer.
bool isOversizedDiff(List<DiffFile> files) {
  if (files.length > maxInAppDiffFiles) return true;
  var lines = 0;
  for (final file in files) {
    if (file.requiresWebFallback) return true;
    lines += file.lineCount;
    if (lines > maxInAppDiffLines) return true;
  }
  return false;
}
