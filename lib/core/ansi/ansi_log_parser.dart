/// Parses the raw trace text GitLab returns for a CI job
/// (`GET /projects/:id/jobs/:id/trace`) into per-line styled spans a UI can
/// render without ever showing raw escape sequences.
///
/// Handles the ordinary GitLab trace shape: plaintext lines, ANSI SGR color
/// and bold codes, `section_start`/`section_end` markers, and carriage-return
/// progress overwrites. Non-SGR escape sequences (cursor movement, GitLab's
/// `\x1b[0K` erase-line after section markers) are stripped, and a `\r` not
/// followed by `\n` discards the line content written so far, which is what
/// hides section markers and keeps only the final state of progress lines.
library;

/// A run of text with one foreground color and weight.
class AnsiSpan {
  const AnsiSpan(this.text, {this.fgIndex, this.bold = false});

  final String text;

  /// Index into the standard 16-color ANSI palette (0-7 normal, 8-15
  /// bright), or null for the log's default color.
  final int? fgIndex;

  final bool bold;
}

/// One rendered log line.
class AnsiLine {
  const AnsiLine(this.spans);

  final List<AnsiSpan> spans;

  /// The line's plain text with all styling dropped.
  String get text => spans.map((span) => span.text).join();
}

/// Parses a full job trace into lines of styled spans.
List<AnsiLine> parseAnsiLog(String trace) {
  final lines = <AnsiLine>[];
  var spans = <AnsiSpan>[];
  final buffer = StringBuffer();
  int? fg;
  var bold = false;

  void flushSpan() {
    if (buffer.isEmpty) return;
    spans.add(AnsiSpan(buffer.toString(), fgIndex: fg, bold: bold));
    buffer.clear();
  }

  void flushLine() {
    flushSpan();
    lines.add(AnsiLine(List.unmodifiable(spans)));
    spans = [];
  }

  void applySgr(List<String> params) {
    var i = 0;
    while (i < params.length) {
      final code = params[i].isEmpty ? 0 : (int.tryParse(params[i]) ?? -1);
      switch (code) {
        case 0:
          fg = null;
          bold = false;
        case 1:
          bold = true;
        case 21 || 22:
          bold = false;
        case >= 30 && <= 37:
          fg = code - 30;
        case 39:
          fg = null;
        case >= 90 && <= 97:
          fg = code - 90 + 8;
        case 38 || 48:
          // ponytail: 256-color and truecolor arguments are consumed but not
          // mapped; add a mapping if GitLab runners start emitting them.
          i += i + 1 < params.length && params[i + 1] == '2' ? 4 : 2;
        default:
          break; // Backgrounds, faint, italic, etc.: ignored.
      }
      i++;
    }
  }

  var i = 0;
  final length = trace.length;
  while (i < length) {
    // Copy the run of ordinary characters up to the next control character
    // in one substring rather than char by char, so multi-megabyte traces
    // parse quickly.
    final runStart = i;
    while (i < length) {
      final unit = trace.codeUnitAt(i);
      if (unit == 0x1b || unit == 0x0d || unit == 0x0a) break;
      i++;
    }
    if (i > runStart) buffer.write(trace.substring(runStart, i));
    if (i >= length) break;

    switch (trace.codeUnitAt(i)) {
      case 0x0a: // \n
        flushLine();
        i++;
      case 0x0d: // \r
        if (i + 1 < length && trace.codeUnitAt(i + 1) == 0x0a) {
          // \r\n is a plain line break.
          flushLine();
          i += 2;
        } else {
          // Overwrite: drop this line's content so far, keep the SGR state.
          buffer.clear();
          spans = [];
          i++;
        }
      case 0x1b: // ESC
        if (i + 1 < length && trace.codeUnitAt(i + 1) == 0x5b /* [ */ ) {
          var end = i + 2;
          while (end < length) {
            final unit = trace.codeUnitAt(end);
            if (unit >= 0x40 && unit <= 0x7e) break; // CSI final byte
            end++;
          }
          if (end < length && trace.codeUnitAt(end) == 0x6d /* m */ ) {
            flushSpan();
            applySgr(trace.substring(i + 2, end).split(';'));
          }
          i = end + 1;
        } else {
          final introducer = i + 1 < length ? trace.codeUnitAt(i + 1) : null;
          final isOsc = introducer == 0x5d; // ]
          final isControlString =
              isOsc ||
              introducer == 0x50 || // P (DCS)
              introducer == 0x58 || // X (SOS)
              introducer == 0x5e || // ^ (PM)
              introducer == 0x5f; // _ (APC)
          if (isControlString) {
            var end = i + 2;
            while (end < length) {
              final unit = trace.codeUnitAt(end);
              if (isOsc && unit == 0x07) {
                end++;
                break;
              }
              if (unit == 0x1b &&
                  end + 1 < length &&
                  trace.codeUnitAt(end + 1) == 0x5c /* \\ */ ) {
                end += 2;
                break;
              }
              end++;
            }
            i = end;
          } else if (introducer != null &&
              introducer >= 0x20 &&
              introducer <= 0x2f) {
            var end = i + 2;
            while (end < length &&
                trace.codeUnitAt(end) >= 0x20 &&
                trace.codeUnitAt(end) <= 0x2f) {
              end++;
            }
            if (end < length &&
                trace.codeUnitAt(end) >= 0x30 &&
                trace.codeUnitAt(end) <= 0x7e) {
              end++;
            }
            i = end;
          } else {
            i += introducer == null ? 1 : 2;
          }
        }
    }
  }
  if (buffer.isNotEmpty || spans.isNotEmpty) flushLine();
  return lines;
}
