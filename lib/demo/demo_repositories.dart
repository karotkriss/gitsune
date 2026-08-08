/// Demo-only in-memory repositories for the web gallery (`gallery_main.dart`).
///
/// These mirror the widget-test fixture repositories in
/// `test/features/*/support/fixture_*_repository.dart` (which lib/ cannot
/// import), serving the same recorded GitLab payloads from
/// `demo_fixtures.dart` instead of the filesystem: no network, no drift.
library;

import 'dart:async';
import 'dart:convert';

import '../core/ci/ci_status.dart';
import '../core/database/app_database.dart';
import '../core/diff/diff_file.dart';
import '../core/repository/offline_first_repository.dart';
import '../features/code/data/repository_tree_repository.dart';
import '../features/issues/data/issue_models.dart';
import '../features/issues/data/issues_repository.dart';
import '../features/merge_requests/data/merge_request_discussion_models.dart';
import '../features/merge_requests/data/merge_request_models.dart';
import '../features/merge_requests/data/merge_requests_repository.dart';
import '../features/pipelines/data/pipeline_models.dart';
import '../features/pipelines/data/pipelines_repository.dart';
import '../features/releases/data/releases_repository.dart';
import '../features/search/data/search_models.dart';
import '../features/search/data/search_repository.dart';
import 'demo_fixtures.dart';

Map<String, dynamic> _map(dynamic value) =>
    Map<String, dynamic>.from(value as Map);

List<Map<String, dynamic>> _maps(String fixture) =>
    (demoJson(fixture) as List).map(_map).toList(growable: false);

class DemoIssuesRepository implements IssuesRepository {
  DemoIssuesRepository()
    : _firstPage = _issuesFrom('issues_page1'),
      _secondPage = _issuesFrom('issues_page2'),
      _issue = Issue.fromJson(_map(demoJson('issue_142'))),
      _firstNotes = _notesFrom('issue_142_notes_page1'),
      _secondNotes = _notesFrom('issue_142_notes_page2');

  final List<Issue> _firstPage;
  final List<Issue> _secondPage;
  Issue _issue;
  final List<IssueNote> _firstNotes;
  final List<IssueNote> _secondNotes;

  @override
  Future<IssuePage> loadFirstPage(int projectId) async =>
      IssuePage(items: _firstPage, hasMore: true);

  @override
  Future<IssuePage> loadNextPage(int projectId) async =>
      IssuePage(items: _secondPage, hasMore: false);

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) async => _issue;

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) async =>
      IssueNotePage(items: _firstNotes, hasMore: true);

  @override
  Future<IssueNotePage> loadNextNotesPage(int projectId, int issueIid) async =>
      IssueNotePage(items: _secondNotes, hasMore: false);

  @override
  Future<Issue> createIssue(
    int projectId, {
    required String title,
    String description = '',
  }) async => Issue.fromJson(_map(demoJson('issue_created_143')));

  @override
  Future<IssueNote> createNote(int projectId, int issueIid, String body) async =>
      IssueNote.fromJson(_map(demoJson('issue_142_note_created')));

  @override
  Future<List<IssueLabel>> loadProjectLabels(int projectId) async =>
      (demoJson('project_7_labels') as List)
          .map(IssueLabel.fromJson)
          .toList(growable: false);

  @override
  Future<List<IssueAuthor>> loadProjectMembers(int projectId) async =>
      _maps('project_7_members')
          .map(IssueAuthor.fromJson)
          .toList(growable: false);

  @override
  Future<Issue> updateIssue(
    int projectId,
    int issueIid, {
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  }) async {
    // Mirrors the real endpoint closely enough for a click-through demo: the
    // update response carries labels as plain names and flips state.
    final updated = _map(demoJson('issue_142'));
    if (labels != null) updated['labels'] = labels;
    if (assigneeIds != null) {
      updated['assignees'] = [
        for (final member in _maps('project_7_members'))
          if (assigneeIds.contains(member['id'])) member,
      ];
    }
    if (stateEvent != null) {
      updated['state'] = stateEvent == 'close' ? 'closed' : 'opened';
    }
    return _issue = Issue.fromJson(updated);
  }

  static List<Issue> _issuesFrom(String fixture) =>
      _maps(fixture).map(Issue.fromJson).toList(growable: false);

  static List<IssueNote> _notesFrom(String fixture) =>
      _maps(fixture).map(IssueNote.fromJson).toList(growable: false);
}

class DemoMergeRequestsRepository implements MergeRequestsRepository {
  DemoMergeRequestsRepository()
    : _firstPage = _mergeRequestsFrom('merge_requests_page1'),
      _secondPage = _mergeRequestsFrom('merge_requests_page2'),
      _mergeRequest = _mergeRequestFrom('merge_request_142'),
      _approvals = _approvalsFrom('merge_request_142_approvals');

