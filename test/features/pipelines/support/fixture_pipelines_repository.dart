import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/data/pipelines_repository.dart';

import '../../../support/fixtures.dart';

class FixturePipelinesRepository implements PipelinesRepository {
  int loads = 0;
  final retriedJobIds = <int>[];
  final canceledJobIds = <int>[];
  final playedJobIds = <int>[];

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) async {
    loads++;
    final pipeline = Pipeline.fromJson(
      Map<String, dynamic>.from(Fixtures.json('pipeline_88123') as Map),
    );
    final jobs = (Fixtures.json('pipeline_88123_jobs') as List<dynamic>)
        .map(
          (job) => PipelineJob.fromJson(Map<String, dynamic>.from(job as Map)),
        )
        .toList(growable: false);
    return PipelineDetails(pipeline: pipeline, jobs: jobs);
  }

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) async {
    retriedJobIds.add(jobId);
    // A retry creates a brand new job attempt with a fresh id.
    return _updatedJob(jobId, CiStatus.running, newId: jobId + 10000);
  }

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) async {
    canceledJobIds.add(jobId);
    return _updatedJob(jobId, CiStatus.canceled);
  }

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) async {
    playedJobIds.add(jobId);
    return _updatedJob(jobId, CiStatus.running);
  }

  PipelineJob _updatedJob(int jobId, CiStatus status, {int? newId}) {
    final original = (Fixtures.json('pipeline_88123_jobs') as List<dynamic>)
        .map(
          (job) => PipelineJob.fromJson(Map<String, dynamic>.from(job as Map)),
        )
        .firstWhere((job) => job.id == jobId);
    return PipelineJob(
      id: newId ?? original.id,
      name: original.name,
      stage: original.stage,
      status: status,
      allowFailure: original.allowFailure,
    );
  }
}
