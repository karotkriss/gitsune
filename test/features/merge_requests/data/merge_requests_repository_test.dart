import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('loads project merge requests through Link-header pagination', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var requestCount = 0;
    server.handle('GET /api/v4/projects/7/merge_requests', (request) async {
      requestCount++;
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      final cursor = request.uri.queryParameters['cursor'];
      if (cursor == null) {
        expect(request.uri.queryParameters, containsPair('scope', 'all'));
        expect(request.uri.queryParameters, containsPair('state', 'all'));
        expect(request.uri.queryParameters, isNot(contains('pagination')));
        expect(
          request.uri.queryParameters,
          containsPair('order_by', 'updated_at'),
        );
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/merge_requests?cursor=page2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('merge_requests_page1'));
      } else {
        expect(cursor, 'page2');
        request.response.write(Fixtures.raw('merge_requests_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabMergeRequestsRepository(_client(server, account));
    final first = await repository.loadFirstPage(7);
    final second = await repository.loadNextPage(7);

    expect(first.items.map((mergeRequest) => mergeRequest.iid), [142, 141]);
    expect(first.items.first.sourceBranch, 'feat/instance-switcher');
    expect(first.items.first.targetBranch, 'main');
    expect(first.hasMore, isTrue);
    expect(second.items.map((mergeRequest) => mergeRequest.iid), [140, 139]);
    expect(second.items.first.state, MergeRequestState.closed);
    expect(second.items.last.draft, isTrue);
    expect(second.hasMore, isFalse);
    expect(requestCount, 2);

    final exhausted = await repository.loadNextPage(7);
    expect(exhausted.items, isEmpty);
    expect(requestCount, 2);
  });

  test('loads detail, one pipeline page, and approval counts', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/7/merge_requests/142',
      Fixtures.json('merge_request_142'),
    );
    server.respondJson(
      'GET /api/v4/projects/7/merge_requests/142/approvals',
      Fixtures.json('merge_request_142_approvals'),
    );
    var pipelineRequestCount = 0;
    server.handle('GET /api/v4/projects/7/merge_requests/142/pipelines', (
      request,
    ) async {
      pipelineRequestCount++;
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      final page = request.uri.queryParameters['page'];
      if (page == null) {
        expect(request.uri.queryParameters, containsPair('per_page', '20'));
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/merge_requests/142/pipelines?page=2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(
          Fixtures.raw('merge_request_142_pipelines_page1'),
        );
      } else {
        expect(page, '2');
        request.response.write(
          Fixtures.raw('merge_request_142_pipelines_page2'),
        );
      }
      await request.response.close();
    });

    final repository = GitLabMergeRequestsRepository(_client(server, account));
    final mergeRequest = await repository.loadMergeRequest(7, 142);
    final firstPipelines = await repository.loadFirstPipelinePage(7, 142);
    final approvals = await repository.loadApprovals(7, 142);

    expect(mergeRequest.title, 'Add instance switcher sheet');
    expect(mergeRequest.changedFilesLabel, '4 files changed');
    expect(mergeRequest.labels, ['workflow::in review', 'mobile']);
    expect(firstPipelines.items.map((pipeline) => pipeline.id), [88123, 88119]);
    expect(firstPipelines.items.first.status, CiStatus.running);
    expect(firstPipelines.hasMore, isTrue);
    expect(pipelineRequestCount, 1);
    expect(approvals.approvalsRequired, 2);
    expect(approvals.approvalsLeft, 1);
    expect(approvals.approvedCount, 1);
    expect(approvals.approvedBy.single.username, 'priya');

    final secondPipelines = await repository.loadNextPipelinePage(7, 142);
    expect(secondPipelines.items.single.id, 88101);
    expect(secondPipelines.hasMore, isFalse);
    expect(pipelineRequestCount, 2);
  });

  test('loads the full diff by following every pagination link', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var requestCount = 0;
    server.handle('GET /api/v4/projects/7/merge_requests/142/diffs', (
      request,
    ) async {
      requestCount++;
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (request.uri.queryParameters['cursor'] == null) {
        expect(request.uri.queryParameters, containsPair('per_page', '50'));
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/merge_requests/142/diffs?cursor=page2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('merge_request_142_diffs_page1'));
      } else {
        request.response.write(Fixtures.raw('merge_request_142_diffs_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabMergeRequestsRepository(_client(server, account));
    final files = await repository.loadDiffs(7, 142);

    expect(requestCount, 2);
    expect(files.map((file) => file.newPath), [
      'lib/src/instance_switcher.dart',
      'README.md',
      'lib/src/switcher_state.dart',
      'lib/src/legacy_switcher.dart',
    ]);
    expect(files.first.hunks, hasLength(2));
    expect(files.last.deletedFile, isTrue);
  });

  test('accepts the documented basic pipeline shape', () {
    final pipeline = MergeRequestPipeline.fromJson({
      'id': 88123,
      'status': 'running',
      'ref': 'refs/merge-requests/142/head',
      'sha': '731af8923c51e65101fc3cbb3275ce0a3e849311',
    });

    expect(pipeline.updatedAt, isNull);
  });

  test('normalizes a pending changes count', () {
    final json = Map<String, dynamic>.from(
      Fixtures.json('merge_request_142') as Map,
    )..['changes_count'] = '';

    expect(MergeRequest.fromJson(json).changedFilesLabel, 'Changed files');
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => const TokenReadResult('fixture-token'),
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
