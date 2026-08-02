import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
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
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (request.uri.queryParameters['page'] == null) {
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/pipelines/88123/jobs?per_page=100&page=2',
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
    expect(jobPageRequests, 2);
    expect(details.jobs.map((job) => job.status), contains(CiStatus.failed));
    expect(details.jobs.map((job) => job.status), contains(CiStatus.manual));
    expect(details.jobs.map((job) => job.status), contains(CiStatus.scheduled));
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => 'fixture-token',
  refreshToken: (_) async => fail('refresh should not be called'),
);
