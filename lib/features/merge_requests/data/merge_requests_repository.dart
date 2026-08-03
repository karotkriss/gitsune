import 'package:dio/dio.dart';

import '../../../core/network/keyset_paginator.dart';
import 'merge_request_models.dart';

class MergeRequestPage {
  const MergeRequestPage({required this.items, required this.hasMore});

  final List<MergeRequest> items;
  final bool hasMore;
}

/// Read seam consumed by the merge request list and detail shell.
///
/// E14.1 adds the bounded offline cache for recently viewed merge requests.
/// Until then this stays lightweight and network-backed, like the E3.3 seam.
abstract interface class MergeRequestsRepository {
  Future<MergeRequestPage> loadFirstPage(int projectId);

  Future<MergeRequestPage> loadNextPage(int projectId);

  Future<MergeRequestDetails> loadMergeRequest(int projectId, int mergeIid);
}

/// GitLab REST v4 merge request reader with Link-header pagination.
class GitLabMergeRequestsRepository implements MergeRequestsRepository {
  GitLabMergeRequestsRepository(this._client);

  final Dio _client;
  final _paginators = <int, KeysetPaginator<MergeRequest>>{};
  final _pageLoads = <int, Future<MergeRequestPage>>{};

  @override
  Future<MergeRequestPage> loadFirstPage(int projectId) {
    final paginator = KeysetPaginator<MergeRequest>(
      dio: _client,
      initialUri: _apiUri('projects/$projectId/merge_requests', {
        'scope': 'all',
        'state': 'all',
        'order_by': 'updated_at',
        'sort': 'desc',
        'pagination': 'keyset',
        'per_page': '20',
      }),
      decode: MergeRequest.fromJson,
    );
    _paginators[projectId] = paginator;
    return _loadPage(projectId, paginator);
  }

  @override
  Future<MergeRequestPage> loadNextPage(int projectId) {
    final existing = _pageLoads[projectId];
    if (existing != null) return existing;

    final paginator = _paginators[projectId];
    if (paginator == null) {
      throw StateError(
        'Load the first merge request page before loading the next.',
      );
    }
    if (!paginator.hasMore) {
      return Future.value(const MergeRequestPage(items: [], hasMore: false));
    }
    return _loadPage(projectId, paginator);
  }

  Future<MergeRequestPage> _loadPage(
    int projectId,
    KeysetPaginator<MergeRequest> paginator,
  ) {
    final future = paginator.loadNext().then(
      (page) => MergeRequestPage(items: page.items, hasMore: page.hasMore),
    );
    _pageLoads[projectId] = future;
    return future.whenComplete(() {
      if (identical(_pageLoads[projectId], future)) {
        _pageLoads.remove(projectId);
      }
    });
  }

  @override
  Future<MergeRequestDetails> loadMergeRequest(
    int projectId,
    int mergeIid,
  ) async {
    final results = await Future.wait<Object>([
      _loadDetails(projectId, mergeIid),
      _loadPipelines(projectId, mergeIid),
      _loadApprovals(projectId, mergeIid),
    ]);
    return MergeRequestDetails(
      mergeRequest: results[0] as MergeRequest,
      pipelines: results[1] as List<MergeRequestPipeline>,
      approvals: results[2] as MergeRequestApprovals,
    );
  }

  Future<MergeRequest> _loadDetails(int projectId, int mergeIid) async {
    final response = await _client.getUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid'),
    );
    return MergeRequest.fromJson(response.data!);
  }

  Future<List<MergeRequestPipeline>> _loadPipelines(
    int projectId,
    int mergeIid,
  ) async {
    final paginator = KeysetPaginator<MergeRequestPipeline>(
      dio: _client,
      initialUri: _apiUri(
        'projects/$projectId/merge_requests/$mergeIid/pipelines',
        {'per_page': '100'},
      ),
      decode: MergeRequestPipeline.fromJson,
    );
    final pipelines = <MergeRequestPipeline>[];
    while (paginator.hasMore) {
      pipelines.addAll((await paginator.loadNext()).items);
    }
    return pipelines;
  }

  Future<MergeRequestApprovals> _loadApprovals(
    int projectId,
    int mergeIid,
  ) async {
    final response = await _client.getUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid/approvals'),
    );
    return MergeRequestApprovals.fromJson(response.data!);
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
