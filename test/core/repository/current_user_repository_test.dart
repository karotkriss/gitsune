import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/repository/current_user_repository.dart';

import '../../support/fake_gitlab_server.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('an initial read serves the cached database state', () async {
    await db
        .into(db.currentUserProfiles)
        .insert(
          CurrentUserProfilesCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            username: 'alice',
            name: 'Alice Cached',
            updatedAt: DateTime.now(),
          ),
        );

    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = CurrentUserRepository(
      database: db,
      client: client,
      account: account,
    );

    final profile = await repository.watch().first;

    expect(profile?.name, 'Alice Cached');
  });

  test('a refresh writes through and the stream re-emits', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/user', {
      'username': 'alice',
      'name': 'Alice Fresh',
      'avatar_url': 'https://example.com/alice.png',
    });

    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = CurrentUserRepository(
      database: db,
      client: client,
      account: account,
    );

    final emissions = repository.watch().map((profile) => profile?.name);
    final expectation = expectLater(
      emissions,
      emitsInOrder([null, 'Alice Fresh']),
    );

    await repository.refresh();

    await expectation;
  });

  test('a network failure leaves cached data served (offline-first)', () async {
    await db
        .into(db.currentUserProfiles)
        .insert(
          CurrentUserProfilesCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            username: 'alice',
            name: 'Alice Cached',
            updatedAt: DateTime.now(),
          ),
        );

    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/user', {'error': 'boom'}, statusCode: 500);

    final client = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok',
      refreshToken: (_) async => fail('refresh should not be called'),
    );
    final repository = CurrentUserRepository(
      database: db,
      client: client,
      account: account,
    );

    await repository.refresh();

    final profile = await repository.watch().first;
    expect(profile?.name, 'Alice Cached');
  });

  test('the composite key is instanceHost + accountId', () {
    expect(db.currentUserProfiles.primaryKey, {
      db.currentUserProfiles.instanceHost,
      db.currentUserProfiles.accountId,
    });
  });
}
