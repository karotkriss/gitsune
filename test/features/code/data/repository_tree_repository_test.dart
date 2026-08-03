import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/code/data/repository_tree_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );
  const projectId = 7;

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  GitLabRepositoryTreeRepository repositoryFor(FakeGitLabServer server) {
    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('tok'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );
    return GitLabRepositoryTreeRepository(
      database: db,
      client: client,
      account: account,
    );
  }

  /// Serves the root tree as two keyset pages, mirroring GitLab's real
  /// behavior: a `Link: <...>; rel="next"` header on every page but the last.
  void registerTwoRootPages(FakeGitLabServer server) {
    server.handle('GET /api/v4/projects/$projectId/repository/tree', (
      request,
    ) async {
      expect(request.uri.queryParameters['pagination'], 'keyset');
      expect(request.uri.queryParameters['per_page'], '100');
      expect(request.uri.queryParameters.containsKey('path'), isFalse);
      expect(request.uri.queryParameters.containsKey('ref'), isFalse);
      final pageToken = request.uri.queryParameters['page_token'];
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      if (pageToken == null) {
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/$projectId/repository/tree'
          '?pagination=keyset&per_page=100&page_token=next',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('repository_tree_root_page1'));
      } else {
        expect(pageToken, 'next');
        request.response.write(Fixtures.raw('repository_tree_root_page2'));
      }
      await request.response.close();
    });
  }

  test('a refresh paginates the directory, writes through, and the stream '
      're-emits in server order', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerTwoRootPages(server);

    final repository = repositoryFor(server);
    final emissions = repository
        .watchDirectory(projectId)
        .map((entries) => entries.length);
    final expectation = expectLater(emissions, emitsInOrder([0, 10]));

    await repository.refreshDirectory(projectId);

    await expectation;

    final entries = await repository.watchDirectory(projectId).first;
    expect(entries.map((e) => e.name).take(4), [
      'android',
      'ios',
      'lib',
      'test',
    ]);
    expect(entries.first.entryType, 'tree');
    expect(entries.last.name, 'pubspec.yaml');
    expect(entries.last.entryType, 'blob');
    expect(entries.every((e) => e.parentPath.isEmpty), isTrue);
  });

  test(
    'a subdirectory refresh passes path and ref and caches under them',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      server.handle('GET /api/v4/projects/$projectId/repository/tree', (
        request,
      ) async {
        expect(request.uri.queryParameters['path'], 'lib');
        expect(request.uri.queryParameters['ref'], 'v1.0');
        request.response.headers.contentType = ContentType.json;
        request.response.write(Fixtures.raw('repository_tree_lib'));
        await request.response.close();
      });

      final repository = repositoryFor(server);
      await repository.refreshDirectory(projectId, ref: 'v1.0', path: 'lib');

      final entries = await repository
          .watchDirectory(projectId, ref: 'v1.0', path: 'lib')
          .first;
      expect(entries.map((e) => e.name), ['core', 'features', 'main.dart']);
      expect(entries.first.path, 'lib/core');

      final root = await repository
          .watchDirectory(projectId, ref: 'v1.0')
          .first;
      expect(root, isEmpty, reason: 'lib rows must not leak into the root');
    },
  );

  test('a subsequent refresh replaces entries no longer returned', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/$projectId/repository/tree',
      Fixtures.json('repository_tree_root_page1'),
    );

    await db
        .into(db.repositoryTreeEntries)
        .insert(
          RepositoryTreeEntriesCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            projectId: projectId,
            ref: '',
            parentPath: '',
            name: 'deleted_dir',
            path: 'deleted_dir',
            entryType: 'tree',
            position: 0,
          ),
        );

    final repository = repositoryFor(server);
    await repository.refreshDirectory(projectId);

    final entries = await repository.watchDirectory(projectId).first;
    expect(entries.map((e) => e.name), ['android', 'ios', 'lib', 'test']);
  });

  test('a network failure leaves cached data served (offline-first)', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/projects/$projectId/repository/tree', {
      'error': 'boom',
    }, statusCode: 500);

    await db
        .into(db.repositoryTreeEntries)
        .insert(
          RepositoryTreeEntriesCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            projectId: projectId,
            ref: '',
            parentPath: '',
            name: 'lib',
            path: 'lib',
            entryType: 'tree',
            position: 0,
          ),
        );

    final repository = repositoryFor(server);
    await repository.refreshDirectory(projectId);

    final entries = await repository.watchDirectory(projectId).first;
    expect(entries.single.name, 'lib');
  });

  test('the cache is account-scoped: another account sees nothing', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/$projectId/repository/tree',
      Fixtures.json('repository_tree_root_page1'),
    );

    final repository = repositoryFor(server);
    await repository.refreshDirectory(projectId);

    const otherAccount = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'bob',
    );
    final otherClient = createGitLabClient(
      account: otherAccount,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('tok'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );
    final otherRepository = GitLabRepositoryTreeRepository(
      database: db,
      client: otherClient,
      account: otherAccount,
    );

    expect(await repository.watchDirectory(projectId).first, hasLength(4));
    expect(await otherRepository.watchDirectory(projectId).first, isEmpty);
  });

  test(
    'concurrent refreshes of the same directory are de-duplicated',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      final releaseResponse = Completer<void>();
      var requestCount = 0;
      server.handle('GET /api/v4/projects/$projectId/repository/tree', (
        request,
      ) async {
        requestCount++;
        await releaseResponse.future;
        request.response.headers.contentType = ContentType.json;
        request.response.write(Fixtures.raw('repository_tree_root_page1'));
        await request.response.close();
      });

      final repository = repositoryFor(server);
      final firstRefresh = repository.refreshDirectory(projectId);
      final secondRefresh = repository.refreshDirectory(projectId);

      releaseResponse.complete();
      await Future.wait([firstRefresh, secondRefresh]);
      expect(requestCount, 1);
    },
  );

  test('the composite key covers account, project, ref, and directory', () {
    expect(db.repositoryTreeEntries.primaryKey, {
      db.repositoryTreeEntries.instanceHost,
      db.repositoryTreeEntries.accountId,
      db.repositoryTreeEntries.projectId,
      db.repositoryTreeEntries.ref,
      db.repositoryTreeEntries.parentPath,
      db.repositoryTreeEntries.name,
    });
  });
}
