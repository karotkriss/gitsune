import 'package:dio/dio.dart';

import '../../../core/diff/diff_file.dart';
import '../../../core/network/keyset_paginator.dart';
import 'merge_request_models.dart';

class MergeRequestPage {
  const MergeRequestPage({required this.items, required this.hasMore});

  final List<MergeRequest> items;
  final bool hasMore;
}

class MergeRequestPipelinePage {
  const MergeRequestPipelinePage({required this.items, required this.hasMore});

  final List<MergeRequestPipeline> items;
  final bool hasMore;
}

/// Read seam consumed by the merge request list and detail shell.
///
/// This E7.1 implementation is intentionally network-backed. E14.1 adds the
/// bounded offline cache for recently viewed merge requests.
abstract interface class MergeRequestsRepository {
  Future<MergeRequestPage> loadFirstPage(int projectId);

  Future<MergeRequestPage> loadNextPage(int projectId);

  Future<MergeRequest> loadMergeRequest(int projectId, int mergeIid);

  Future<MergeRequestPipelinePage> loadFirstPipelinePage(
    int projectId,
    int mergeIid,
  );

  Future<MergeRequestPipelinePage> loadNextPipelinePage(
    int projectId,
    int mergeIid,
  );

  Future<MergeRequestApprovals> loadApprovals(int projectId, int mergeIid);

  /// Loads the merge request's full multi-file diff, following every
  /// pagination link, in the order GitLab returns the files.
  Future<List<DiffFile>> loadDiffs(int projectId, int mergeIid);
}

/// GitLab REST v4 merge request reader with Link-header pagination.
class GitLabMergeRequestsRepository implements MergeRequestsRepository {
  GitLabMergeRequestsRepository(this._client);

  final Dio _client;
  final _paginators = <int, KeysetPaginator<MergeRequest>>{};
  final _pageLoads = <int, Future<MergeRequestPage>>{};
  final _pipelinePaginators =
      <(int, int), KeysetPaginator<MergeRequestPipeline>>{};
  final _pipelinePageLoads = <(int, int), Future<MergeRequestPipelinePage>>{};

  @override
  Future<MergeRequestPage> loadFirstPage(int projectId) {
    final paginator = KeysetPaginator<MergeRequest>(
      dio: _client,
      initialUri: _apiUri('projects/$projectId/merge_requests', {
        'scope': 'all',
        'state': 'all',
        'order_by': 'updated_at',
        'sort': 'desc',
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
  Future<MergeRequest> loadMergeRequest(int projectId, int mergeIid) async {
    final response = await _client.getUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid'),
    );
    return MergeRequest.fromJson(response.data!);
  }

  @override
  Future<MergeRequestPipelinePage> loadFirstPipelinePage(
    int projectId,
    int mergeIid,
  ) {
    final key = (projectId, mergeIid);
    final paginator = KeysetPaginator<MergeRequestPipeline>(
      dio: _client,
      initialUri: _apiUri(
        'projects/$projectId/merge_requests/$mergeIid/pipelines',
        {'per_page': '20'},
      ),
      decode: MergeRequestPipeline.fromJson,
    );
    _pipelinePaginators[key] = paginator;
    return _loadPipelinePage(key, paginator);
  }

  @override
  Future<MergeRequestPipelinePage> loadNextPipelinePage(
    int projectId,
    int mergeIid,
  ) {
    final key = (projectId, mergeIid);
    final existing = _pipelinePageLoads[key];
    if (existing != null) return existing;

    final paginator = _pipelinePaginators[key];
    if (paginator == null) {
      throw StateError('Load the first pipeline page before loading the next.');
    }
    if (!paginator.hasMore) {
      return Future.value(
        const MergeRequestPipelinePage(items: [], hasMore: false),
      );
    }
    return _loadPipelinePage(key, paginator);
  }

  Future<MergeRequestPipelinePage> _loadPipelinePage(
    (int, int) key,
    KeysetPaginator<MergeRequestPipeline> paginator,
  ) {
    final future = paginator.loadNext().then(
      (page) =>
          MergeRequestPipelinePage(items: page.items, hasMore: page.hasMore),
    );
    _pipelinePageLoads[key] = future;
    return future.whenComplete(() {
      if (identical(_pipelinePageLoads[key], future)) {
        _pipelinePageLoads.remove(key);
      }
    });
  }

  @override
  Future<MergeRequestApprovals> loadApprovals(
    int projectId,
    int mergeIid,
  ) async {
    final response = await _client.getUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid/approvals'),
    );
    return MergeRequestApprovals.fromJson(response.data!);
  }

  @override
  Future<List<DiffFile>> loadDiffs(int projectId, int mergeIid) async {
    final paginator = KeysetPaginator<DiffFile>(
      dio: _client,
      initialUri: _apiUri(
        'projects/$projectId/merge_requests/$mergeIid/diffs',
        {'per_page': '50'},
      ),
      decode: DiffFile.fromJson,
    );
    final files = <DiffFile>[];
    while (paginator.hasMore) {
      final page = await paginator.loadNext();
      files.addAll(page.items);
    }
    return files;
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
