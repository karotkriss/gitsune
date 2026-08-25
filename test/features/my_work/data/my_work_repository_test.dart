import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/my_work/data/my_work_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('loads the assigned issues queue and follows pagination', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('GET /api/v4/issues', (request) async {
      final params = request.uri.queryParameters;
      expect(params['scope'], 'assigned_to_me');
      expect(params['state'], 'opened');
      expect(params['order_by'], 'updated_at');
      expect(params['with_labels_details'], 'true');
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (params['page'] == null) {
        final nextUri = server.baseUri.resolve(
          '/api/v4/issues?scope=assigned_to_me&state=opened'
          '&order_by=updated_at&with_labels_details=true&page=2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('issues_page1'));
      } else {
        expect(params['page'], '2');
        request.response.write(Fixtures.raw('issues_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabMyWorkRepository(_client(server, account));

    final first = await repository.loadFirstIssuesPage(MyWorkScope.assigned);
    expect(first.items.map((issue) => issue.iid), [142, 141]);
    expect(first.hasMore, isTrue);

    final second = await repository.loadNextIssuesPage(MyWorkScope.assigned);
    expect(second.items.map((issue) => issue.iid), [140]);
    expect(second.hasMore, isFalse);

    final drained = await repository.loadNextIssuesPage(MyWorkScope.assigned);
    expect(drained.items, isEmpty);
  });

  test('the authored scope maps to created_by_me', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final scopes = <String?>[];
    server.handle('GET /api/v4/issues', (request) async {
      scopes.add(request.uri.queryParameters['scope']);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response.write('[]');
      await request.response.close();
    });

    final repository = GitLabMyWorkRepository(_client(server, account));
    await repository.loadFirstIssuesPage(MyWorkScope.authored);

    expect(scopes, ['created_by_me']);
  });

  test('loads the open merge request queue per scope', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('GET /api/v4/merge_requests', (request) async {
      final params = request.uri.queryParameters;
      expect(params['scope'], 'assigned_to_me');
      expect(params['state'], 'opened');
      expect(params['order_by'], 'updated_at');
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('merge_requests_page1'));
      await request.response.close();
    });

    final repository = GitLabMyWorkRepository(_client(server, account));

    final page = await repository.loadFirstMergeRequestsPage(
      MyWorkScope.assigned,
    );
    expect(page.items.map((mergeRequest) => mergeRequest.iid), [142, 141]);
    expect(page.hasMore, isFalse);

    final drained = await repository.loadNextMergeRequestsPage(
      MyWorkScope.assigned,
    );
    expect(drained.items, isEmpty);
    expect(drained.hasMore, isFalse);
  });

  test('loading the next page before the first throws', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final repository = GitLabMyWorkRepository(_client(server, account));

    expect(
      () => repository.loadNextIssuesPage(MyWorkScope.assigned),
      throwsStateError,
    );
    expect(
      () => repository.loadNextMergeRequestsPage(MyWorkScope.assigned),
      throwsStateError,
    );
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => const TokenReadResult('fixture-token'),
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
