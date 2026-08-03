import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/data/pipelines_repository.dart';

import '../../../support/fixtures.dart';

class FixturePipelinesRepository implements PipelinesRepository {
  int loads = 0;

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
}
