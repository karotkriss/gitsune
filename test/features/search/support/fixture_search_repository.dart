import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/search/data/search_models.dart';
import 'package:gitsune/features/search/data/search_repository.dart';

/// A canned [SearchRepository] for widget tests, backed by whatever items
/// are passed in rather than a fake server.
class FixtureSearchRepository implements SearchRepository {
  FixtureSearchRepository({
    this.projects = const [],
    this.issues = const [],
    this.mergeRequests = const [],
  });

  final List<SearchProject> projects;
  final List<Issue> issues;
  final List<SearchMergeRequest> mergeRequests;
  int projectSearches = 0;
  int issueSearches = 0;
  int mergeRequestSearches = 0;

  @override
  Future<SearchPage<SearchProject>> loadFirstProjectsPage(String term) async {
    projectSearches++;
    return SearchPage(items: projects, hasMore: false);
  }

  @override
  Future<SearchPage<SearchProject>> loadNextProjectsPage(String term) async =>
      const SearchPage(items: [], hasMore: false);

  @override
  Future<SearchPage<Issue>> loadFirstIssuesPage(String term) async {
    issueSearches++;
    return SearchPage(items: issues, hasMore: false);
  }

  @override
  Future<SearchPage<Issue>> loadNextIssuesPage(String term) async =>
      const SearchPage(items: [], hasMore: false);

  @override
  Future<SearchPage<SearchMergeRequest>> loadFirstMergeRequestsPage(
    String term,
  ) async {
    mergeRequestSearches++;
    return SearchPage(items: mergeRequests, hasMore: false);
  }

  @override
  Future<SearchPage<SearchMergeRequest>> loadNextMergeRequestsPage(
    String term,
  ) async => const SearchPage(items: [], hasMore: false);
}
