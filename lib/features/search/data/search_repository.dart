import 'package:dio/dio.dart';

import '../../../core/network/keyset_paginator.dart';
import '../../issues/data/issue_models.dart';
import 'search_models.dart';

class SearchPage<T> {
  const SearchPage({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}

/// Read seam over GitLab's search API (`GET /search?scope=...&search=...`),
/// consumed by the search screen.
///
/// Search results are a live, per-query result set rather than a synced
/// local collection, so - like [IssuesRepository] and [PipelinesRepository] -
/// this stays network-backed with no offline cache.
abstract interface class SearchRepository {
  Future<SearchPage<SearchProject>> loadFirstProjectsPage(String term);

  Future<SearchPage<SearchProject>> loadNextProjectsPage(String term);

  Future<SearchPage<Issue>> loadFirstIssuesPage(String term);

  Future<SearchPage<Issue>> loadNextIssuesPage(String term);

  Future<SearchPage<SearchMergeRequest>> loadFirstMergeRequestsPage(
    String term,
  );

  Future<SearchPage<SearchMergeRequest>> loadNextMergeRequestsPage(
    String term,
  );
}

/// GitLab REST v4 search reader with Link-header pagination, one paginator
/// per scope keyed by search term.
class GitLabSearchRepository implements SearchRepository {
  GitLabSearchRepository(this._client);

  final Dio _client;

  final _projectPaginators = <String, KeysetPaginator<SearchProject>>{};
  final _projectPageLoads = <String, Future<SearchPage<SearchProject>>>{};
  final _issuePaginators = <String, KeysetPaginator<Issue>>{};
  final _issuePageLoads = <String, Future<SearchPage<Issue>>>{};
  final _mrPaginators = <String, KeysetPaginator<SearchMergeRequest>>{};
  final _mrPageLoads = <String, Future<SearchPage<SearchMergeRequest>>>{};

  @override
  Future<SearchPage<SearchProject>> loadFirstProjectsPage(String term) {
    final paginator = KeysetPaginator<SearchProject>(
      dio: _client,
      initialUri: _searchUri('projects', term),
      decode: SearchProject.fromJson,
    );
    _projectPaginators[term] = paginator;
    return _loadPage(term, paginator, _projectPageLoads);
  }

  @override
  Future<SearchPage<SearchProject>> loadNextProjectsPage(String term) =>
      _loadNext(term, _projectPaginators, _projectPageLoads);

  @override
  Future<SearchPage<Issue>> loadFirstIssuesPage(String term) {
    final paginator = KeysetPaginator<Issue>(
      dio: _client,
      initialUri: _searchUri('issues', term),
      decode: Issue.fromJson,
    );
    _issuePaginators[term] = paginator;
    return _loadPage(term, paginator, _issuePageLoads);
  }

  @override
  Future<SearchPage<Issue>> loadNextIssuesPage(String term) =>
      _loadNext(term, _issuePaginators, _issuePageLoads);

  @override
  Future<SearchPage<SearchMergeRequest>> loadFirstMergeRequestsPage(
    String term,
  ) {
    final paginator = KeysetPaginator<SearchMergeRequest>(
      dio: _client,
      initialUri: _searchUri('merge_requests', term),
      decode: SearchMergeRequest.fromJson,
    );
    _mrPaginators[term] = paginator;
    return _loadPage(term, paginator, _mrPageLoads);
  }

  @override
  Future<SearchPage<SearchMergeRequest>> loadNextMergeRequestsPage(
    String term,
  ) => _loadNext(term, _mrPaginators, _mrPageLoads);

  Future<SearchPage<T>> _loadNext<T>(
    String term,
    Map<String, KeysetPaginator<T>> paginators,
    Map<String, Future<SearchPage<T>>> pageLoads,
  ) {
    final existing = pageLoads[term];
    if (existing != null) return existing;

    final paginator = paginators[term];
    if (paginator == null) {
      throw StateError('Load the first search page before loading the next.');
    }
    if (!paginator.hasMore) {
      return Future.value(SearchPage<T>(items: const [], hasMore: false));
    }
    return _loadPage(term, paginator, pageLoads);
  }

  Future<SearchPage<T>> _loadPage<T>(
    String term,
    KeysetPaginator<T> paginator,
    Map<String, Future<SearchPage<T>>> pageLoads,
  ) {
    final future = paginator.loadNext().then(
      (page) => SearchPage<T>(items: page.items, hasMore: page.hasMore),
    );
    pageLoads[term] = future;
    return future.whenComplete(() {
      if (identical(pageLoads[term], future)) {
        pageLoads.remove(term);
      }
    });
  }

  Uri _searchUri(String scope, String term) {
    final base = _client.options.baseUrl.endsWith('/')
        ? _client.options.baseUrl
        : '${_client.options.baseUrl}/';
    return Uri.parse(base).resolve('search').replace(
      queryParameters: {'scope': scope, 'search': term, 'per_page': '20'},
    );
  }
}
