import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/account_sessions.dart';
import 'package:gitsune/core/auth/oauth_config.dart';
import 'package:gitsune/core/auth/token_refresh.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/memory_secure_storage.dart';

void main() {
  // Two accounts on one instance plus the same account id on another
  // instance: only the full composite key tells them all apart.
  const alice = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
  const bob = AccountKey(instanceHost: 'gitlab.com', accountId: '2');
  const selfHostedAlice = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: '1',
  );

  late AppDatabase database;
  late AccountSessions sessions;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sessions = AccountSessions(database);
  });

  tearDown(() => database.close());

  AccountKey keyOf(Account row) =>
      AccountKey(instanceHost: row.instanceHost, accountId: row.accountId);

  test(
    'accounts across instances coexist, keyed by the composite key',
    () async {
      await sessions.signedIn(alice);
      await sessions.signedIn(bob);
      await sessions.signedIn(selfHostedAlice);

      final accounts = await sessions.watchAll().first;
      expect(accounts.map(keyOf), [alice, bob, selfHostedAlice]);
      expect(accounts.map((row) => row.needsReauth), everyElement(isFalse));
    },
  );

  test('same-second sign-ins keep insertion order', () async {
    final sameInstant = DateTime.utc(2026, 8, 4, 12);
    sessions = AccountSessions(database, now: () => sameInstant);

    await sessions.signedIn(selfHostedAlice);
    await sessions.signedIn(bob);
    await sessions.signedIn(alice);

    final accounts = await sessions.watchAll().first;
    expect(accounts.map(keyOf), [selfHostedAlice, bob, alice]);
    expect(
      accounts.map((row) => row.addedAt.microsecondsSinceEpoch),
      orderedEquals([
        sameInstant.microsecondsSinceEpoch,
        sameInstant.microsecondsSinceEpoch + 1,
        sameInstant.microsecondsSinceEpoch + 2,
      ]),
    );
  });

  test('signing in an already-registered account is idempotent and keeps '
      'its switcher position', () async {
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await sessions.signedIn(alice);

    final accounts = await sessions.watchAll().first;
    expect(accounts.map(keyOf), [alice, bob]);
  });

  test('marking one account for re-auth keeps it in the switcher and '
      'leaves every other account untouched', () async {
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await sessions.signedIn(selfHostedAlice);

    await sessions.markNeedsReauth(selfHostedAlice);

    final accounts = await sessions.watchAll().first;
    expect(accounts.map(keyOf), [alice, bob, selfHostedAlice]);
    expect(
      {for (final row in accounts) keyOf(row): row.needsReauth},
      {alice: false, bob: false, selfHostedAlice: true},
    );
  });

  test('re-signing-in a marked account clears only its re-auth mark', () async {
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await sessions.markNeedsReauth(alice);
    await sessions.markNeedsReauth(bob);

    await sessions.signedIn(alice);

    final accounts = await sessions.watchAll().first;
    expect(
      {for (final row in accounts) keyOf(row): row.needsReauth},
      {alice: false, bob: true},
    );
  });

  test('a rejected refresh marks only that account for re-auth; the other '
      'account keeps working and both stay in the switcher', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    // One instance rejects alice's refresh (revoked grant); bob's rotates
    // normally. Distinguished by the refresh token each account stored.
    server.handle('POST /oauth/token', (request) async {
      final form = Uri.splitQueryString(
        await utf8.decoder.bind(request).join(),
      );
      if (form['refresh_token'] != 'rt-bob') {
        request.response.statusCode = 400;
        request.response.write(jsonEncode({'error': 'invalid_grant'}));
        await request.response.close();
        return;
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'access_token': 'at-bob-2',
          'token_type': 'Bearer',
          'refresh_token': 'rt-bob-2',
          'expires_in': 7200,
        }),
      );
      await request.response.close();
    });

    final store = SecureTokenStore(storage: MemorySecureStorage());
    final coordinator = TokenRefreshCoordinator(
      tokenStore: store,
      configFor: (_) => GitLabOAuthConfig(
        clientId: 'test-client',
        authorizeEndpoint: server.baseUri.replace(path: '/oauth/authorize'),
        tokenEndpoint: server.baseUri.replace(path: '/oauth/token'),
      ),
      onReauthRequired: sessions.markNeedsReauth,
    );

    final expired = DateTime.now().subtract(const Duration(minutes: 1));
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    await store.save(
      alice,
      OAuthTokens(
        accessToken: 'at-alice',
        refreshToken: 'rt-alice',
        expiresAt: expired,
      ),
    );
    await store.save(
      bob,
      OAuthTokens(
        accessToken: 'at-bob',
        refreshToken: 'rt-bob',
        expiresAt: expired,
      ),
    );

    expect(await coordinator.refreshToken(alice, 'at-alice'), isNull);
    expect(await coordinator.refreshToken(bob, 'at-bob'), 'at-bob-2');

    final accounts = await sessions.watchAll().first;
    expect(accounts.map(keyOf), [alice, bob]);
    expect(
      {for (final row in accounts) keyOf(row): row.needsReauth},
      {alice: true, bob: false},
    );

    // Isolation holds in the token store too: alice's stored session is
    // untouched (ready for scoped re-auth) and bob's rotated normally.
    expect((await store.read(alice))?.refreshToken, 'rt-alice');
    expect((await store.read(bob))?.refreshToken, 'rt-bob-2');
  });
}