  final List<MergeRequest> _firstPage;
  final List<MergeRequest> _secondPage;
  MergeRequest _mergeRequest;
  MergeRequestApprovals _approvals;
  final Map<String, bool> _resolvedOverrides = {};

  @override
  Future<MergeRequestPage> loadFirstPage(int projectId) async =>
      MergeRequestPage(items: _firstPage, hasMore: true);

  @override
  Future<MergeRequestPage> loadNextPage(int projectId) async =>
      MergeRequestPage(items: _secondPage, hasMore: false);

  @override
  Future<MergeRequest> loadMergeRequest(int projectId, int mergeIid) async =>
      _mergeRequest;

  @override
  Future<MergeRequestPipelinePage> loadFirstPipelinePage(
    int projectId,
    int mergeIid,
  ) async => MergeRequestPipelinePage(
    items: [
      for (final fixture in [
        'merge_request_142_pipelines_page1',
        'merge_request_142_pipelines_page2',
      ])
        ..._maps(fixture).map(MergeRequestPipeline.fromJson),
    ],
    hasMore: false,
  );

  @override
  Future<MergeRequestPipelinePage> loadNextPipelinePage(
    int projectId,
    int mergeIid,
  ) async => const MergeRequestPipelinePage(items: [], hasMore: false);

  @override
  Future<MergeRequestApprovals> loadApprovals(
    int projectId,
    int mergeIid,
  ) async => _approvals;

  @override
  Future<MergeRequestApprovals> approve(int projectId, int mergeIid) async =>
      _approvals = _approvalsFrom('merge_request_142_approved');

  @override
  Future<MergeRequestApprovals> unapprove(int projectId, int mergeIid) async =>
      _approvals = _approvalsFrom('merge_request_142_unapproved');

  @override
  Future<MergeRequest> merge(int projectId, int mergeIid) async =>
      _mergeRequest = _mergeRequestFrom('merge_request_142_merged');

  @override
  Future<List<DiffFile>> loadDiffs(int projectId, int mergeIid) async => [
    for (final fixture in [
      'merge_request_142_diffs_page1',
      'merge_request_142_diffs_page2',
    ])
      ..._maps(fixture).map(DiffFile.fromJson),
  ];

  @override
  Future<List<Discussion>> loadDiscussions(int projectId, int mergeIid) async =>
      _rawDiscussions().map(Discussion.fromJson).toList(growable: false);

  @override
  Future<Discussion> createDiffDiscussion(
    int projectId,
    int mergeIid, {
    required String body,
    required DiffPosition position,
  }) async => Discussion.fromJson(
    _map(demoJson('merge_request_142_discussion_created')),
  );

  @override
  Future<Discussion> setDiscussionResolved(
    int projectId,
    int mergeIid,
    String discussionId, {
    required bool resolved,
  }) async {
    _resolvedOverrides[discussionId] = resolved;
    return _rawDiscussions()
        .map(Discussion.fromJson)
        .firstWhere((discussion) => discussion.id == discussionId);
  }

  List<Map<String, dynamic>> _rawDiscussions() => [
    for (final fixture in [
      'merge_request_142_discussions_page1',
      'merge_request_142_discussions_page2',
    ])
      for (final raw in _maps(fixture))
        _withResolvedOverride(raw),
  ];

  Map<String, dynamic> _withResolvedOverride(Map<String, dynamic> raw) {
    final resolved = _resolvedOverrides[raw['id']];
    if (resolved == null) return raw;
    final copy = Map<String, dynamic>.from(raw);
    copy['notes'] = [
      for (final note in copy['notes'] as List)
        {
          ...(note as Map).cast<String, dynamic>(),
          if (note['resolvable'] == true) 'resolved': resolved,
        },
    ];
    return copy;
  }

  static List<MergeRequest> _mergeRequestsFrom(String fixture) =>
      _maps(fixture).map(MergeRequest.fromJson).toList(growable: false);

  static MergeRequest _mergeRequestFrom(String fixture) =>
      MergeRequest.fromJson(_map(demoJson(fixture)));

  static MergeRequestApprovals _approvalsFrom(String fixture) =>
      MergeRequestApprovals.fromJson(_map(demoJson(fixture)));
}

