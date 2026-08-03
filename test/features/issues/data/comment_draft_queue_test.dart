import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/features/issues/data/comment_draft_queue.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';

import '../../../support/fake_gitlab_server.dart';
import '../../../support/fixtures.dart';

const _account = AccountKey(instanceHost: 'gitlab.example.com', accountId: '1');
const _notesPath = 'POST /api/v4/projects/7/issues/142/notes';

void main() {
  late AppDatabase database;
  late StreamController<void> reconnect;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    reconnect = StreamController<void>.broadcast();
  });

  tearDown(() async {
    await reconnect.close();
    await database.close();
  });

  CommentDraftQueue queue(Dio client, {AccountKey account = _account}) {
    final created = CommentDraftQueue(
      database: database,
      account: account,
      repository: GitLabIssuesRepository(client),
      onReconnect: reconnect.stream,
    );
    addTearDown(created.dispose);
    return created;
  }

  /// Binds and immediately closes a server, yielding an address that refuses
  /// connections: the closest loopback approximation of being offline.
  Future<int> offlinePort() async {
    final probe = await FakeGitLabServer.start();
    final port = probe.baseUri.port;
    await probe.close();
    return port;
  }

  Dio client(int port) => createGitLabClient(
    account: _account,
    baseUrl: Uri.http('localhost:$port', '/api/v4'),
    readToken: (_) async => const TokenReadResult('fixture-token'),
    refreshToken: (_, _) async => fail('refresh should not be called'),
  );

  /// Registers a notes POST handler that records each sent body and answers
  /// with the created-note fixture carrying that body.
  List<String> serveNotes(FakeGitLabServer server) {
    final bodies = <String>[];
    server.handle(_notesPath, (request) async {
      final body =
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      bodies.add(body['body'] as String);
      final note = Map<String, dynamic>.from(
        Fixtures.json('issue_142_note_created') as Map,
      );
      note['id'] = 9000 + bodies.length;
      note['body'] = body['body'];
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(note));
      await request.response.close();
    });
    return bodies;
  }

  test('comments sent offline queue durably and flush in order '
      'on reconnect', () async {
    final port = await offlinePort();
    final offline = queue(client(port));

    await offline.send(7, 142, 'First, while offline');
    await offline.send(7, 142, 'Second, while offline');

    var drafts = await offline.watchDrafts(7, 142).first;
    expect(drafts.map((draft) => draft.body), [
      'First, while offline',
      'Second, while offline',
    ]);
    expect(drafts.map((draft) => draft.lastError), everyElement(isNull));

    // A restart: a fresh queue over the same database still sees the drafts.
    await offline.dispose();
    final restarted = queue(client(port));
    drafts = await restarted.watchDrafts(7, 142).first;
    expect(drafts, hasLength(2));

    // Connectivity returns: the same address serves again.
    final server = await FakeGitLabServer.start(port: port);
    addTearDown(server.close);
    final bodies = serveNotes(server);

    final sent = restarted.sentNotes.take(2).toList();
    reconnect.add(null);
    final events = await sent;

    expect(bodies, ['First, while offline', 'Second, while offline']);
    expect(events.map((event) => (event.projectId, event.issueIid)), [
      (7, 142),
      (7, 142),
    ]);
    expect(events.map((event) => event.note.body), [
      'First, while offline',
      'Second, while offline',
    ]);
    expect(await restarted.watchDrafts(7, 142).first, isEmpty);
  });

  test('a restarted queue allocates after persisted drafts when the clock '
      'is behind', () async {
    final port = await offlinePort();
    final futureId = DateTime.now().microsecondsSinceEpoch + 1000000000;
    await database
        .into(database.commentDrafts)
        .insert(
          CommentDraftsCompanion.insert(
            instanceHost: _account.instanceHost,
            accountId: _account.accountId,
            draftId: futureId,
            projectId: 7,
            issueIid: 142,
            body: 'Persisted first',
          ),
        );

    final restarted = queue(client(port));
    await restarted.send(7, 142, 'Created after restart');

    final drafts = await restarted.watchDrafts(7, 142).first;
    expect(drafts.map((draft) => draft.body), [
      'Persisted first',
      'Created after restart',
    ]);
    expect(drafts.last.draftId, futureId + 1);
  });

  test('a permanent rejection is surfaced, not retried, and does not '
      'block later drafts', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    var attempts = 0;
    server.handle(_notesPath, (request) async {
      attempts++;
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
    });

    final rejecting = queue(client(server.baseUri.port));
    await rejecting.send(7, 142, 'No permission');

    var drafts = await rejecting.watchDrafts(7, 142).first;
    expect(drafts.single.lastError, 'HTTP 403');
    expect(attempts, 1);

    // Further flushes skip the rejected draft entirely.
    await rejecting.flush();
    expect(attempts, 1);

    // A later draft still sends past it.
    final bodies = serveNotes(server);
    final sent = rejecting.sentNotes.first;
    await rejecting.send(7, 142, 'Allowed now');
    await sent;

    expect(bodies, ['Allowed now']);
    drafts = await rejecting.watchDrafts(7, 142).first;
    expect(drafts.single.body, 'No permission');
    expect(drafts.single.lastError, 'HTTP 403');
    // The rejected draft was attempted exactly once, ever.
    expect(attempts, 1);
  });

  test('a transient server failure keeps the draft queued for the next '
      'reconnect', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle(_notesPath, (request) async {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    });

    final flaky = queue(client(server.baseUri.port));
    await flaky.send(7, 142, 'Survives a 500');

    final drafts = await flaky.watchDrafts(7, 142).first;
    expect(drafts.single.lastError, isNull);

    final bodies = serveNotes(server);
    final sent = flaky.sentNotes.first;
    reconnect.add(null);
    await sent;

    expect(bodies, ['Survives a 500']);
    expect(await flaky.watchDrafts(7, 142).first, isEmpty);
  });

  test('one account\'s queue never reads or flushes another\'s '
      'drafts', () async {
    const otherAccount = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: '2',
    );
    final port = await offlinePort();
    final mine = queue(client(port));
    final theirs = queue(client(port), account: otherAccount);

    await mine.send(7, 142, 'Mine');
    await theirs.send(7, 142, 'Theirs');

    expect((await mine.watchDrafts(7, 142).first).single.body, 'Mine');
    expect((await theirs.watchDrafts(7, 142).first).single.body, 'Theirs');

    final server = await FakeGitLabServer.start(port: port);
    addTearDown(server.close);
    final bodies = serveNotes(server);

    await mine.flush();

    expect(bodies, ['Mine']);
    expect(await mine.watchDrafts(7, 142).first, isEmpty);
    expect((await theirs.watchDrafts(7, 142).first).single.body, 'Theirs');
  });
}
