import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/search/data/search_models.dart';
import 'package:gitsune/features/search/data/search_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('searches across projects, issues, and merge requests', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('GET /api/v4/search', (request) async {
      final params = request.uri.queryParameters;
      expect(params['search'], 'offline');
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      switch (params['scope']) {
        case 'projects':
          request.response.write(Fixtures.raw('search_projects_page1'));
        case 'issues':
          final cursor = params['cursor'];
          if (cursor == null) {
            final nextUri = server.baseUri.resolve(
              '/api/v4/search?scope=issues&search=offline&cursor=page2',
            );
            request.response.headers.set('Link', '<$nextUri>; rel="next"');
            request.response.write(Fixtures.raw('issues_page1'));
          } else {
            expect(cursor, 'page2');
            request.response.write(Fixtures.raw('issues_page2'));
          }
        case 'merge_requests':
          request.response.write(Fixtures.raw('search_merge_requests_page1'));
        case 'blobs':
          request.response.write(Fixtures.raw('search_blobs_page1'));
        default:
          fail('Unexpected search scope: ${params['scope']}');
      }
      await request.response.close();
    });

    final repository = GitLabSearchRepository(_client(server, account));

    final projects = await repository.loadFirstProjectsPage('offline');
    expect(projects.items.map((project) => project.name), [
      'app',
      'offline-sync',
    ]);
    expect(projects.items.first.starCount, 12);
    expect(projects.hasMore, isFalse);

    final firstIssues = await repository.loadFirstIssuesPage('offline');
    expect(firstIssues.items.map((issue) => issue.iid), [142, 141]);
    expect(firstIssues.hasMore, isTrue);
    final nextIssues = await repository.loadNextIssuesPage('offline');
    expect(nextIssues.items.single.iid, 140);
    expect(nextIssues.hasMore, isFalse);

    final mergeRequests = await repository.loadFirstMergeRequestsPage(
      'offline',
    );
    expect(mergeRequests.items.map((mr) => mr.iid), [88, 81]);
    expect(mergeRequests.items.first.state, SearchMergeRequestState.opened);
    expect(mergeRequests.items.last.state, SearchMergeRequestState.merged);
    expect(mergeRequests.hasMore, isFalse);

    final blobs = await repository.loadFirstBlobsPage('offline');
    expect(blobs.items.map((blob) => blob.path), [
      'lib/core/repository/offline_first_repository.dart',
      'docs/plan/roadmap.md',
    ]);
    expect(
      blobs.items.first.data,
      contains('abstract class OfflineFirstRepository<T> {'),
    );
    expect(blobs.items.first.startline, 14);
    expect(blobs.hasMore, isFalse);
  });

  test(
    'an instance without Advanced Search reports code search unsupported',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      server.respondJson('GET /api/v4/search', {
        'error': 'Scope not supported without Elasticsearch!',
      }, statusCode: 400);

      final repository = GitLabSearchRepository(_client(server, account));

      await expectLater(
        repository.loadFirstBlobsPage('offline'),
        throwsA(isA<CodeSearchUnsupportedException>()),
      );
    },
  );

  test(
    'a rate-limit failure on code search is not mistaken for a tier limit',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      server.respondJson('GET /api/v4/search', {
        'message': 'Too many requests',
      }, statusCode: 429);

      final repository = GitLabSearchRepository(_client(server, account));

      await expectLater(
        repository.loadFirstBlobsPage('offline'),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'statusCode',
            429,
          ),
        ),
      );
    },
  );

  test('builds the instance web code-search URL from the API base', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    final repository = GitLabSearchRepository(_client(server, account));

    final url = repository.codeSearchWebUrl('offline first');
    expect(url.origin, server.baseUri.origin);
    expect(url.path, '/search');
    expect(url.queryParameters, {'search': 'offline first', 'scope': 'blobs'});
  });

  test('an empty term returns empty pages for every scope', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/search', <dynamic>[]);

    final repository = GitLabSearchRepository(_client(server, account));

    final projects = await repository.loadFirstProjectsPage('doesnotexist');
    final issues = await repository.loadFirstIssuesPage('doesnotexist');
    final mergeRequests = await repository.loadFirstMergeRequestsPage(
      'doesnotexist',
    );

    expect(projects.items, isEmpty);
    expect(projects.hasMore, isFalse);
    expect(issues.items, isEmpty);
    expect(issues.hasMore, isFalse);
    expect(mergeRequests.items, isEmpty);
    expect(mergeRequests.hasMore, isFalse);
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => const TokenReadResult('fixture-token'),
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