class DemoPipelinesRepository implements PipelinesRepository {
  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) async =>
      PipelineDetails(
        pipeline: Pipeline.fromJson(_map(demoJson('pipeline_88123'))),
        jobs: _jobs(),
      );

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) async =>
      _updatedJob(jobId, CiStatus.running, newId: jobId + 10000);

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) async =>
      _updatedJob(jobId, CiStatus.canceled);

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) async =>
      _updatedJob(jobId, CiStatus.running);

  @override
  Future<String> loadJobLog(int projectId, int jobId) async => demoJobTrace;

  List<PipelineJob> _jobs() => _maps('pipeline_88123_jobs')
      .map(PipelineJob.fromJson)
      .toList(growable: false);

  PipelineJob _updatedJob(int jobId, CiStatus status, {int? newId}) {
    final original = _jobs().firstWhere((job) => job.id == jobId);
    return PipelineJob(
      id: newId ?? original.id,
      name: original.name,
      stage: original.stage,
      status: status,
      allowFailure: original.allowFailure,
    );
  }
}

class DemoTodosRepository implements OfflineFirstRepository<List<TodoItem>> {
  final List<TodoItem> _todos = demoTodos();

  @override
  Future<void> refresh() async {}

  @override
  Stream<List<TodoItem>> watch() => Stream.value(List.unmodifiable(_todos));
}

/// Same shape as the widget tests' `fixtureTodos`, retargeted at project 7
/// so tapping a to-do deep-links into the wired demo detail screens.
List<TodoItem> demoTodos() => [
  _demoTodo(
    id: 102,
    actionName: 'review_requested',
    targetType: 'MergeRequest',
    targetIid: 142,
    targetTitle: 'Add instance switcher sheet',
    body: 'Ade requested your review',
    createdAt: DateTime.utc(2026, 8, 7, 21),
  ),
  _demoTodo(
    id: 101,
    actionName: 'assigned',
    targetType: 'Issue',
    targetIid: 142,
    targetTitle: 'Sign-in: PAT fallback hidden behind wrong affordance',
    body: 'Priya assigned you',
    createdAt: DateTime.utc(2026, 8, 6, 9),
  ),
  _demoTodo(
    id: 88123,
    actionName: 'build_failed',
    targetType: 'Pipeline',
    body: 'Pipeline failed on main',
    createdAt: DateTime.utc(2026, 8, 4, 10),
  ),
];

TodoItem _demoTodo({
  required int id,
  required String actionName,
  required String targetType,
  int? targetIid,
  String? targetTitle,
  required String body,
  required DateTime createdAt,
}) {
  final targetPath = switch (targetType) {
    'MergeRequest' => 'merge_requests/${targetIid ?? id}',
    'Issue' => 'issues/${targetIid ?? id}',
    'Pipeline' => 'pipelines/$id',
    _ => 'todos/$id',
  };
  return TodoItem(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
    todoId: id,
    projectId: 7,
    projectPathWithNamespace: 'gitsune/app',
    authorName: 'Demo Author',
    authorUsername: 'demo',
    actionName: actionName,
    targetType: targetType,
    targetIid: targetIid,
    targetTitle: targetTitle,
    targetUrl: 'https://gitlab.example.com/gitsune/app/-/$targetPath',
    body: body,
    state: 'pending',
    createdAt: createdAt,
  );
}

class DemoSearchRepository implements SearchRepository {
  DemoSearchRepository()
    : _projects = _maps('search_projects_page1')
          .map(SearchProject.fromJson)
          .toList(growable: false),
      _issues = _maps('issues_page1')
          .map(Issue.fromJson)
          .toList(growable: false),
      _mergeRequests = _maps('search_merge_requests_page1')
          .map(SearchMergeRequest.fromJson)
          .toList(growable: false),
      _blobs = _maps('search_blobs_page1')
          .map(SearchBlob.fromJson)
          .toList(growable: false);

  final List<SearchProject> _projects;
  final List<Issue> _issues;
  final List<SearchMergeRequest> _mergeRequests;
  final List<SearchBlob> _blobs;

  @override
  Future<SearchPage<SearchProject>> loadFirstProjectsPage(String term) async =>
      SearchPage(items: _projects, hasMore: false);

  @override
  Future<SearchPage<SearchProject>> loadNextProjectsPage(String term) async =>
      const SearchPage(items: [], hasMore: false);

  @override
  Future<SearchPage<Issue>> loadFirstIssuesPage(String term) async =>
      SearchPage(items: _issues, hasMore: false);

  @override
  Future<SearchPage<Issue>> loadNextIssuesPage(String term) async =>
      const SearchPage(items: [], hasMore: false);

  @override
  Future<SearchPage<SearchMergeRequest>> loadFirstMergeRequestsPage(
    String term,
  ) async => SearchPage(items: _mergeRequests, hasMore: false);

