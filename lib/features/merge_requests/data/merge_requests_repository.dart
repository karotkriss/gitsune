import 'package:dio/dio.dart';

import '../../../core/diff/diff_file.dart';
import '../../../core/network/keyset_paginator.dart';
import 'merge_request_discussion_models.dart';
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
/// This repository remains network-backed. The merge request detail screen
/// composes it with the E14.1 recently-viewed cache for offline reads.
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

  /// Approves the merge request, returning the updated approval state as the
  /// server shaped it.
  Future<MergeRequestApprovals> approve(int projectId, int mergeIid);

  /// Revokes the current user's approval, returning the updated approval
  /// state as the server shaped it.
  Future<MergeRequestApprovals> unapprove(int projectId, int mergeIid);

  /// Merges the merge request, returning it as the server shaped it after
  /// the merge.
  Future<MergeRequest> merge(int projectId, int mergeIid);

  /// Loads the merge request's full multi-file diff, following every
  /// pagination link, in the order GitLab returns the files.
  Future<List<DiffFile>> loadDiffs(int projectId, int mergeIid);

  /// Loads every discussion on the merge request, following every
  /// pagination link.
  Future<List<Discussion>> loadDiscussions(int projectId, int mergeIid);

  /// Starts a new thread on a diff line, returning the created discussion
  /// as the server shaped it.
  Future<Discussion> createDiffDiscussion(
    int projectId,
    int mergeIid, {
    required String body,
    required DiffPosition position,
  });

  /// Resolves or unresolves a thread, returning the updated discussion as
  /// the server shaped it.
  Future<Discussion> setDiscussionResolved(
    int projectId,
    int mergeIid,
    String discussionId, {
    required bool resolved,
  });
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
  Future<MergeRequestApprovals> approve(int projectId, int mergeIid) async {
    final response = await _client.postUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid/approve'),
    );
    return MergeRequestApprovals.fromJson(response.data!);
  }

  @override
  Future<MergeRequestApprovals> unapprove(int projectId, int mergeIid) async {
    final response = await _client.postUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid/unapprove'),
    );
    return MergeRequestApprovals.fromJson(response.data!);
  }

  @override
  Future<MergeRequest> merge(int projectId, int mergeIid) async {
    final response = await _client.putUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid/merge'),
    );
    return MergeRequest.fromJson(response.data!);
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

  @override
  Future<List<Discussion>> loadDiscussions(int projectId, int mergeIid) async {
    final paginator = KeysetPaginator<Discussion>(
      dio: _client,
      initialUri: _apiUri(
        'projects/$projectId/merge_requests/$mergeIid/discussions',
        {'per_page': '50'},
      ),
      decode: Discussion.fromJson,
    );
    final discussions = <Discussion>[];
    while (paginator.hasMore) {
      final page = await paginator.loadNext();
      discussions.addAll(page.items);
    }
    return discussions;
  }

  @override
  Future<Discussion> createDiffDiscussion(
    int projectId,
    int mergeIid, {
    required String body,
    required DiffPosition position,
  }) async {
    final response = await _client.postUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/merge_requests/$mergeIid/discussions'),
      data: {'body': body, 'position': position.toJson()},
    );
    return Discussion.fromJson(response.data!);
  }

  @override
  Future<Discussion> setDiscussionResolved(
    int projectId,
    int mergeIid,
    String discussionId, {
    required bool resolved,
  }) async {
    final response = await _client.putUri<Map<String, dynamic>>(
      _apiUri(
        'projects/$projectId/merge_requests/$mergeIid/discussions/'
        '$discussionId',
        {'resolved': '$resolved'},
      ),
    );
    return Discussion.fromJson(response.data!);
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
