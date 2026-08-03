import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/repository/recently_viewed_repository.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';
import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/data/pipelines_repository.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

  late AppDatabase db;
  late DateTime clock;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = DateTime(2026, 8, 1);
  });

  tearDown(() => db.close());

  DateTime tick() => clock = clock.add(const Duration(minutes: 1));

  RecentlyViewedCache cacheFor(
    AccountKey account, {
    int maxEntriesPerType = 50,
  }) {
    return RecentlyViewedCache(
      database: db,
      account: account,
      maxEntriesPerType: maxEntriesPerType,
      now: tick,
    );
  }

  Dio clientFor(Uri baseUri) => createGitLabClient(
    account: account,
    baseUrl: baseUri.resolve('/api/v4'),
    readToken: (_) async => const TokenReadResult('tok'),
    refreshToken: (_, _) async => fail('refresh should not be called'),
  );

  /// A base URI whose port no longer accepts connections, so every request
  /// fails the way an offline device's would.
  Future<Uri> offlineBaseUri() async {
    final server = await FakeGitLabServer.start();
    final baseUri = server.baseUri;
    await server.close();
    return baseUri;
  }

  RecentItemRepository<Issue> issueRepository(
    RecentlyViewedCache cache,
    Dio client,
  ) {
    final issues = GitLabIssuesRepository(client);
    return RecentItemRepository(
      cache: cache,
      type: RecentlyViewedType.issue,
      projectId: 7,
      itemId: 142,
      fetch: () => issues.loadIssue(7, 142),
      decode: Issue.fromJson,
      encode: (issue) => issue.toJson(),
      updatedAt: (issue) => issue.updatedAt,
    );
  }

  RecentItemRepository<MergeRequest> mergeRequestRepository(
    RecentlyViewedCache cache,
    Dio client,
  ) {
    final mergeRequests = GitLabMergeRequestsRepository(client);
    return RecentItemRepository(
      cache: cache,
      type: RecentlyViewedType.mergeRequest,
      projectId: 7,
      itemId: 142,
      fetch: () => mergeRequests.loadMergeRequest(7, 142),
      decode: MergeRequest.fromJson,
      encode: (mergeRequest) => mergeRequest.toJson(),
      updatedAt: (mergeRequest) => mergeRequest.updatedAt,
    );
  }

  RecentItemRepository<PipelineDetails> pipelineRepository(
    RecentlyViewedCache cache,
    Dio client,
  ) {
    final pipelines = GitLabPipelinesRepository(client);
    return RecentItemRepository(
      cache: cache,
      type: RecentlyViewedType.pipeline,
      projectId: 7,
      itemId: 88123,
      fetch: () => pipelines.loadPipeline(7, 88123),
      decode: PipelineDetails.fromJson,
      encode: (details) => details.toJson(),
      updatedAt: (details) => details.pipeline.updatedAt,
    );
  }

  test('a viewed issue reads from the cache when offline', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/projects/7/issues', [
      Fixtures.json('issue_142'),
    ]);
    final cache = cacheFor(account);

    final online = issueRepository(cache, clientFor(server.baseUri));
    final viewed = await online.load();

    final offline = issueRepository(cache, clientFor(await offlineBaseUri()));
    await offline.refresh();
    final cached = await offline.readCached();

    expect(cached, isNotNull);
    expect(cached!.title, viewed.title);
    expect(cached.description, viewed.description);
    expect(cached.state, viewed.state);
    expect(cached.author.username, viewed.author.username);
    expect(
      [for (final label in cached.labels) (label.name, label.colorHex)],
      [for (final label in viewed.labels) (label.name, label.colorHex)],
    );
    expect(
      [for (final assignee in cached.assignees) assignee.username],
      [for (final assignee in viewed.assignees) assignee.username],
    );
    expect(cached.milestoneTitle, viewed.milestoneTitle);
    expect(cached.updatedAt, viewed.updatedAt);
  });

  test(
    'a malformed cached issue is replaced by the network response',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      server.respondJson('GET /api/v4/projects/7/issues', [
        Fixtures.json('issue_142'),
      ]);
      final cache = cacheFor(account);
      await cache.put(RecentlyViewedType.issue, 7, 142, '{malformed');
      final repository = issueRepository(cache, clientFor(server.baseUri));

      expect(await repository.readCached(), isNull);
      expect(
        await cache.watchPayload(RecentlyViewedType.issue, 7, 142).first,
        isNull,
      );

      final loaded = await repository.load();
      final cached = await repository.readCached();
      expect(cached!.title, loaded.title);
    },
  );

  test('a touch failure still serves a readable cached issue', () async {
    final cache = _FailingTouchRecentlyViewedCache(
      database: db,
      account: account,
      now: tick,
    );
    await cache.put(
      RecentlyViewedType.issue,
      7,
      142,
      Fixtures.raw('issue_142'),
    );
    final repository = issueRepository(
      cache,
      clientFor(Uri.parse('http://127.0.0.1:1')),
    );

    final cached = await repository.readCached();

    expect(cached!.title, 'Keep draft comments after reconnecting');
    expect(
      await cache.watchPayload(RecentlyViewedType.issue, 7, 142).first,
      isNotNull,
    );
  });

  test(
    'a background refresh updates the cache and the stream re-emits',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      final issueJson = Map<String, dynamic>.from(
        Fixtures.json('issue_142') as Map,
      );
      server.respondJson('GET /api/v4/projects/7/issues', [issueJson]);
      final repository = issueRepository(
        cacheFor(account),
        clientFor(server.baseUri),
      );

      await repository.refresh();

      final titles = repository.watch().map((issue) => issue?.title);
      final expectation = expectLater(
        titles,
        emitsInOrder([
          'Keep draft comments after reconnecting',
          'Keep draft comments after reconnecting (edited)',
        ]),
      );

      server.respondJson('GET /api/v4/projects/7/issues', [
        {
          ...issueJson,
          'title': 'Keep draft comments after reconnecting (edited)',
        },
      ]);
      await repository.refresh();

      await expectation;
    },
  );

  test('a viewed merge request reads from the cache when offline', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/7/merge_requests/142',
      Fixtures.json('merge_request_142'),
    );
    final cache = cacheFor(account);

    final viewed = await mergeRequestRepository(
      cache,
      clientFor(server.baseUri),
    ).load();

    final offline = mergeRequestRepository(
      cache,
      clientFor(await offlineBaseUri()),
    );
    await offline.refresh();
    final cached = await offline.readCached();

    expect(cached, isNotNull);
    expect(cached!.title, viewed.title);
    expect(cached.state, viewed.state);
    expect(cached.draft, viewed.draft);
    expect(cached.author.username, viewed.author.username);
    expect(cached.sourceBranch, viewed.sourceBranch);
    expect(cached.targetBranch, viewed.targetBranch);
    expect(cached.labels, viewed.labels);
    expect(cached.changesCount, viewed.changesCount);
  });

  test('a viewed pipeline reads from the cache when offline', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson(
      'GET /api/v4/projects/7/pipelines/88123',
      Fixtures.json('pipeline_88123'),
    );
    server.respondJson(
      'GET /api/v4/projects/7/pipelines/88123/jobs',
      Fixtures.json('pipeline_88123_jobs'),
    );
    final cache = cacheFor(account);

    final viewed = await pipelineRepository(
      cache,
      clientFor(server.baseUri),
    ).load();

    final offline = pipelineRepository(
      cache,
      clientFor(await offlineBaseUri()),
    );
    await offline.refresh();
    final cached = await offline.readCached();

    expect(cached, isNotNull);
    expect(cached!.pipeline.status, viewed.pipeline.status);
    expect(cached.pipeline.ref, viewed.pipeline.ref);
    expect(cached.pipeline.sha, viewed.pipeline.sha);
    expect(
      [for (final job in cached.jobs) (job.stage, job.name, job.badgeStatus)],
      [for (final job in viewed.jobs) (job.stage, job.name, job.badgeStatus)],
    );
  });

  test(
    'a mutation invalidates then a later view re-caches fresh data',
    () async {
      final server = await FakeGitLabServer.start();
      addTearDown(server.close);
      server.respondJson(
        'GET /api/v4/projects/7/pipelines/88123',
        Fixtures.json('pipeline_88123'),
      );
      server.respondJson(
        'GET /api/v4/projects/7/pipelines/88123/jobs',
        Fixtures.json('pipeline_88123_jobs'),
      );
      final cache = cacheFor(account);
      final online = pipelineRepository(cache, clientFor(server.baseUri));
      await online.load();

      await online.invalidate();
      expect(
        await cache.watchPayload(RecentlyViewedType.pipeline, 7, 88123).first,
        isNull,
      );

      final jobs = (Fixtures.json('pipeline_88123_jobs') as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();
      jobs.firstWhere((job) => job['id'] == 502)['status'] = 'canceled';
      server.respondJson('GET /api/v4/projects/7/pipelines/88123/jobs', jobs);
      await online.load();

      final cached = await online.readCached();
      expect(
        cached!.jobs.firstWhere((job) => job.id == 502).status,
        CiStatus.canceled,
      );
      expect(cached.pipeline.updatedAt, DateTime.parse('2026-08-02T09:58:00Z'));
    },
  );

  test('the bound evicts the least recently viewed entries', () async {
    final cache = cacheFor(account, maxEntriesPerType: 3);

    // A different type's entry is untouched by the issue bound.
    await cache.put(RecentlyViewedType.pipeline, 7, 900, '{}');
    for (final itemId in [1, 2, 3]) {
      await cache.put(RecentlyViewedType.issue, 7, itemId, '{}');
    }

    // Re-viewing item 1 protects it, so item 2 becomes the eviction victim.
    await cache.touch(RecentlyViewedType.issue, 7, 1);
    await cache.put(RecentlyViewedType.issue, 7, 4, '{}');

    Future<String?> cachedIssue(int itemId) =>
        cache.watchPayload(RecentlyViewedType.issue, 7, itemId).first;
    expect(await cachedIssue(1), isNotNull);
    expect(await cachedIssue(2), isNull);
    expect(await cachedIssue(3), isNotNull);
    expect(await cachedIssue(4), isNotNull);
    expect(
      await cache.watchPayload(RecentlyViewedType.pipeline, 7, 900).first,
      isNotNull,
    );
    expect((await db.select(db.recentlyViewedItems).get()).length, 4);
  });

  test('one account\'s cache never serves another\'s', () async {
    const other = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'bob',
    );
    final aliceCache = cacheFor(account);
    final bobCache = cacheFor(other);

    await aliceCache.put(RecentlyViewedType.issue, 7, 142, '{"who":"alice"}');

    expect(
      await bobCache.watchPayload(RecentlyViewedType.issue, 7, 142).first,
      isNull,
    );

    await bobCache.put(RecentlyViewedType.issue, 7, 142, '{"who":"bob"}');
    expect(
      await aliceCache.watchPayload(RecentlyViewedType.issue, 7, 142).first,
      '{"who":"alice"}',
    );
  });

  test('the composite key is scoped by instanceHost + accountId', () {
    expect(
      db.recentlyViewedItems.primaryKey,
      containsAll([
        db.recentlyViewedItems.instanceHost,
        db.recentlyViewedItems.accountId,
      ]),
    );
  });
}

class _FailingTouchRecentlyViewedCache extends RecentlyViewedCache {
  _FailingTouchRecentlyViewedCache({
    required super.database,
    required super.account,
    required super.now,
  });

  @override
  Future<void> touch(RecentlyViewedType type, int projectId, int itemId) =>
      Future.error(StateError('touch failed'));
}