  @override
  Future<SearchPage<SearchMergeRequest>> loadNextMergeRequestsPage(
    String term,
  ) async => const SearchPage(items: [], hasMore: false);

  @override
  Future<SearchPage<SearchBlob>> loadFirstBlobsPage(String term) async =>
      SearchPage(items: _blobs, hasMore: false);

  @override
  Future<SearchPage<SearchBlob>> loadNextBlobsPage(String term) async =>
      const SearchPage(items: [], hasMore: false);

  @override
  Uri codeSearchWebUrl(String term) => Uri.https(
    'gitlab.example.com',
    '/search',
    {'search': term, 'scope': 'blobs'},
  );
}

class DemoReleasesRepository implements ReleasesRepository {
  final List<ReleaseEntry> _releases = demoReleases();

  @override
  Stream<List<ReleaseEntry>> watchReleases(int projectId) =>
      Stream.value(List.unmodifiable(_releases));

  @override
  Stream<ReleaseEntry?> watchRelease(int projectId, String tagName) =>
      Stream.value(
        _releases.where((release) => release.tagName == tagName).firstOrNull,
      );

  @override
  Future<void> refreshReleases(int projectId) async {}

  /// Never touches a filesystem (there is none on web); just plays the
  /// progress callbacks so the screen's download UI is demonstrable.
  @override
  Future<void> downloadAsset(
    ReleaseAssetLink asset,
    String destinationPath, {
    void Function(int received, int total)? onProgress,
  }) async {
    onProgress?.call(5, 10);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    onProgress?.call(10, 10);
  }
}

List<ReleaseEntry> demoReleases() {
  final pages = [
    demoJson('releases_page1') as List,
    demoJson('releases_page2') as List,
  ];
  var position = 0;
  return [
    for (final page in pages)
      for (final release in page.map(_map))
        ReleaseEntry(
          instanceHost: 'gitlab.example.com',
          accountId: 'alice',
          projectId: 7,
          tagName: release['tag_name'] as String,
          name: release['name'] as String? ?? release['tag_name'] as String,
          description: release['description'] as String? ?? '',
          releasedAt: DateTime.parse(
            (release['released_at'] ?? release['created_at']) as String,
          ),
          authorName:
              (release['author'] as Map<String, dynamic>?)?['name'] as String?,
          assetsJson: jsonEncode(release['assets'] ?? const {}),
          position: position++,
        ),
  ];
}

class DemoRepositoryTreeRepository implements RepositoryTreeRepository {
  final Map<String, List<RepositoryTreeEntry>> _directories = demoTree();
  final Map<String, String> _files = demoFiles();

  @override
  Stream<List<RepositoryTreeEntry>> watchDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  }) => Stream.value(List.unmodifiable(_directories[path] ?? const []));

  @override
  Future<void> refreshDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  }) async {}

  @override
  Future<String> loadFileContent(
    int projectId, {
    required String path,
    String ref = '',
  }) async {
    final content = _files[path];
    if (content == null) {
      throw StateError('no demo file at $path');
    }
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

/// A three-level demo tree: root -> `lib` -> `lib/core`, mirroring the
/// widget tests' `fixtureTree`.
Map<String, List<RepositoryTreeEntry>> demoTree() => {
  '': [
    _treeEntry(name: 'android', path: 'android', type: 'tree'),
    _treeEntry(name: 'ios', path: 'ios', type: 'tree'),
    _treeEntry(name: 'lib', path: 'lib', type: 'tree'),
    _treeEntry(name: 'test', path: 'test', type: 'tree'),
    _treeEntry(name: '.gitignore', path: '.gitignore'),
    _treeEntry(name: 'README.md', path: 'README.md'),
    _treeEntry(name: 'analysis_options.yaml', path: 'analysis_options.yaml'),
    _treeEntry(name: 'pubspec.lock', path: 'pubspec.lock'),
    _treeEntry(name: 'pubspec.yaml', path: 'pubspec.yaml'),
  ],
  'lib': [
    _treeEntry(name: 'core', path: 'lib/core', type: 'tree'),
    _treeEntry(name: 'features', path: 'lib/features', type: 'tree'),
    _treeEntry(name: 'main.dart', path: 'lib/main.dart'),
  ],
  'lib/core': [
    _treeEntry(name: 'theme', path: 'lib/core/theme', type: 'tree'),
    _treeEntry(name: 'app_theme.dart', path: 'lib/core/app_theme.dart'),
    _treeEntry(name: 'tokens.json', path: 'lib/core/tokens.json'),
  ],
};

Map<String, String> demoFiles() => {
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

RepositoryTreeEntry _treeEntry({
  required String name,
  required String path,
  String type = 'blob',
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
    position: 0,
  );
}
