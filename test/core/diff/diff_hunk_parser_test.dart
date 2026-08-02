import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/diff/diff_hunk_parser.dart';

String _fixture(String name) =>
    File('test/fixtures/diff/$name').readAsStringSync();

void main() {
  test('pure rename with no content change has no hunks', () {
    expect(parseDiffHunks(''), isEmpty);
  });

  test('multi-hunk file resolves headers and line numbers per hunk', () {
    final hunks = parseDiffHunks(_fixture('multi_hunk.diff'));

    expect(hunks, hasLength(2));

    final first = hunks[0];
    expect(first.header, '@@ -1,6 +1,8 @@');
    expect(first.oldStart, 1);
    expect(first.oldLineCount, 6);
    expect(first.newStart, 1);
    expect(first.newLineCount, 8);
    expect(first.sectionHeading, isEmpty);
    expect(first.lines.map((l) => l.type), [
      DiffLineType.context,
      DiffLineType.context,
      DiffLineType.context,
      DiffLineType.deletion,
      DiffLineType.addition,
      DiffLineType.addition,
      DiffLineType.addition,
      DiffLineType.context,
      DiffLineType.context,
    ]);
    final deletion = first.lines[3];
    expect(deletion.content, '  Greeter(this.name);');
    expect(deletion.oldLineNumber, 4);
    expect(deletion.newLineNumber, isNull);
    final lastContext = first.lines.last;
    expect(lastContext.oldLineNumber, 6);
    expect(lastContext.newLineNumber, 8);

    final second = hunks[1];
    expect(second.header, '@@ -20,6 +22,6 @@ class Farewell {');
    expect(second.sectionHeading, 'class Farewell {');
    expect(second.oldStart, 20);
    expect(second.newStart, 22);
    final addedLine = second.lines.firstWhere(
      (l) => l.type == DiffLineType.addition,
    );
    expect(addedLine.content, "    return 'Goodbye, \$name.';");
    expect(addedLine.newLineNumber, 25);
  });

  test('renamed file with a modified line parses like any other diff', () {
    final hunks = parseDiffHunks(_fixture('rename_with_modification.diff'));

    expect(hunks, hasLength(1));
    final lines = hunks.single.lines;
    expect(lines.map((l) => l.type), [
      DiffLineType.context,
      DiffLineType.context,
      DiffLineType.deletion,
      DiffLineType.addition,
      DiffLineType.context,
    ]);
  });

  test('single-line file with no trailing newline on either side', () {
    final hunks = parseDiffHunks(_fixture('single_line_file.diff'));

    expect(hunks, hasLength(1));
    final hunk = hunks.single;
    expect(hunk.header, '@@ -1 +1 @@');
    expect(hunk.oldLineCount, 1);
    expect(hunk.newLineCount, 1);
    expect(hunk.lines, hasLength(2));

    final removed = hunk.lines[0];
    expect(removed.type, DiffLineType.deletion);
    expect(removed.content, "console.log('old');");
    expect(removed.noNewlineAtEndOfFile, isFalse);

    final added = hunk.lines[1];
    expect(added.type, DiffLineType.addition);
    expect(added.content, "console.log('new');");
    expect(added.noNewlineAtEndOfFile, isTrue);
  });

  test('no-newline marker attaches to the preceding removed line', () {
    final hunks = parseDiffHunks(_fixture('no_newline_old_side.diff'));

    final lines = hunks.single.lines;
    final removed = lines.firstWhere((l) => l.type == DiffLineType.deletion);
    expect(removed.content, 'last line without newline');
    expect(removed.noNewlineAtEndOfFile, isTrue);

    final added = lines.firstWhere((l) => l.type == DiffLineType.addition);
    expect(added.noNewlineAtEndOfFile, isFalse);
  });

  test('no-newline marker attaches to the preceding added line', () {
    final hunks = parseDiffHunks(_fixture('no_newline_new_side.diff'));

    final added = hunks.single.lines.firstWhere(
      (l) => l.type == DiffLineType.addition,
    );
    expect(added.content, 'new ending line');
    expect(added.noNewlineAtEndOfFile, isTrue);
  });

  test('blank context and added lines carry empty content, not null', () {
    final hunks = parseDiffHunks(_fixture('empty_context_lines.diff'));

    final lines = hunks.single.lines;
    expect(lines[0].type, DiffLineType.context);
    expect(lines[0].content, isEmpty);
    expect(lines[0].oldLineNumber, 1);
    expect(lines[0].newLineNumber, 1);

    final blankAddition = lines.firstWhere(
      (l) => l.type == DiffLineType.addition,
    );
    expect(blankAddition.content, isEmpty);
  });
}
