import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/features/code/data/repository_tree_repository.dart';

/// Serves a canned repository tree, one directory level per key, mirroring
/// the drill-down shape the real repository reads from its drift cache.
class FixtureRepositoryTreeRepository implements RepositoryTreeRepository {
  FixtureRepositoryTreeRepository([
    Map<String, List<RepositoryTreeEntry>>? directories,
    Map<String, String>? files,
  ]) : _directories = directories ?? fixtureTree(),
       _files = files ?? fixtureFiles();

  final Map<String, List<RepositoryTreeEntry>> _directories;
  final Map<String, String> _files;
  final refreshedPaths = <String>[];
  final refreshedRefs = <String>[];
  final loadedFilePaths = <String>[];

  @override
  Stream<List<RepositoryTreeEntry>> watchDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  }) {
    return Stream.value(List.unmodifiable(_directories[path] ?? const []));
  }

  @override
  Future<void> refreshDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  }) async {
    refreshedPaths.add(path);
    refreshedRefs.add(ref);
  }

  @override
  Future<String> loadFileContent(
    int projectId, {
    required String path,
    String ref = '',
  }) async {
    loadedFilePaths.add(path);
    final content = _files[path];
    if (content == null) throw StateError('no fixture file at $path');
    return content;
  }

  @override
  Uri fileWebUrl({
    required String projectPath,
    required String path,
    String ref = '',
  }) => Uri.https(
    'gitlab.example.com',
    '$projectPath/-/blob/${ref.isEmpty ? 'HEAD' : ref}/$path',
  );
}

/// A three-level fixture tree: root -> `lib` -> `lib/core`.
Map<String, List<RepositoryTreeEntry>> fixtureTree() => {
  '': [
    fixtureTreeEntry(name: 'android', path: 'android', type: 'tree'),
    fixtureTreeEntry(name: 'ios', path: 'ios', type: 'tree'),
    fixtureTreeEntry(name: 'lib', path: 'lib', type: 'tree'),
    fixtureTreeEntry(name: 'test', path: 'test', type: 'tree'),
    fixtureTreeEntry(name: '.gitignore', path: '.gitignore'),
    fixtureTreeEntry(name: 'README.md', path: 'README.md'),
    fixtureTreeEntry(
      name: 'analysis_options.yaml',
      path: 'analysis_options.yaml',
    ),
    fixtureTreeEntry(name: 'cover.png', path: 'cover.png'),
    fixtureTreeEntry(name: 'pubspec.lock', path: 'pubspec.lock'),
    fixtureTreeEntry(name: 'pubspec.yaml', path: 'pubspec.yaml'),
  ],
  'lib': [
    fixtureTreeEntry(name: 'core', path: 'lib/core', type: 'tree'),
    fixtureTreeEntry(name: 'features', path: 'lib/features', type: 'tree'),
    fixtureTreeEntry(name: 'main.dart', path: 'lib/main.dart'),
  ],
  'lib/core': [
    fixtureTreeEntry(name: 'theme', path: 'lib/core/theme', type: 'tree'),
    fixtureTreeEntry(name: 'app_theme.dart', path: 'lib/core/app_theme.dart'),
    fixtureTreeEntry(name: 'tokens.json', path: 'lib/core/tokens.json'),
  ],
};

/// Blob contents served by [FixtureRepositoryTreeRepository.loadFileContent],
/// keyed by repository path. The Dart file exercises every mapped syntax
/// token (keyword, string, comment, number, function name) plus one line
/// long enough to overflow a phone-width viewport.
Map<String, String> fixtureFiles() => {
  'lib/core/app_theme.dart': '''
class Greeter {
  // A deliberately long comment line that overflows a phone-width viewport so the wrap toggle has something real to wrap.
  final String name;
  const Greeter(this.name);

  String greet() => 'Hello, \$name!';
}

const answer = 42;
''',
  'README.md': '# gitsune\n\nA GitLab companion app.\n',
};

RepositoryTreeEntry fixtureTreeEntry({
  required String name,
  required String path,
  String type = 'blob',
  int position = 0,
}) {
  final parent = path.contains('/')
      ? path.substring(0, path.lastIndexOf('/'))
      : '';
  return RepositoryTreeEntry(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
    projectId: 7,
    ref: '',
    parentPath: parent,
    name: name,
    path: path,
    entryType: type,
    position: position,
  );
}
