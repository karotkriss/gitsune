import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ansi/ansi_log_parser.dart';

void main() {
  group('parseAnsiLog on a recorded GitLab job trace', () {
    final lines = parseAnsiLog(
      File('test/fixtures/ansi/job_trace.txt').readAsStringSync(),
    );

    test('never leaks a raw escape sequence or section marker', () {
      for (final line in lines) {
        expect(line.text, isNot(contains('\x1b')));
        expect(line.text, isNot(contains('\r')));
        expect(line.text, isNot(contains('section_start:')));
        expect(line.text, isNot(contains('section_end:')));
      }
    });

    test('keeps plain lines verbatim as single default spans', () {
      final first = lines.first;
      expect(first.text, 'Running with gitlab-runner 17.5.3 (12345678)');
      expect(first.spans, hasLength(1));
      expect(first.spans.single.fgIndex, isNull);
      expect(first.spans.single.bold, isFalse);
    });

    test('styles section headers cyan bold with the marker overwritten', () {
      final header = lines.firstWhere(
        (line) => line.text.contains('Preparing'),
      );
      expect(header.text, 'Preparing the "docker" executor');
      expect(header.spans.single.fgIndex, 6);
      expect(header.spans.single.bold, isTrue);
    });

    test('styles echoed commands green bold', () {
      final command = lines.firstWhere(
        (line) => line.text == r'$ flutter test',
      );
      expect(command.spans.single.fgIndex, 2);
      expect(command.spans.single.bold, isTrue);
    });

    test('maps bright colors to the upper palette half', () {
      final warning = lines.firstWhere(
        (line) => line.text.contains('unused import'),
      );
      expect(warning.spans.single.fgIndex, 11);
    });

    test('keeps only the final state of a \\r progress line', () {
      expect(
        lines.map((line) => line.text),
        contains('00:12 +42: All tests passed!'),
      );
      expect(
        lines.map((line) => line.text),
        isNot(contains(contains('00:03 +0'))),
      );
    });

    test('reduces bare section_end marker lines to empty lines', () {
      expect(lines[4].text, isEmpty);
    });

    test('passes timestamped runner lines through untouched', () {
      expect(
        lines.map((line) => line.text),
        contains('2026-08-02T10:15:42.123Z [runner] uploading artifacts'),
      );
    });
  });

  group('parseAnsiLog edge cases', () {
    test('treats CRLF as a plain line break', () {
      final lines = parseAnsiLog('one\r\ntwo\r\n');
      expect(lines.map((line) => line.text), ['one', 'two']);
    });

    test('keeps SGR state across a \\r overwrite', () {
      final lines = parseAnsiLog('\x1b[31mdownloading 10%\rdownloading 99%\n');
      expect(lines.single.text, 'downloading 99%');
      expect(lines.single.spans.single.fgIndex, 1);
    });

    test('splits one line into spans at each SGR change', () {
      final lines = parseAnsiLog('a \x1b[1mbold\x1b[22m \x1b[34mblue\x1b[0m.');
      expect(lines.single.text, 'a bold blue.');
      expect(
        lines.single.spans.map((span) => (span.text, span.fgIndex, span.bold)),
        [
          ('a ', null, false),
          ('bold', null, true),
          (' ', null, false),
          ('blue', 4, false),
          ('.', null, false),
        ],
      );
    });

    test('consumes 256-color and truecolor arguments without misreading', () {
      final lines = parseAnsiLog(
        '\x1b[38;5;196mx\x1b[0m \x1b[38;2;1;2;3;1my\x1b[0m\n',
      );
      expect(lines.single.text, 'x y');
      // The extended color itself is unmapped, but the trailing bold
      // parameter after the truecolor triple still applies.
      expect(lines.single.spans.last.bold, isTrue);
    });

    test('drops non-SGR escape sequences', () {
      expect(parseAnsiLog('a\x1b[2Kb\x1b(Bc\n').single.text, 'abc');
    });

    test('survives a truncated escape sequence at end of input', () {
      expect(parseAnsiLog('tail\x1b[31').single.text, 'tail');
      expect(parseAnsiLog('tail\x1b').single.text, 'tail');
    });

    test('keeps a trailing line without a final newline', () {
      expect(parseAnsiLog('a\nb').map((line) => line.text), ['a', 'b']);
    });

    test('returns no lines for an empty trace', () {
      expect(parseAnsiLog(''), isEmpty);
    });
  });
}
