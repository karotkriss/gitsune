import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/data/pipelines_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('loads pipeline detail and all jobs against the fake server', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/7/pipelines/88123',
      Fixtures.json('pipeline_88123'),
    );
    final fixtureJobs = Fixtures.json('pipeline_88123_jobs') as List<dynamic>;
    var jobPageRequests = 0;
    server.handle('GET /api/v4/projects/7/pipelines/88123/jobs', (
      request,
    ) async {
      jobPageRequests++;
      expect(request.uri.queryParameters, containsPair('per_page', '100'));
      expect(
        request.uri.queryParameters,
        containsPair('include_retried', 'true'),
      );
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (request.uri.queryParameters['page'] == null) {
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/pipelines/88123/jobs'
          '?per_page=100&include_retried=true&page=2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(jsonEncode(fixtureJobs.take(4).toList()));
      } else {
        expect(request.uri.queryParameters, containsPair('page', '2'));
        request.response.write(jsonEncode(fixtureJobs.skip(4).toList()));
      }
      await request.response.close();
    });

    final repository = GitLabPipelinesRepository(_client(server, account));
    final details = await repository.loadPipeline(7, 88123);

    expect(details.pipeline.id, 88123);
    expect(details.pipeline.status, CiStatus.running);
    expect(details.pipeline.shortSha, 'a73f91c2');
    expect(details.jobs, hasLength(8));
    expect(details.jobs.first.stage, 'build');
    expect(details.jobs.first.id, 509);
    expect(
      details.jobs.where((job) => job.name == 'build:android'),
      hasLength(1),
    );
    expect(jobPageRequests, 2);
    expect(details.jobs.map((job) => job.status), contains(CiStatus.failed));
    expect(details.jobs.map((job) => job.status), contains(CiStatus.manual));
    expect(details.jobs.map((job) => job.status), contains(CiStatus.scheduled));
  });

  test('retries a job against the fake server', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('POST /api/v4/projects/7/jobs/503/retry', {
      'id': 9503,
      'name': 'test:integration',
      'stage': 'test',
      'status': 'pending',
      'allow_failure': false,
    });

    final repository = GitLabPipelinesRepository(_client(server, account));
    final job = await repository.retryJob(7, 503);

    expect(job.id, 9503);
    expect(job.name, 'test:integration');
    expect(job.status, CiStatus.pending);
  });

  test('cancels a job against the fake server', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('POST /api/v4/projects/7/jobs/502/cancel', {
      'id': 502,
      'name': 'test:flutter',
      'stage': 'test',
      'status': 'canceled',
      'allow_failure': false,
    });

    final repository = GitLabPipelinesRepository(_client(server, account));
    final job = await repository.cancelJob(7, 502);

    expect(job.id, 502);
    expect(job.status, CiStatus.canceled);
  });

  test('runs a manual job against the fake server', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('POST /api/v4/projects/7/jobs/506/play', {
      'id': 506,
      'name': 'deploy:review',
      'stage': 'deploy',
      'status': 'running',
      'allow_failure': true,
    });

    final repository = GitLabPipelinesRepository(_client(server, account));
    final job = await repository.playJob(7, 506);

    expect(job.id, 506);
    expect(job.status, CiStatus.running);
  });

  test(
    'withUpdatedJob replaces a same-id job and supersedes a retried one',
    () async {
      final pipeline = Pipeline.fromJson(
        Map<String, dynamic>.from(Fixtures.json('pipeline_88123') as Map),
      );
      final jobs = (Fixtures.json('pipeline_88123_jobs') as List<dynamic>)
          .map(
            (job) =>
                PipelineJob.fromJson(Map<String, dynamic>.from(job as Map)),
          )
          .toList();
      final details = PipelineDetails(pipeline: pipeline, jobs: jobs);

      final canceled = details.withUpdatedJob(
        const PipelineJob(
          id: 502,
          name: 'test:flutter',
          stage: 'test',
          status: CiStatus.canceled,
          allowFailure: false,
        ),
      );
      expect(
        canceled.jobs.firstWhere((job) => job.name == 'test:flutter').status,
        CiStatus.canceled,
      );

      final retried = canceled.withUpdatedJob(
        const PipelineJob(
          id: 9503,
          name: 'test:integration',
          stage: 'test',
          status: CiStatus.running,
          allowFailure: false,
        ),
      );
      final integrationJobs = retried.jobs.where(
        (job) => job.name == 'test:integration',
      );
      expect(integrationJobs, hasLength(1));
      expect(integrationJobs.single.id, 9503);
      expect(integrationJobs.single.status, CiStatus.running);
    },
  );

  test('repeated retries preserve original job and stage order', () {
    final pipeline = Pipeline.fromJson(
      Map<String, dynamic>.from(Fixtures.json('pipeline_88123') as Map),
    );
    const firstAttempt = PipelineJob(
      id: 1,
      name: 'test:first',
      stage: 'test',
      status: CiStatus.failed,
      allowFailure: false,
    );
    const deploy = PipelineJob(
      id: 2,
      name: 'deploy',
      stage: 'deploy',
      status: CiStatus.success,
      allowFailure: false,
    );
    const secondTestJob = PipelineJob(
      id: 3,
      name: 'test:second',
      stage: 'test',
      status: CiStatus.success,
      allowFailure: false,
    );
    const previousRetry = PipelineJob(
      id: 101,
      name: 'test:first',
      stage: 'test',
      status: CiStatus.failed,
      allowFailure: false,
    );
    final details = PipelineDetails(
      pipeline: pipeline,
      jobs: const [firstAttempt, deploy, secondTestJob, previousRetry],
    );

    final retried = details.withUpdatedJob(
      const PipelineJob(
        id: 201,
        name: 'test:first',
        stage: 'test',
        status: CiStatus.running,
        allowFailure: false,
      ),
    );

    expect(retried.jobs.map((job) => job.name), [
      'test:first',
      'test:second',
      'deploy',
    ]);
    expect(retried.jobs.first.id, 201);
  });

  test('derives warning badges without losing raw execution status', () {
    final pipelineJson =
        Map<String, dynamic>.from(Fixtures.json('pipeline_88123') as Map)
          ..['status'] = 'success'
          ..['detailed_status'] = {'icon': 'status_warning'};
    final jobJson =
        Map<String, dynamic>.from(
            (Fixtures.json('pipeline_88123_jobs') as List<dynamic>).first
                as Map,
          )
          ..['status'] = 'failed'
          ..['allow_failure'] = true;

    expect(Pipeline.fromJson(pipelineJson).status, CiStatus.warning);
    final job = PipelineJob.fromJson(jobJson);
    expect(job.status, CiStatus.failed);
    expect(job.badgeStatus, CiStatus.warning);
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => 'fixture-token',
  refreshToken: (_) async => fail('refresh should not be called'),
);
