import 'package:dio/dio.dart';

import '../../../core/network/keyset_paginator.dart';
import 'issue_models.dart';

class IssuePage {
  const IssuePage({required this.items, required this.hasMore});

  final List<Issue> items;
  final bool hasMore;
}

class IssueNotePage {
  const IssueNotePage({required this.items, required this.hasMore});

  final List<IssueNote> items;
  final bool hasMore;
}

/// Read seam consumed by the issue list and detail screens.
///
/// The first offline cache for recently viewed issues arrives in E14.1, so
/// E6.1 keeps this seam intentionally small and network-backed.
abstract interface class IssuesRepository {
  Future<IssuePage> loadFirstPage(int projectId);

  Future<IssuePage> loadNextPage(int projectId);

  Future<Issue> loadIssue(int projectId, int issueIid);

  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid);

  Future<IssueNotePage> loadNextNotesPage(int projectId, int issueIid);

  /// Creates an issue, returning the created resource as the server shaped it.
  Future<Issue> createIssue(
    int projectId, {
    required String title,
    String description = '',
  });

  /// Posts a comment on an issue, returning the created note.
  Future<IssueNote> createNote(int projectId, int issueIid, String body);

  /// Lists the project's labels for the triage label picker.
  Future<List<IssueLabel>> loadProjectLabels(int projectId);

  /// Lists the project's members for the triage assignee picker.
  Future<List<IssueAuthor>> loadProjectMembers(int projectId);

  /// Applies a triage change (labels, assignees, or a `close`/`reopen` state
  /// event), returning the updated issue as the server shaped it.
  Future<Issue> updateIssue(
    int projectId,
    int issueIid, {
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  });
}

/// GitLab REST v4 issue reader with Link-header pagination.
///
/// `with_labels_details=true` is important here: the default Issues API shape
/// returns label names only, while the Pajamas label treatment needs each
/// label's project-defined background and foreground colors.
class GitLabIssuesRepository implements IssuesRepository {
  GitLabIssuesRepository(this._client);

  final Dio _client;
  final _paginators = <int, KeysetPaginator<Issue>>{};
  final _pageLoads = <int, Future<IssuePage>>{};
  final _notePaginators = <(int, int), KeysetPaginator<IssueNote>>{};
  final _notePageLoads = <(int, int), Future<IssueNotePage>>{};

  @override
  Future<IssuePage> loadFirstPage(int projectId) {
    final paginator = KeysetPaginator<Issue>(
      dio: _client,
      initialUri: _apiUri('projects/$projectId/issues', {
        'scope': 'all',
        'state': 'all',
        'order_by': 'updated_at',
        'sort': 'desc',
        'pagination': 'keyset',
        'per_page': '20',
        'with_labels_details': 'true',
      }),
      decode: Issue.fromJson,
    );
    _paginators[projectId] = paginator;
    return _loadPage(projectId, paginator);
  }

  @override
  Future<IssuePage> loadNextPage(int projectId) {
    final existing = _pageLoads[projectId];
    if (existing != null) return existing;

    final paginator = _paginators[projectId];
    if (paginator == null) {
      throw StateError('Load the first issue page before loading the next.');
    }
    if (!paginator.hasMore) {
      return Future.value(const IssuePage(items: [], hasMore: false));
    }
    return _loadPage(projectId, paginator);
  }

  Future<IssuePage> _loadPage(int projectId, KeysetPaginator<Issue> paginator) {
    final future = paginator.loadNext().then(
      (page) => IssuePage(items: page.items, hasMore: page.hasMore),
    );
    _pageLoads[projectId] = future;
    return future.whenComplete(() {
      if (identical(_pageLoads[projectId], future)) {
        _pageLoads.remove(projectId);
      }
    });
  }

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) async {
    final response = await _client.getUri<List<dynamic>>(
      _apiUri('projects/$projectId/issues', {
        'iids[]': '$issueIid',
        'with_labels_details': 'true',
      }),
    );
    final issues = response.data!;
    if (issues.length != 1) {
      throw StateError(
        'Expected one issue with IID $issueIid, received ${issues.length}.',
      );
    }
    return Issue.fromJson(issues.single as Map<String, dynamic>);
  }

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) {
    final key = (projectId, issueIid);
    final paginator = KeysetPaginator<IssueNote>(
      dio: _client,
      initialUri: _apiUri('projects/$projectId/issues/$issueIid/notes', {
        'sort': 'asc',
        'order_by': 'created_at',
        'per_page': '50',
      }),
      decode: IssueNote.fromJson,
    );
    _notePaginators[key] = paginator;
    return _loadNotePage(key, paginator);
  }

  @override
  Future<IssueNotePage> loadNextNotesPage(int projectId, int issueIid) {
    final key = (projectId, issueIid);
    final existing = _notePageLoads[key];
    if (existing != null) return existing;

    final paginator = _notePaginators[key];
    if (paginator == null) {
      throw StateError('Load the first notes page before loading the next.');
    }
    if (!paginator.hasMore) {
      return Future.value(const IssueNotePage(items: [], hasMore: false));
    }
    return _loadNotePage(key, paginator);
  }

  Future<IssueNotePage> _loadNotePage(
    (int, int) key,
    KeysetPaginator<IssueNote> paginator,
  ) {
    final future = paginator.loadNext().then(
      (page) => IssueNotePage(items: page.items, hasMore: page.hasMore),
    );
    _notePageLoads[key] = future;
    return future.whenComplete(() {
      if (identical(_notePageLoads[key], future)) {
        _notePageLoads.remove(key);
      }
    });
  }

  @override
  Future<Issue> createIssue(
    int projectId, {
    required String title,
    String description = '',
  }) async {
    final response = await _client.postUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/issues'),
      data: {
        'title': title,
        if (description.isNotEmpty) 'description': description,
      },
    );
    return Issue.fromJson(response.data!);
  }

  @override
  Future<IssueNote> createNote(int projectId, int issueIid, String body) async {
    final response = await _client.postUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/issues/$issueIid/notes'),
      data: {'body': body},
    );
    return IssueNote.fromJson(response.data!);
  }

  @override
  Future<List<IssueLabel>> loadProjectLabels(int projectId) async {
    // ponytail: single page of 100; wire a paginator if a project outgrows it.
    final response = await _client.getUri<List<dynamic>>(
      _apiUri('projects/$projectId/labels', {'per_page': '100'}),
    );
    return response.data!.map(IssueLabel.fromJson).toList(growable: false);
  }

  @override
  Future<List<IssueAuthor>> loadProjectMembers(int projectId) async {
    // `members/all` includes inherited members, who are assignable too.
    // ponytail: single page of 100; wire a paginator if a project outgrows it.
    final response = await _client.getUri<List<dynamic>>(
      _apiUri('projects/$projectId/members/all', {'per_page': '100'}),
    );
    return response.data!
        .map((value) => IssueAuthor.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Issue> updateIssue(
    int projectId,
    int issueIid, {
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  }) async {
    final response = await _client.putUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/issues/$issueIid'),
      data: {
        if (labels != null) 'labels': labels.join(','),
        'assignee_ids': ?assigneeIds,
        'state_event': ?stateEvent,
      },
    );
    return Issue.fromJson(response.data!);
  }

  Uri _apiUri(String path, [Map<String, String>? queryParameters]) {
    final base = _client.options.baseUrl.endsWith('/')
        ? _client.options.baseUrl
        : '${_client.options.baseUrl}/';
    return Uri.parse(
      base,
    ).resolve(path).replace(queryParameters: queryParameters);
  }
}
