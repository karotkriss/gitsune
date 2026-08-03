import 'package:dio/dio.dart';

import '../../../core/network/keyset_paginator.dart';
import 'pipeline_models.dart';

/// Data seam consumed by the pipeline detail surface.
///
/// E14.1 adds the bounded offline cache for recently viewed pipelines. Until
/// then this stays lightweight and network-backed, like the E3.3 seam.
abstract interface class PipelinesRepository {
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId);

  /// Retries a failed job, returning the newly created retry job.
  Future<PipelineJob> retryJob(int projectId, int jobId);

  /// Cancels a running job, returning its updated state.
  Future<PipelineJob> cancelJob(int projectId, int jobId);

  /// Runs a manual job, returning its updated state.
  Future<PipelineJob> playJob(int projectId, int jobId);
}

class GitLabPipelinesRepository implements PipelinesRepository {
  GitLabPipelinesRepository(this._client);

  final Dio _client;

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) async {
    final results = await Future.wait<Object>([
      _loadPipeline(projectId, pipelineId),
      _loadJobs(projectId, pipelineId),
    ]);
    return PipelineDetails(
      pipeline: results[0] as Pipeline,
      jobs: results[1] as List<PipelineJob>,
    );
  }

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) =>
      _postJobAction(projectId, jobId, 'retry');

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) =>
      _postJobAction(projectId, jobId, 'cancel');

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) =>
      _postJobAction(projectId, jobId, 'play');

  Future<PipelineJob> _postJobAction(
    int projectId,
    int jobId,
    String action,
  ) async {
    final response = await _client.postUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/jobs/$jobId/$action'),
    );
    return PipelineJob.fromJson(response.data!);
  }

  Future<Pipeline> _loadPipeline(int projectId, int pipelineId) async {
    final response = await _client.getUri<Map<String, dynamic>>(
      _apiUri('projects/$projectId/pipelines/$pipelineId'),
    );
    return Pipeline.fromJson(response.data!);
  }

  Future<List<PipelineJob>> _loadJobs(int projectId, int pipelineId) async {
    final paginator = KeysetPaginator<PipelineJob>(
      dio: _client,
      initialUri: _apiUri('projects/$projectId/pipelines/$pipelineId/jobs', {
        'per_page': '100',
        'include_retried': 'true',
      }),
      decode: PipelineJob.fromJson,
    );
    final jobs = <PipelineJob>[];
    while (paginator.hasMore) {
      jobs.addAll((await paginator.loadNext()).items);
    }
    return jobs;
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
