import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/releases/data/releases_repository.dart';

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

  GitLabReleasesRepository repositoryFor(
    FakeGitLabServer server, {
    AccountKey forAccount = account,
  }) {
    final client = createGitLabClient(
      account: forAccount,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('tok'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );
    return GitLabReleasesRepository(
      database: db,
      client: client,
      account: forAccount,
    );
  }

  /// Serves the project's releases as two pages, mirroring GitLab's real
  /// behavior: a `Link: <...>; rel="next"` header on every page but the last.
  void registerTwoPages(FakeGitLabServer server) {
    server.handle('GET /api/v4/projects/$projectId/releases', (request) async {
      expect(request.uri.queryParameters['per_page'], '100');
      final page = request.uri.queryParameters['page'];
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      if (page == '1') {
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/$projectId/releases?page=2&per_page=100',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('releases_page1'));
      } else {
        expect(page, '2');
        request.response.write(Fixtures.raw('releases_page2'));
      }
      await request.response.close();
    });
  }

  ReleaseEntriesCompanion cachedRelease({
    AccountKey forAccount = account,
    String tagName = 'v0.9.0',
  }) => ReleaseEntriesCompanion.insert(
    instanceHost: forAccount.instanceHost,
    accountId: forAccount.accountId,
    projectId: projectId,
    tagName: tagName,
    name: 'Cached $tagName',
    description: 'cached notes',
    releasedAt: DateTime.utc(2025, 12, 24),
    assetsJson: '{}',
    position: 0,
  );

  test('a refresh paginates every page, writes through, and the stream '
      're-emits in server order', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerTwoPages(server);

    final repository = repositoryFor(server);
    final emissions = repository
        .watchReleases(projectId)
        .map((releases) => releases.length);
    final expectation = expectLater(emissions, emitsInOrder([0, 3]));

    await repository.refreshReleases(projectId);

    await expectation;

    final releases = await repository.watchReleases(projectId).first;
    expect(releases.map((r) => r.tagName), ['v1.2.0', 'v1.1.0', 'v1.0.0']);
    expect(releases.first.name, 'Version 1.2.0');
    expect(releases.first.description, contains('**twice as fast**'));
    expect(releases.first.authorName, 'Alice Doe');
    expect(releases.first.releasedAt.toUtc(), DateTime.utc(2026, 6, 2, 9, 30));
  });

  test('a null name falls back to the tag and a missing released_at falls '
      'back to created_at', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerTwoPages(server);

    final repository = repositoryFor(server);
    await repository.refreshReleases(projectId);

    final draft = await repository.watchRelease(projectId, 'v1.1.0').first;
    expect(draft!.name, 'v1.1.0');
    expect(draft.description, isEmpty);
    expect(draft.authorName, isNull);
    expect(draft.releasedAt.toUtc(), DateTime.utc(2026, 4, 15, 8));
  });

  test('the assets object round-trips into a flat link list, custom links '
      'first', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerTwoPages(server);

    final repository = repositoryFor(server);
    await repository.refreshReleases(projectId);

    final release = await repository.watchRelease(projectId, 'v1.2.0').first;
    final links = releaseAssetLinks(release!);
    expect(links.map((l) => l.name), [
      'Android APK',
      'Source code (zip)',
      'Source code (tar.gz)',
    ]);
    expect(links.first.url, endsWith('app-release.apk'));
  });

  test('a subsequent refresh replaces releases no longer returned', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/$projectId/releases',
      Fixtures.json('releases_page2'),
    );

    await db.into(db.releaseEntries).insert(cachedRelease());

    final repository = repositoryFor(server);
    await repository.refreshReleases(projectId);

    final releases = await repository.watchReleases(projectId).first;
    expect(releases.map((r) => r.tagName), ['v1.0.0']);
  });

  test('a network failure leaves cached data served (offline-first)', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/projects/$projectId/releases', {
      'error': 'boom',
    }, statusCode: 500);

    await db.into(db.releaseEntries).insert(cachedRelease());

    final repository = repositoryFor(server);
    await repository.refreshReleases(projectId);

    final releases = await repository.watchReleases(projectId).first;
    expect(releases.single.tagName, 'v0.9.0');
    expect(releases.single.description, 'cached notes');
  });

  test('the cache is account-scoped: another account sees nothing', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/$projectId/releases',
      Fixtures.json('releases_page1'),
    );

    final repository = repositoryFor(server);
    await repository.refreshReleases(projectId);

    const otherAccount = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'bob',
    );
    final otherRepository = repositoryFor(server, forAccount: otherAccount);

    expect(await repository.watchReleases(projectId).first, hasLength(2));
    expect(await otherRepository.watchReleases(projectId).first, isEmpty);
    expect(
      await otherRepository.watchRelease(projectId, 'v1.2.0').first,
      isNull,
    );
  });

  test('the composite key covers account, project, and tag', () {
    expect(db.releaseEntries.primaryKey, {
      db.releaseEntries.instanceHost,
      db.releaseEntries.accountId,
      db.releaseEntries.projectId,
      db.releaseEntries.tagName,
    });
  });
}
