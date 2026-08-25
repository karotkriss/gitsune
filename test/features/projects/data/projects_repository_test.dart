import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/projects/data/projects_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('lists membership projects by recent activity and follows '
      'pagination', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('GET /api/v4/projects', (request) async {
      final params = request.uri.queryParameters;
      expect(params['membership'], 'true');
      expect(params['order_by'], 'last_activity_at');
      expect(params['sort'], 'desc');
      expect(params['simple'], 'true');
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      if (params['page'] == null) {
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects?membership=true&order_by=last_activity_at'
          '&sort=desc&simple=true&page=2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('search_projects_page1'));
      } else {
        expect(params['page'], '2');
        request.response.write(Fixtures.raw('projects_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabProjectsRepository(_client(server, account));

    final first = await repository.loadFirstPage();
    expect(first.items.map((project) => project.name), ['app', 'offline-sync']);
    expect(first.hasMore, isTrue);

    final second = await repository.loadNextPage();
    expect(second.items.map((project) => project.name), ['relay-bridge']);
    expect(second.hasMore, isFalse);

    final drained = await repository.loadNextPage();
    expect(drained.items, isEmpty);
  });

  test('loading the next page before the first throws', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final repository = GitLabProjectsRepository(_client(server, account));

    expect(repository.loadNextPage, throwsStateError);
  });

  test('a failed refresh preserves the next-page cursor', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var firstPageRequests = 0;
    server.handle('GET /api/v4/projects', (request) async {
      final page = request.uri.queryParameters['page'];
      request.response.headers.contentType = ContentType.json;
      if (page == null) {
        firstPageRequests += 1;
        if (firstPageRequests == 2) {
          request.response.statusCode = HttpStatus.internalServerError;
          request.response.write('{}');
        } else {
          request.response.statusCode = HttpStatus.ok;
          final nextUri = server.baseUri.resolve('/api/v4/projects?page=2');
          request.response.headers.set('Link', '<$nextUri>; rel="next"');
          request.response.write(Fixtures.raw('search_projects_page1'));
        }
      } else {
        expect(page, '2');
        request.response.statusCode = HttpStatus.ok;
        request.response.write(Fixtures.raw('projects_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabProjectsRepository(_client(server, account));
    await repository.loadFirstPage();

    await expectLater(repository.loadFirstPage(), throwsA(isA<DioException>()));
    final next = await repository.loadNextPage();

    expect(next.items.map((project) => project.name), ['relay-bridge']);
    expect(firstPageRequests, 2);
  });

  test(
    'only the latest concurrent first-page load commits its cursor',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      final olderStarted = Completer<void>();
      final releaseOlder = Completer<void>();
      var firstPageRequests = 0;
      String? nextCursor;
      server.handle('GET /api/v4/projects', (request) async {
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
            '/api/v4/projects?cursor=${isOlder ? 'older' : 'latest'}',
          );
          request.response.headers.set('Link', '<$nextUri>; rel="next"');
          request.response.write(Fixtures.raw('search_projects_page1'));
        } else {
          nextCursor = cursor;
          request.response.write(Fixtures.raw('projects_page2'));
        }
        await request.response.close();
      });

      final repository = GitLabProjectsRepository(_client(server, account));
      final older = repository.loadFirstPage();
      await olderStarted.future;
      final latest = repository.loadFirstPage();
      await latest;
      releaseOlder.complete();
      await older;

      await repository.loadNextPage();

      expect(nextCursor, 'latest');
    },
  );
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => const TokenReadResult('fixture-token'),
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
