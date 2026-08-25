import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';
import 'package:gitsune/features/my_work/data/my_work_repository.dart';

import '../../../support/fixtures.dart';

/// A canned [MyWorkRepository] for widget tests, serving the shared issue and
/// merge request fixtures (or the items passed in) regardless of scope, and
/// recording which scopes were requested.
class FixtureMyWorkRepository implements MyWorkRepository {
  FixtureMyWorkRepository({
    List<Issue>? issues,
    List<MergeRequest>? mergeRequests,
  }) : _issuesFirstPage = issues ?? _issuesFrom('issues_page1'),
       _issuesSecondPage = issues == null
           ? _issuesFrom('issues_page2')
           : const [],
       _mergeRequestsFirstPage =
           mergeRequests ?? _mergeRequestsFrom('merge_requests_page1'),
       _mergeRequestsSecondPage = mergeRequests == null
           ? _mergeRequestsFrom('merge_requests_page2')
           : const [];

  final List<Issue> _issuesFirstPage;
  final List<Issue> _issuesSecondPage;
  final List<MergeRequest> _mergeRequestsFirstPage;
  final List<MergeRequest> _mergeRequestsSecondPage;

  /// Every scope passed to a first-issues-page load, in call order.
  final issueScopeLoads = <MyWorkScope>[];

  /// Every scope passed to a first-merge-requests-page load, in call order.
  final mergeRequestScopeLoads = <MyWorkScope>[];

  int nextIssuePageLoads = 0;
  int nextMergeRequestPageLoads = 0;

  @override
  Future<IssuePage> loadFirstIssuesPage(MyWorkScope scope) async {
    issueScopeLoads.add(scope);
    return IssuePage(
      items: _issuesFirstPage,
      hasMore: _issuesSecondPage.isNotEmpty,
    );
  }

  @override
  Future<IssuePage> loadNextIssuesPage(MyWorkScope scope) async {
    nextIssuePageLoads++;
    return IssuePage(items: _issuesSecondPage, hasMore: false);
  }

  @override
  Future<MergeRequestPage> loadFirstMergeRequestsPage(MyWorkScope scope) async {
    mergeRequestScopeLoads.add(scope);
    return MergeRequestPage(
      items: _mergeRequestsFirstPage,
      hasMore: _mergeRequestsSecondPage.isNotEmpty,
    );
  }

  @override
  Future<MergeRequestPage> loadNextMergeRequestsPage(MyWorkScope scope) async {
    nextMergeRequestPageLoads++;
    return MergeRequestPage(items: _mergeRequestsSecondPage, hasMore: false);
  }

  static List<Issue> _issuesFrom(String fixture) => [
    for (final json in Fixtures.json(fixture) as List)
      Issue.fromJson(json as Map<String, dynamic>),
  ];

  static List<MergeRequest> _mergeRequestsFrom(String fixture) => [
    for (final json in Fixtures.json(fixture) as List)
      MergeRequest.fromJson(json as Map<String, dynamic>),
  ];
}
