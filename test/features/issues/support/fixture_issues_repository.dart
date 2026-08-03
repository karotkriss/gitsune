import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';

import '../../../support/fixtures.dart';

class FixtureIssuesRepository implements IssuesRepository {
  FixtureIssuesRepository()
    : _firstPage = _issuesFrom('issues_page1'),
      _secondPage = _issuesFrom('issues_page2'),
      _issue = _issueFrom('issue_142'),
      _firstNotes = _notesFrom('issue_142_notes_page1'),
      _secondNotes = _notesFrom('issue_142_notes_page2');

  final List<Issue> _firstPage;
  final List<Issue> _secondPage;
  final Issue _issue;
  final List<IssueNote> _firstNotes;
  final List<IssueNote> _secondNotes;
  int firstPageLoads = 0;
  int nextPageLoads = 0;
  int issueLoads = 0;
  int firstNotesLoads = 0;
  int nextNotesLoads = 0;
  final createdIssues = <({int projectId, String title, String description})>[];
  final createdNotes = <({int projectId, int issueIid, String body})>[];
  final updateCalls =
      <
        ({
          int projectId,
          int issueIid,
          List<String>? labels,
          List<int>? assigneeIds,
          String? stateEvent,
        })
      >[];
  Map<String, dynamic> _issueJson = Map<String, dynamic>.from(
    Fixtures.json('issue_142') as Map,
  );

  @override
  Future<IssuePage> loadFirstPage(int projectId) async {
    firstPageLoads++;
    return IssuePage(items: _firstPage, hasMore: true);
  }

  @override
  Future<IssuePage> loadNextPage(int projectId) async {
    nextPageLoads++;
    return IssuePage(items: _secondPage, hasMore: false);
  }

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) async {
    issueLoads++;
    return _issue;
  }

  @override
  Future<IssueNotePage> loadFirstNotesPage(int projectId, int issueIid) async {
    firstNotesLoads++;
    return IssueNotePage(items: _firstNotes, hasMore: true);
  }

  @override
  Future<IssueNotePage> loadNextNotesPage(int projectId, int issueIid) async {
    nextNotesLoads++;
    return IssueNotePage(items: _secondNotes, hasMore: false);
  }

  @override
  Future<Issue> createIssue(
    int projectId, {
    required String title,
    String description = '',
  }) async {
    createdIssues.add((
      projectId: projectId,
      title: title,
      description: description,
    ));
    return _issueFrom('issue_created_143');
  }

  @override
  Future<IssueNote> createNote(int projectId, int issueIid, String body) async {
    createdNotes.add((projectId: projectId, issueIid: issueIid, body: body));
    return IssueNote.fromJson(
      Map<String, dynamic>.from(Fixtures.json('issue_142_note_created') as Map),
    );
  }

  @override
  Future<List<IssueLabel>> loadProjectLabels(int projectId) async =>
      (Fixtures.json('project_7_labels') as List)
          .map(IssueLabel.fromJson)
          .toList(growable: false);

  @override
  Future<List<IssueAuthor>> loadProjectMembers(int projectId) async =>
      (Fixtures.json('project_7_members') as List)
          .map(
            (value) =>
                IssueAuthor.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false);

  @override
  Future<Issue> updateIssue(
    int projectId,
    int issueIid, {
    List<String>? labels,
    List<int>? assigneeIds,
    String? stateEvent,
  }) async {
    updateCalls.add((
      projectId: projectId,
      issueIid: issueIid,
      labels: labels,
      assigneeIds: assigneeIds,
      stateEvent: stateEvent,
    ));
    _issueJson = applyIssueUpdateJson(_issueJson, {
      if (labels != null) 'labels': labels.join(','),
      'assignee_ids': ?assigneeIds,
      'state_event': ?stateEvent,
    });
    return Issue.fromJson(_issueJson);
  }
}

/// Applies a GitLab-shaped issue update body to a raw issue JSON map the way
/// the real endpoint would, including returning labels as plain names (the
/// update response carries no label details).
Map<String, dynamic> applyIssueUpdateJson(
  Map<String, dynamic> issue,
  Map<String, dynamic> body,
) {
  final updated = Map<String, dynamic>.from(issue);
  if (body['labels'] case final String labels) {
    updated['labels'] = labels.isEmpty ? <String>[] : labels.split(',');
  }
  if (body['assignee_ids'] case final List<dynamic> assigneeIds) {
    updated['assignees'] = [
      for (final member in Fixtures.json('project_7_members') as List)
        if (assigneeIds.contains((member as Map)['id'])) member,
    ];
  }
  if (body['state_event'] case final String stateEvent) {
    updated['state'] = stateEvent == 'close' ? 'closed' : 'opened';
  }
  updated['updated_at'] = '2026-08-02T10:00:00Z';
  return updated;
}

List<Issue> _issuesFrom(String fixture) => (Fixtures.json(fixture) as List)
    .map((value) => Issue.fromJson(Map<String, dynamic>.from(value as Map)))
    .toList(growable: false);

Issue _issueFrom(String fixture) =>
    Issue.fromJson(Map<String, dynamic>.from(Fixtures.json(fixture) as Map));

List<IssueNote> _notesFrom(String fixture) => (Fixtures.json(fixture) as List)
    .map((value) => IssueNote.fromJson(Map<String, dynamic>.from(value as Map)))
    .toList(growable: false);
