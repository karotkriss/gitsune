/// Maps a file path to the `re_highlight` language id used to highlight it.
library;

/// The `re_highlight`/highlight.js language id used when no extension or
/// filename match is found, or the path has no extension at all.
const String plainTextLanguageId = 'plaintext';

const Map<String, String> _extensionLanguages = {
  'dart': 'dart',
  'js': 'javascript',
  'jsx': 'javascript',
  'mjs': 'javascript',
  'cjs': 'javascript',
  'ts': 'typescript',
  'tsx': 'typescript',
  'py': 'python',
  'rb': 'ruby',
  'go': 'go',
  'rs': 'rust',
  'java': 'java',
  'kt': 'kotlin',
  'kts': 'kotlin',
  'swift': 'swift',
  'c': 'c',
  'h': 'c',
  'cpp': 'cpp',
  'cc': 'cpp',
  'cxx': 'cpp',
  'hpp': 'cpp',
  'm': 'objectivec',
  'mm': 'objectivec',
  'cs': 'csharp',
  'php': 'php',
  'sh': 'bash',
  'bash': 'bash',
  'zsh': 'bash',
  'yml': 'yaml',
  'yaml': 'yaml',
  'json': 'json',
  'xml': 'xml',
  'html': 'xml',
  'htm': 'xml',
  'vue': 'xml',
  'css': 'css',
  'scss': 'scss',
  'less': 'less',
  'sql': 'sql',
  'md': 'markdown',
  'markdown': 'markdown',
  'graphql': 'graphql',
  'diff': 'diff',
  'patch': 'diff',
  'toml': 'ini',
  'ini': 'ini',
  'cfg': 'ini',
  'gradle': 'gradle',
  'proto': 'protobuf',
  'lua': 'lua',
  'pl': 'perl',
  'r': 'r',
  'scala': 'scala',
  'groovy': 'groovy',
};

const Map<String, String> _filenameLanguages = {
  'dockerfile': 'dockerfile',
  'makefile': 'makefile',
  'gemfile': 'ruby',
  'rakefile': 'ruby',
};

/// Detects the `re_highlight` language id for [path] from its filename or
/// extension, falling back to [plainTextLanguageId] for unknown or
/// extension-less files.
String detectLanguageId(String path) {
  final fileName = path.split('/').last.toLowerCase();
  final byName = _filenameLanguages[fileName];
  if (byName != null) return byName;

  final dot = fileName.lastIndexOf('.');
  if (dot <= 0) return plainTextLanguageId;
  return _extensionLanguages[fileName.substring(dot + 1)] ??
      plainTextLanguageId;
}
