import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/pat_auth.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/network/account_key.dart';

import '../../support/fake_gitlab_server.dart';

class _MemoryTokenStore implements TokenStore {
  final tokens = <AccountKey, OAuthTokens>{};

  @override
  Future<void> save(AccountKey account, OAuthTokens tokens) async =>
      this.tokens[account] = tokens;

  @override
  Future<OAuthTokens?> read(AccountKey account) async => tokens[account];

  @override
  Future<void> clear(AccountKey account) async => tokens.remove(account);
}

void main() {
  late FakeGitLabServer server;

  setUp(() async {
    server = await FakeGitLabServer.startSecure();
  });

  tearDown(() => server.close());

  test('a valid token is checked with GET /user and stored under the '
      'account composite key without refresh token or expiry', () async {
    String? authHeader;
    server.handle('GET /api/v4/user', (request) async {
      authHeader = request.headers.value('authorization');
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"id":42,"username":"alice"}');
      await request.response.close();
    });
    final store = _MemoryTokenStore();

    final session = await signInWithPat(
      baseUrl: server.baseUri,
      token: 'glpat-abc123',
      tokenStore: store,
      dio: server.createClient(),
    );

    expect(authHeader, 'Bearer glpat-abc123');
    final account = AccountKey(
      instanceHost: server.baseUri.authority,
      accountId: '42',
    );
    expect(session.account, account);
    final stored = store.tokens[account]!;
    expect(stored.accessToken, 'glpat-abc123');
    // A PAT never refreshes: a later 401 must surface as re-enter-token.
    expect(stored.refreshToken, isNull);
    expect(stored.expiresAt, isNull);
  });

  test('a rejected token throws and persists nothing', () async {
    server.respondJson('GET /api/v4/user', {
      'message': '401 Unauthorized',
    }, statusCode: 401);
    final store = _MemoryTokenStore();

    final attempt = signInWithPat(
      baseUrl: server.baseUri,
      token: 'glpat-wrong',
      tokenStore: store,
      dio: server.createClient(),
    );

    await expectLater(
      attempt,
      throwsA(
        isA<PatSignInException>().having(
          (error) => error.failure,
          'failure',
          PatSignInFailure.rejected,
        ),
      ),
    );
    expect(store.tokens, isEmpty);
  });

  test('an HTTP instance is refused before the token is sent', () async {
    var requested = false;
    server.handle('GET /api/v4/user', (_) async {
      requested = true;
    });

    final attempt = signInWithPat(
      baseUrl: server.baseUri.replace(scheme: 'http'),
      token: 'glpat-secret',
      tokenStore: _MemoryTokenStore(),
      dio: server.createClient(),
    );

    await expectLater(
      attempt,
      throwsA(
        isA<PatSignInException>().having(
          (error) => error.failure,
          'failure',
          PatSignInFailure.insecureTransport,
        ),
      ),
    );
    expect(requested, isFalse);
  });

  test('a dropped connection is classified as a network error', () async {
    server.handle('GET /api/v4/user', (request) async {
      final socket = await request.response.detachSocket();
      socket.destroy();
    });

    final attempt = signInWithPat(
      baseUrl: server.baseUri,
      token: 'glpat-abc123',
      tokenStore: _MemoryTokenStore(),
      dio: server.createClient(),
    );

    await expectLater(
      attempt,
      throwsA(
        isA<PatSignInException>().having(
          (error) => error.failure,
          'failure',
          PatSignInFailure.network,
        ),
      ),
    );
  });
}
