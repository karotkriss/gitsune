import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/diff/diff_file.dart';
import 'package:gitsune/core/diff/diff_hunk_parser.dart';
import 'package:gitsune/core/diff/gs_diff_view.dart';

import '../../support/fixtures.dart';

List<DiffFile> _filesFrom(String fixture) => (Fixtures.json(fixture) as List)
    .map((value) => DiffFile.fromJson(Map<String, dynamic>.from(value as Map)))
    .toList(growable: false);

DiffFile _fileOfLines(int lineCount) => DiffFile(
  oldPath: 'a.txt',
  newPath: 'a.txt',
  newFile: false,
  renamedFile: false,
  deletedFile: false,
  hunks: [
    DiffHunk(
      header: '@@ -1,$lineCount +1,$lineCount @@',
      oldStart: 1,
      oldLineCount: lineCount,
      newStart: 1,
      newLineCount: lineCount,
      sectionHeading: '',
      lines: [
        for (var i = 0; i < lineCount; i++)
          DiffLine(
            type: DiffLineType.context,
            content: 'line $i',
            oldLineNumber: i + 1,
            newLineNumber: i + 1,
          ),
      ],
    ),
  ],
);

void main() {
  test('decodes GitLab diff entries with parsed hunks and change kinds', () {
    final files = [
      ..._filesFrom('merge_request_142_diffs_page1'),
      ..._filesFrom('merge_request_142_diffs_page2'),
    ];

    expect(files, hasLength(4));

    final modified = files[0];
    expect(modified.newPath, 'lib/src/instance_switcher.dart');
    expect(modified.changeKindLabel, isNull);
    expect(modified.hunks, hasLength(2));
    expect(modified.lineCount, 13);
    expect(modified.hunks.first.lines[2].type, DiffLineType.deletion);
    expect(modified.hunks.first.lines[3].type, DiffLineType.addition);
    expect(modified.hunks.first.lines[3].newLineNumber, 3);

    final renamed = files[1];
    expect(renamed.changeKindLabel, 'renamed');
    expect(renamed.displayPath, 'docs/README.md -> README.md');
    expect(renamed.languagePath, 'README.md');

    final added = files[2];
    expect(added.changeKindLabel, 'new');
    expect(added.hunks.single.lines, everyElement(_isAddition));

    final deleted = files[3];
    expect(deleted.changeKindLabel, 'deleted');
    expect(deleted.languagePath, 'lib/src/legacy_switcher.dart');
  });

  test('flags a diff oversized past the file or line limits', () {
    expect(
      isOversizedDiff([for (var i = 0; i < 100; i++) _fileOfLines(1)]),
      isFalse,
    );
    expect(
      isOversizedDiff([for (var i = 0; i < 101; i++) _fileOfLines(1)]),
      isTrue,
    );
    expect(isOversizedDiff([_fileOfLines(5000)]), isFalse);
    expect(isOversizedDiff([_fileOfLines(5000), _fileOfLines(1)]), isTrue);
    expect(
      isOversizedDiff(_filesFrom('merge_request_142_diffs_oversized')),
      isTrue,
    );
    final suppressed = _filesFrom('merge_request_142_diffs_suppressed');
    expect(suppressed.first.tooLarge, isTrue);
    expect(suppressed.last.collapsed, isTrue);
    expect(suppressed, everyElement(_requiresWebFallback));
    expect(isOversizedDiff(suppressed), isTrue);
  });

  test('computes fixed per-file extents and jump offsets', () {
    final files = [_fileOfLines(3), _fileOfLines(1), _fileOfLines(2)];

    // header 44 + hunk header 24 + 20 per line + trailing gap 12.
    expect(GsDiffView.extentForFile(files[0]), 44 + 24 + 3 * 20 + 12);
    expect(GsDiffView.offsetForFile(files, 0), 0);
    expect(GsDiffView.offsetForFile(files, 1), 140);
    expect(GsDiffView.offsetForFile(files, 2), 140 + 100);
  });

  test('includes indexed annotations in extents and jump offsets', () {
    final files = [_fileOfLines(3), _fileOfLines(1)];
    final annotations = [
      DiffLineAnnotation(
        path: 'a.txt',
        newLine: 1,
        builder: (_) => const SizedBox.shrink(),
      ),
      DiffLineAnnotation(
        path: 'a.txt',
        oldLine: 2,
        builder: (_) => const SizedBox.shrink(),
      ),
      DiffLineAnnotation(
        path: 'other.txt',
        newLine: 3,
        builder: (_) => const SizedBox.shrink(),
      ),
    ];

    expect(
      GsDiffView.extentForFile(files.first, annotations: annotations),
      140 + 2 * GsDiffView.annotationHeight,
    );
    expect(
      GsDiffView.offsetForFile(files, 1, annotations: annotations),
      140 + 2 * GsDiffView.annotationHeight,
    );
  });
}

final Matcher _isAddition = predicate<DiffLine>(
  (line) => line.type == DiffLineType.addition,
  'is an addition line',
);

final Matcher _requiresWebFallback = predicate<DiffFile>(
  (file) => file.requiresWebFallback,
  'requires web fallback',
);
