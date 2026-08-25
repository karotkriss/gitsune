import 'package:dio/dio.dart';

import '../../../core/network/keyset_paginator.dart';
import '../../issues/data/issue_models.dart';
import '../../issues/data/issues_repository.dart' show IssuePage;
import '../../merge_requests/data/merge_request_models.dart';
import '../../merge_requests/data/merge_requests_repository.dart'
    show MergeRequestPage;

/// Which relationship ties an item to the signed-in user, mapped to the
/// `scope` values GitLab's global `GET /issues` and `GET /merge_requests`
/// endpoints accept.
enum MyWorkScope {
  assigned('assigned_to_me'),
  authored('created_by_me');

  const MyWorkScope(this.apiValue);

  final String apiValue;
}

/// Network-backed seam behind the Home "Issues" and "Merge Requests" tiles:
/// the signed-in user's open issues and merge requests across every project.
///
/// Only `state=opened` items are listed - the tiles are a personal work
/// queue, and closed or merged history stays on each project's own list.
/// Like the project-scoped repositories, this stays network-backed with no
/// offline cache.
abstract interface class MyWorkRepository {
  Future<IssuePage> loadFirstIssuesPage(MyWorkScope scope);

  Future<IssuePage> loadNextIssuesPage(MyWorkScope scope);

  Future<MergeRequestPage> loadFirstMergeRequestsPage(MyWorkScope scope);

  Future<MergeRequestPage> loadNextMergeRequestsPage(MyWorkScope scope);
}

/// GitLab REST v4 reader over the global (dashboard-level) issue and merge
/// request endpoints, with Link-header pagination per scope.
class GitLabMyWorkRepository implements MyWorkRepository {
  GitLabMyWorkRepository(this._client);

  final Dio _client;

  final _issuePaginators = <MyWorkScope, KeysetPaginator<Issue>>{};
  final _issuePageLoads = <MyWorkScope, Future<IssuePage>>{};
  final _issueFirstPageRequests = <MyWorkScope, Object>{};
  final _mrPaginators = <MyWorkScope, KeysetPaginator<MergeRequest>>{};
  final _mrPageLoads = <MyWorkScope, Future<MergeRequestPage>>{};
  final _mrFirstPageRequests = <MyWorkScope, Object>{};

  @override
  Future<IssuePage> loadFirstIssuesPage(MyWorkScope scope) {
    final paginator = KeysetPaginator<Issue>(
      dio: _client,
      // `with_labels_details=true` for the same reason as the project issue
      // list: the Pajamas label treatment needs each label's colors.
      initialUri: _apiUri('issues', {
        'scope': scope.apiValue,
        'state': 'opened',
        'order_by': 'updated_at',
        'sort': 'desc',
        'per_page': '20',
        'with_labels_details': 'true',
      }),
      decode: Issue.fromJson,
    );
    return _loadFirst(
      scope,
      paginator,
      _issuePaginators,
      _issuePageLoads,
      _issueFirstPageRequests,
      _toIssuePage,
    );
  }

  @override
  Future<IssuePage> loadNextIssuesPage(MyWorkScope scope) => _loadNext(
    scope,
    _issuePaginators,
    _issuePageLoads,
    _toIssuePage,
    const IssuePage(items: [], hasMore: false),
  );

  @override
  Future<MergeRequestPage> loadFirstMergeRequestsPage(MyWorkScope scope) {
    final paginator = KeysetPaginator<MergeRequest>(
      dio: _client,
      initialUri: _apiUri('merge_requests', {
        'scope': scope.apiValue,
        'state': 'opened',
        'order_by': 'updated_at',
        'sort': 'desc',
        'per_page': '20',
      }),
      decode: MergeRequest.fromJson,
    );
    return _loadFirst(
      scope,
      paginator,
      _mrPaginators,
      _mrPageLoads,
      _mrFirstPageRequests,
      _toMergeRequestPage,
    );
  }

  @override
  Future<MergeRequestPage> loadNextMergeRequestsPage(MyWorkScope scope) =>
      _loadNext(
        scope,
        _mrPaginators,
        _mrPageLoads,
        _toMergeRequestPage,
        const MergeRequestPage(items: [], hasMore: false),
      );

  static IssuePage _toIssuePage(KeysetPage<Issue> page) =>
      IssuePage(items: page.items, hasMore: page.hasMore);

  static MergeRequestPage _toMergeRequestPage(KeysetPage<MergeRequest> page) =>
      MergeRequestPage(items: page.items, hasMore: page.hasMore);

  Future<P> _loadFirst<T, P>(
    MyWorkScope scope,
    KeysetPaginator<T> paginator,
    Map<MyWorkScope, KeysetPaginator<T>> paginators,
    Map<MyWorkScope, Future<P>> pageLoads,
    Map<MyWorkScope, Object> firstPageRequests,
    P Function(KeysetPage<T>) toPage,
  ) {
    final request = Object();
    firstPageRequests[scope] = request;
    final future = _loadPage(scope, paginator, pageLoads, toPage).then((page) {
      if (identical(firstPageRequests[scope], request)) {
        paginators[scope] = paginator;
      }
      return page;
    });
    return future.whenComplete(() {
      if (identical(firstPageRequests[scope], request)) {
        firstPageRequests.remove(scope);
      }
    });
  }

  Future<P> _loadNext<T, P>(
    MyWorkScope scope,
    Map<MyWorkScope, KeysetPaginator<T>> paginators,
    Map<MyWorkScope, Future<P>> pageLoads,
    P Function(KeysetPage<T>) toPage,
    P emptyPage,
  ) {
    final existing = pageLoads[scope];
    if (existing != null) return existing;

    final paginator = paginators[scope];
    if (paginator == null) {
      throw StateError('Load the first page before loading the next.');
    }
    if (!paginator.hasMore) return Future.value(emptyPage);
    return _loadPage(scope, paginator, pageLoads, toPage);
  }

  Future<P> _loadPage<T, P>(
    MyWorkScope scope,
    KeysetPaginator<T> paginator,
    Map<MyWorkScope, Future<P>> pageLoads,
    P Function(KeysetPage<T>) toPage,
  ) {
    final future = paginator.loadNext().then(toPage);
    pageLoads[scope] = future;
    return future.whenComplete(() {
      if (identical(pageLoads[scope], future)) {
        pageLoads.remove(scope);
      }
    });
  }

  Uri _apiUri(String path, Map<String, String> queryParameters) {
    final base = _client.options.baseUrl.endsWith('/')
        ? _client.options.baseUrl
        : '${_client.options.baseUrl}/';
    return Uri.parse(
      base,
    ).resolve(path).replace(queryParameters: queryParameters);
  }
}
