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
    this.blobs = const [],
    this.codeSearchUnsupported = false,
  });

  final List<SearchProject> projects;
  final List<Issue> issues;
  final List<SearchMergeRequest> mergeRequests;
  final List<SearchBlob> blobs;

  /// When true, code search behaves like an instance without Advanced
  /// Search: [loadFirstBlobsPage] throws [CodeSearchUnsupportedException].
  final bool codeSearchUnsupported;

  int projectSearches = 0;
  int issueSearches = 0;
  int mergeRequestSearches = 0;
  int blobSearches = 0;

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

  @override
  Future<SearchPage<SearchBlob>> loadFirstBlobsPage(String term) async {
    blobSearches++;
    if (codeSearchUnsupported) throw const CodeSearchUnsupportedException();
    return SearchPage(items: blobs, hasMore: false);
  }

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
