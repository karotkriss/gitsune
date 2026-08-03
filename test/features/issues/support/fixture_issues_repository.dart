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
}

List<Issue> _issuesFrom(String fixture) => (Fixtures.json(fixture) as List)
    .map((value) => Issue.fromJson(Map<String, dynamic>.from(value as Map)))
    .toList(growable: false);

Issue _issueFrom(String fixture) =>
    Issue.fromJson(Map<String, dynamic>.from(Fixtures.json(fixture) as Map));

List<IssueNote> _notesFrom(String fixture) => (Fixtures.json(fixture) as List)
    .map((value) => IssueNote.fromJson(Map<String, dynamic>.from(value as Map)))
    .toList(growable: false);
