import 'package:flutter/painting.dart';

import '../theme/app_theme.dart';

/// Groups of `re_highlight`/highlight.js scope names that map onto the same
/// [GsTheme] code color, kept in one place so the native `TextSpan` theme
/// ([gsSyntaxTextTheme]) and the WebView CSS theme ([gsSyntaxCss]) can never
/// drift apart.
const Map<String, List<String>> _scopeGroups = {
  'codeKeyword': [
    'keyword',
    'built_in',
    'type',
    'literal',
    'meta',
    'meta-keyword',
    'selector-tag',
    'template-tag',
    'template-variable',
    'variable.language_',
  ],
  'codeString': ['string', 'regexp', 'meta-string', 'symbol', 'char'],
  'codeComment': ['comment', 'quote', 'doctag'],
  'codeFunction': [
    'title',
    'title.function_',
    'title.class_',
    'section',
    'name',
    'tag',
    'attr',
    'attribute',
    'selector-id',
    'selector-class',
    'selector-attr',
    'selector-pseudo',
  ],
  'codeNumber': ['number'],
};

/// The `re_highlight` scope-to-[TextStyle] theme for the native highlighting
/// path, built from [GsTheme]'s five code colors (`codeKeyword`, `codeString`,
/// `codeComment`, `codeFunction`, `codeNumber`). Scopes outside these groups
/// fall back to the caller's base style (plain [GsTheme.mono] text color).
Map<String, TextStyle> gsSyntaxTextTheme(GsTheme gs) {
  final colors = <String, Color>{
    'codeKeyword': gs.codeKeyword,
    'codeString': gs.codeString,
    'codeComment': gs.codeComment,
    'codeFunction': gs.codeFunction,
    'codeNumber': gs.codeNumber,
  };
  return {
    for (final MapEntry(key: group, value: scopes) in _scopeGroups.entries)
      for (final scope in scopes)
        scope: TextStyle(
          color: colors[group],
          fontStyle: group == 'codeComment' ? FontStyle.italic : null,
        ),
  };
}

/// The same color mapping as [gsSyntaxTextTheme], rendered as `.hljs-*` CSS
/// rules for the WebView fallback so both engines produce visually
/// consistent output from the same token layer.
String gsSyntaxCss(GsTheme gs) {
  final colors = <String, Color>{
    'codeKeyword': gs.codeKeyword,
    'codeString': gs.codeString,
    'codeComment': gs.codeComment,
    'codeFunction': gs.codeFunction,
    'codeNumber': gs.codeNumber,
  };
  final buffer = StringBuffer()
    ..writeln('body { background: ${_hex(gs.codeBg)}; margin: 0; }')
    ..writeln(
      'pre { margin: 0; padding: 12px; overflow: auto; '
      'background: ${_hex(gs.codeBg)}; }',
    )
    ..writeln(
      'code { font-family: monospace; font-size: 13px; line-height: 20px; '
      'white-space: pre; color: ${_hex(gs.textDefault)}; }',
    );
  for (final MapEntry(key: group, value: scopes) in _scopeGroups.entries) {
    final style = group == 'codeComment' ? 'italic' : 'normal';
    for (final scope in scopes) {
      buffer.writeln(
        '${_cssSelector(scope)} '
        '{ color: ${_hex(colors[group]!)}; font-style: $style; }',
      );
    }
  }
  return buffer.toString();
}

// highlight.js emits a dotted scope (e.g. `title.function_`) as multiple DOM
// classes, `hljs-title` plus `function_` verbatim, so the matching CSS is a
// compound selector chaining them, not a single escaped class name.
String _cssSelector(String scope) {
  final pieces = scope.split('.');
  final rest = pieces.skip(1).map((p) => '.$p').join();
  return '.hljs-${pieces.first}$rest';
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
