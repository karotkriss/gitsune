import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/keyset_paginator.dart';
import 'package:gitsune/core/network/pagination_cursor_store.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/fixtures.dart';

class _Project {
  const _Project(this.id, this.name);

  final int id;
  final String name;

  static _Project fromJson(Map<String, dynamic> json) =>
      _Project(json['id'] as int, json['name'] as String);
}

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

  /// Serves three keyset-paginated pages of projects, following GitLab's
  /// real behavior: a `Link: <...>; rel="next"` header on every page but
  /// the last, and no total-count headers anywhere.
  ///
  /// [invalidCursor], if given, returns a 400 (an expired/invalid cursor)
  /// instead of a page.
  void registerThreeKeysetPages(
    FakeGitLabServer server, {
    String? invalidCursor,
  }) {
    const fixtureByCursor = {
      null: 'keyset_projects_page1',
      'page2': 'keyset_projects_page2',
      'page3': 'keyset_projects_page3',
    };
    const nextCursorByCursor = {null: 'page2', 'page2': 'page3', 'page3': null};

    server.handle('GET /api/v4/projects', (request) async {
      final cursor = request.uri.queryParameters['cursor'];
      if (cursor != null && cursor == invalidCursor) {
        request.response.statusCode = 400;
        request.response.write('{"error":"invalid_cursor"}');
        await request.response.close();
        return;
      }

      final nextCursor = nextCursorByCursor[cursor];
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      if (nextCursor != null) {
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects?cursor=$nextCursor',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
      }
      request.response.write(Fixtures.raw(fixtureByCursor[cursor]!));
      await request.response.close();
    });
  }

  Dio dioFor(FakeGitLabServer server) =>
      Dio(BaseOptions(baseUrl: server.baseUri.resolve('/api/v4').toString()));

  Uri projectsUri(FakeGitLabServer server) =>
      server.baseUri.resolve('/api/v4/projects');

  test('paginates a multi-page fixture collection to exhaustion', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerThreeKeysetPages(server);

    final paginator = KeysetPaginator<_Project>(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
    );

    final allIds = <int>[];
    while (paginator.hasMore) {
      final page = await paginator.loadNext();
      allIds.addAll(page.items.map((p) => p.id));
    }

    expect(allIds, [1, 2, 3, 4, 5, 6]);
    expect(paginator.hasMore, isFalse);
    expect(paginator.resumeToken, isNull);
  });

  test('never depends on total-count headers', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerThreeKeysetPages(server);

    final paginator = KeysetPaginator<_Project>(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
    );

    final page = await paginator.loadNext();

    expect(page.items, hasLength(2));
    expect(page.hasMore, isTrue);
  });

  test('interrupting mid-collection and recreating the paginator resumes from '
      'the persisted token', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerThreeKeysetPages(server);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final cursorStore = PaginationCursorStore(db);

    final firstPaginator = KeysetPaginator<_Project>(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
    );
    final firstPage = await firstPaginator.loadNext();
    expect(firstPage.items.map((p) => p.id), [1, 2]);

    // "Interrupted" here: only the first page was ever loaded, and its
    // resume token is persisted before the paginator is discarded.
    await cursorStore.save(account, 'projects', firstPaginator.resumeToken!);

    final resumeToken = await cursorStore.read(account, 'projects');
    final resumedPaginator = KeysetPaginator<_Project>.resume(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
      resumeToken: resumeToken,
    );

    final remainingIds = <int>[];
    while (resumedPaginator.hasMore) {
      final page = await resumedPaginator.loadNext();
      remainingIds.addAll(page.items.map((p) => p.id));
    }

    expect(remainingIds, [3, 4, 5, 6]);
  });

  test('an expired/invalid cursor falls back to a clean restart', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerThreeKeysetPages(server, invalidCursor: 'page3');

    final paginator = KeysetPaginator<_Project>.resume(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
      resumeToken: server.baseUri
          .resolve('/api/v4/projects?cursor=page3')
          .toString(),
    );

    final page = await paginator.loadNext();

    // The persisted cursor was rejected, so this is page 1 again, not the
    // page-3 items the stale cursor pointed at.
    expect(page.items.map((p) => p.id), [1, 2]);
    expect(page.hasMore, isTrue);
  });

  test('a resume token with no persisted value starts fresh', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    registerThreeKeysetPages(server);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final cursorStore = PaginationCursorStore(db);

    final resumeToken = await cursorStore.read(account, 'projects');
    expect(resumeToken, isNull);

    final paginator = KeysetPaginator<_Project>.resume(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
      resumeToken: resumeToken,
    );

    final page = await paginator.loadNext();

    expect(page.items.map((p) => p.id), [1, 2]);
  });

  test('an error unrelated to cursor rejection is not swallowed', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('GET /api/v4/projects', (request) async {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    });

    final paginator = KeysetPaginator<_Project>(
      dio: dioFor(server),
      initialUri: projectsUri(server),
      decode: _Project.fromJson,
    );

    await expectLater(paginator.loadNext(), throwsA(isA<DioException>()));
  });
}
