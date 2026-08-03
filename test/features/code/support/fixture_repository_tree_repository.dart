import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/features/code/data/repository_tree_repository.dart';

/// Serves a canned repository tree, one directory level per key, mirroring
/// the drill-down shape the real repository reads from its drift cache.
class FixtureRepositoryTreeRepository implements RepositoryTreeRepository {
  FixtureRepositoryTreeRepository([
    Map<String, List<RepositoryTreeEntry>>? directories,
  ]) : _directories = directories ?? fixtureTree();

  final Map<String, List<RepositoryTreeEntry>> _directories;
  final refreshedPaths = <String>[];
  final refreshedRefs = <String>[];

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
