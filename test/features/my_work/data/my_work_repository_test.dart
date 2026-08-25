import 'dart:async';
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

  test('a failed issue refresh preserves the next-page cursor', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var firstPageRequests = 0;
    server.handle('GET /api/v4/issues', (request) async {
      final page = request.uri.queryParameters['page'];
      request.response.headers.contentType = ContentType.json;
      if (page == null) {
        firstPageRequests += 1;
        if (firstPageRequests == 2) {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write('{}');
        } else {
          request.response.statusCode = HttpStatus.ok;
          final nextUri = server.baseUri.resolve('/api/v4/issues?page=2');
          request.response.headers.set('Link', '<$nextUri>; rel="next"');
          request.response.write(Fixtures.raw('issues_page1'));
        }
      } else {
        expect(page, '2');
        request.response.statusCode = HttpStatus.ok;
        request.response.write(Fixtures.raw('issues_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabMyWorkRepository(_client(server, account));
    await repository.loadFirstIssuesPage(MyWorkScope.assigned);

    await expectLater(
      repository.loadFirstIssuesPage(MyWorkScope.assigned),
      throwsA(isA<DioException>()),
    );
    final next = await repository.loadNextIssuesPage(MyWorkScope.assigned);

    expect(next.items.map((issue) => issue.iid), [140]);
    expect(firstPageRequests, 2);
  });

  test(
    'a failed merge request refresh preserves the next-page cursor',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      var firstPageRequests = 0;
      server.handle('GET /api/v4/merge_requests', (request) async {
        final page = request.uri.queryParameters['page'];
        request.response.headers.contentType = ContentType.json;
        if (page == null) {
          firstPageRequests += 1;
          if (firstPageRequests == 2) {
            request.response.statusCode = HttpStatus.internalServerError;
            request.response.write('{}');
          } else {
            request.response.statusCode = HttpStatus.ok;
            final nextUri = server.baseUri.resolve(
              '/api/v4/merge_requests?page=2',
            );
            request.response.headers.set('Link', '<$nextUri>; rel="next"');
            request.response.write(Fixtures.raw('merge_requests_page1'));
          }
        } else {
          expect(page, '2');
          request.response.statusCode = HttpStatus.ok;
          request.response.write('[]');
        }
        await request.response.close();
      });

      final repository = GitLabMyWorkRepository(_client(server, account));
      await repository.loadFirstMergeRequestsPage(MyWorkScope.assigned);

      await expectLater(
        repository.loadFirstMergeRequestsPage(MyWorkScope.assigned),
        throwsA(isA<DioException>()),
      );
      final next = await repository.loadNextMergeRequestsPage(
        MyWorkScope.assigned,
      );

      expect(next.items, isEmpty);
      expect(firstPageRequests, 2);
    },
  );

  test('only the latest concurrent issue load commits its cursor', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final olderStarted = Completer<void>();
    final releaseOlder = Completer<void>();
    var firstPageRequests = 0;
    String? nextCursor;
    server.handle('GET /api/v4/issues', (request) async {
      final cursor = request.uri.queryParameters['cursor'];
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (cursor == null) {
        firstPageRequests += 1;
        final isOlder = firstPageRequests == 1;
        if (isOlder) {
          olderStarted.complete();
          await releaseOlder.future;
        }
        final nextUri = server.baseUri.resolve(
          '/api/v4/issues?cursor=${isOlder ? 'older' : 'latest'}',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('issues_page1'));
      } else {
        nextCursor = cursor;
        request.response.write(Fixtures.raw('issues_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabMyWorkRepository(_client(server, account));
    final older = repository.loadFirstIssuesPage(MyWorkScope.assigned);
    await olderStarted.future;
    final latest = repository.loadFirstIssuesPage(MyWorkScope.assigned);
    await latest;
    releaseOlder.complete();
    await older;

    await repository.loadNextIssuesPage(MyWorkScope.assigned);

    expect(nextCursor, 'latest');
  });

  test(
    'only the latest concurrent merge request load commits its cursor',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      final olderStarted = Completer<void>();
      final releaseOlder = Completer<void>();
      var firstPageRequests = 0;
      String? nextCursor;
      server.handle('GET /api/v4/merge_requests', (request) async {
        final cursor = request.uri.queryParameters['cursor'];
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        if (cursor == null) {
          firstPageRequests += 1;
          final isOlder = firstPageRequests == 1;
          if (isOlder) {
            olderStarted.complete();
            await releaseOlder.future;
          }
          final nextUri = server.baseUri.resolve(
            '/api/v4/merge_requests?cursor=${isOlder ? 'older' : 'latest'}',
          );
          request.response.headers.set('Link', '<$nextUri>; rel="next"');
          request.response.write(Fixtures.raw('merge_requests_page1'));
        } else {
          nextCursor = cursor;
          request.response.write('[]');
        }
        await request.response.close();
      });

      final repository = GitLabMyWorkRepository(_client(server, account));
      final older = repository.loadFirstMergeRequestsPage(MyWorkScope.assigned);
      await olderStarted.future;
      final latest = repository.loadFirstMergeRequestsPage(
        MyWorkScope.assigned,
      );
      await latest;
      releaseOlder.complete();
      await older;

      await repository.loadNextMergeRequestsPage(MyWorkScope.assigned);

      expect(nextCursor, 'latest');
    },
  );

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
