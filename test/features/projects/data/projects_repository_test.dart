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
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => const TokenReadResult('fixture-token'),
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
