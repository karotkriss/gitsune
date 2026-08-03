import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('loads project issues through Link-header pagination', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var requestCount = 0;
    server.handle('GET /api/v4/projects/7/issues', (request) async {
      requestCount++;
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      final cursor = request.uri.queryParameters['cursor'];
      if (cursor == null) {
        expect(request.uri.queryParameters, containsPair('scope', 'all'));
        expect(
          request.uri.queryParameters,
          containsPair('pagination', 'keyset'),
        );
        expect(
          request.uri.queryParameters,
          containsPair('with_labels_details', 'true'),
        );
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/issues?cursor=page2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('issues_page1'));
      } else {
        expect(cursor, 'page2');
        request.response.write(Fixtures.raw('issues_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabIssuesRepository(_client(server, account));
    final first = await repository.loadFirstPage(7);
    final second = await repository.loadNextPage(7);

    expect(first.items.map((issue) => issue.iid), [142, 141]);
    expect(first.hasMore, isTrue);
    expect(first.items.first.labels.first.name, 'workflow::in review');
    expect(first.items.first.labels.first.colorHex, '#7B58CF');
    expect(first.items.first.labels.first.textColorHex, '#FFFFFF');
    expect(second.items.single.iid, 140);
    expect(second.items.single.state, IssueState.closed);
    expect(second.hasMore, isFalse);
    expect(requestCount, 2);

    final exhausted = await repository.loadNextPage(7);
    expect(exhausted.items, isEmpty);
    expect(requestCount, 2);
  });

  test('loads issue detail and paginates its chronological notes', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('GET /api/v4/projects/7/issues', (request) async {
      expect(request.uri.queryParameters, containsPair('iids[]', '142'));
      expect(
        request.uri.queryParameters,
        containsPair('with_labels_details', 'true'),
      );
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response.write('[${Fixtures.raw('issue_142')}]');
      await request.response.close();
    });
    server.handle('GET /api/v4/projects/7/issues/142/notes', (request) async {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      final page = request.uri.queryParameters['page'];
      if (page == null) {
        expect(request.uri.queryParameters, containsPair('sort', 'asc'));
        expect(
          request.uri.queryParameters,
          containsPair('order_by', 'created_at'),
        );
        final nextUri = server.baseUri.resolve(
          '/api/v4/projects/7/issues/142/notes?page=2',
        );
        request.response.headers.set('Link', '<$nextUri>; rel="next"');
        request.response.write(Fixtures.raw('issue_142_notes_page1'));
      } else {
        expect(page, '2');
        request.response.write(Fixtures.raw('issue_142_notes_page2'));
      }
      await request.response.close();
    });

    final repository = GitLabIssuesRepository(_client(server, account));
    final issue = await repository.loadIssue(7, 142);
    final firstNotes = await repository.loadFirstNotesPage(7, 142);
    final secondNotes = await repository.loadNextNotesPage(7, 142);

    expect(issue.title, 'Keep draft comments after reconnecting');
    expect(issue.milestoneTitle, 'v1.0');
    expect(issue.assignees.single.username, 'suki');
    expect(issue.labels.first.colorHex, '#7B58CF');
    expect(issue.labels.first.textColorHex, '#FFFFFF');
    expect(firstNotes.items.single.id, 9001);
    expect(firstNotes.items.single.system, isTrue);
    expect(firstNotes.hasMore, isTrue);
    expect(secondNotes.items.single.id, 9002);
    expect(secondNotes.items.single.system, isFalse);
    expect(secondNotes.hasMore, isFalse);
  });
  test('creates an issue and decodes the created payload', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    Map<String, dynamic>? postedBody;
    server.handle('POST /api/v4/projects/7/issues', (request) async {
      postedBody =
          jsonDecode(await utf8.decodeStream(request)) as Map<String, dynamic>;
      request.response.statusCode = HttpStatus.created;
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('issue_created_143'));
      await request.response.close();
    });

    final repository = GitLabIssuesRepository(_client(server, account));
    final issue = await repository.createIssue(
      7,
      title: 'Track reconnect regressions',
      description: 'Watch the reconnect flow for **regressions**.',
    );

    expect(postedBody, {
      'title': 'Track reconnect regressions',
      'description': 'Watch the reconnect flow for **regressions**.',
    });
    expect(issue.iid, 143);
    expect(issue.title, 'Track reconnect regressions');
    expect(issue.state, IssueState.opened);
    expect(issue.author.username, 'marin');
  });

  test('posts a comment and decodes the created note', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    Map<String, dynamic>? postedBody;
    server.handle('POST /api/v4/projects/7/issues/142/notes', (request) async {
      postedBody =
          jsonDecode(await utf8.decodeStream(request)) as Map<String, dynamic>;
      request.response.statusCode = HttpStatus.created;
      request.response.headers.contentType = ContentType.json;
      request.response.write(Fixtures.raw('issue_142_note_created'));
      await request.response.close();
    });

    final repository = GitLabIssuesRepository(_client(server, account));
    final note = await repository.createNote(
      7,
      142,
      'Confirmed on the **latest** build.',
    );

    expect(postedBody, {'body': 'Confirmed on the **latest** build.'});
    expect(note.id, 9101);
    expect(note.body, 'Confirmed on the **latest** build.');
    expect(note.system, isFalse);
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => 'fixture-token',
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
