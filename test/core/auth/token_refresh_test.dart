import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/oauth_config.dart';
import 'package:gitsune/core/auth/token_refresh.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/memory_secure_storage.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: '7',
  );

  late FakeGitLabServer server;
  late SecureTokenStore store;
  late TokenRefreshCoordinator coordinator;
  late Dio api;

  setUp(() async {
    server = await FakeGitLabServer.start();
    store = SecureTokenStore(storage: MemorySecureStorage());
    coordinator = TokenRefreshCoordinator(
      tokenStore: store,
      configFor: (_) => GitLabOAuthConfig(
        clientId: 'test-client',
        authorizeEndpoint: server.baseUri.replace(path: '/oauth/authorize'),
        tokenEndpoint: server.baseUri.replace(path: '/oauth/token'),
      ),
    );
    api = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: coordinator.readToken,
      refreshToken: coordinator.refreshToken,
    );
  });

  tearDown(() => server.close());

  OAuthTokens seedTokens({required bool expired}) => OAuthTokens(
    accessToken: 'at-1',
    refreshToken: 'rt-1',
    expiresAt: expired
        ? DateTime.now().subtract(const Duration(minutes: 1))
        : DateTime.now().add(const Duration(hours: 1)),
  );

  var refreshCalls = 0;
  final refreshForms = <Map<String, String>>[];
  setUp(() {
    refreshCalls = 0;
    refreshForms.clear();
  });

  /// A GitLab-faithful token endpoint: the refresh token is single-use, so
  /// only `rt-1` succeeds (rotating to `at-2`/`rt-2`) and any other value,
  /// including a reused `rt-1` on a second call, is an invalid grant.
  void serveRotatingRefresh() {
    server.handle('POST /oauth/token', (request) async {
      refreshCalls++;
      final form = Uri.splitQueryString(
        await utf8.decoder.bind(request).join(),
      );
      refreshForms.add(form);
      final grantValid =
          refreshCalls == 1 &&
          form['grant_type'] == 'refresh_token' &&
          form['refresh_token'] == 'rt-1';
      if (!grantValid) {
        request.response.statusCode = 400;
        request.response.write(jsonEncode({'error': 'invalid_grant'}));
        await request.response.close();
        return;
      }
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'access_token': 'at-2',
          'token_type': 'Bearer',
          'refresh_token': 'rt-2',
          'expires_in': 7200,
        }),
      );
      await request.response.close();
    });
  }

  var apiCalls = 0;
  setUp(() => apiCalls = 0);

  /// An API endpoint that only accepts the rotated access token; the
  /// pre-rotation `at-1` gets a 401.
  void serveProjectsAccepting(String token) {
    server.handle('GET /api/v4/projects', (request) async {
      apiCalls++;
      if (request.headers.value('authorization') != 'Bearer $token') {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        return;
      }
      request.response.write('[]');
      await request.response.close();
    });
  }

  test('an expired token refreshes exactly once before the request goes '
      'out, rotates the stored pair, and the request succeeds', () async {
    serveRotatingRefresh();
    serveProjectsAccepting('at-2');
    await store.save(account, seedTokens(expired: true));

    final before = DateTime.now();
    final response = await api.get<String>('/projects');

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    // Lazy refresh happened before the call, so the expired token was
    // never sent.
    expect(apiCalls, 1);

    // A public-client refresh: no secret, no PKCE verifier.
    final form = refreshForms.single;
    expect(form['grant_type'], 'refresh_token');
    expect(form['client_id'], 'test-client');
    expect(form['refresh_token'], 'rt-1');
    expect(form.containsKey('client_secret'), isFalse);
    expect(form.containsKey('code_verifier'), isFalse);

    // The rotated pair is persisted, with expiry read from the server's
    // expires_in.
    final stored = await store.read(account);
    expect(stored?.accessToken, 'at-2');
    expect(stored?.refreshToken, 'rt-2');
    final expiresAt = stored!.expiresAt!;
    expect(
      expiresAt.isAfter(before.add(const Duration(seconds: 7199))),
      isTrue,
    );
    expect(
      expiresAt.isBefore(DateTime.now().add(const Duration(seconds: 7201))),
      isTrue,
    );
  });

  test('concurrent requests against an expired token trigger exactly one '
      'refresh (single flight), and all of them succeed with the rotated '
      'token', () async {
    serveRotatingRefresh();
    serveProjectsAccepting('at-2');
    await store.save(account, seedTokens(expired: true));

    final responses = await Future.wait(
      List.generate(5, (_) => api.get<String>('/projects')),
    );

    // The fake token endpoint 400s any second refresh attempt (the rotated
    // rt-1 is spent), so five successes prove all requests awaited the one
    // refresh rather than firing their own.
    expect(refreshCalls, 1);
    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(apiCalls, 5);
  });

  test('a fresh token is sent as-is, with no refresh', () async {
    server.handle('POST /oauth/token', (request) async {
      refreshCalls++;
      request.response.statusCode = 400;
      await request.response.close();
    });
    serveProjectsAccepting('at-1');
    await store.save(account, seedTokens(expired: false));

    final response = await api.get<String>('/projects');

    expect(response.statusCode, 200);
    expect(refreshCalls, 0);
  });

  test('a 401 on an unexpired token refreshes once and retries once, '
      'succeeding', () async {
    // The server considers at-1 stale even though its local expiry has not
    // passed (e.g. server-side invalidation).
    serveRotatingRefresh();
    serveProjectsAccepting('at-2');
    await store.save(account, seedTokens(expired: false));

    final response = await api.get<String>('/projects');

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(apiCalls, 2);
    expect((await store.read(account))?.refreshToken, 'rt-2');
  });

  test('a second 401 after a successful refresh surfaces as an auth '
      'failure without looping', () async {
    serveRotatingRefresh();
    server.handle('GET /api/v4/projects', (request) async {
      apiCalls++;
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
    });
    await store.save(account, seedTokens(expired: false));

    await expectLater(
      api.get<String>('/projects'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    expect(refreshCalls, 1);
    expect(apiCalls, 2);
  });

  test('a failed refresh surfaces as an auth failure and leaves the stored '
      'tokens untouched', () async {
    server.handle('POST /oauth/token', (request) async {
      refreshCalls++;
      request.response.statusCode = 400;
      request.response.write(jsonEncode({'error': 'invalid_grant'}));
      await request.response.close();
    });
    server.handle('GET /api/v4/projects', (request) async {
      apiCalls++;
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
    });
    await store.save(account, seedTokens(expired: false));

    await expectLater(
      api.get<String>('/projects'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    expect(refreshCalls, 1);
    expect(apiCalls, 1);
    // The failed refresh did not clobber the stored session; E2.6 decides
    // how to mark the account for re-auth.
    expect((await store.read(account))?.refreshToken, 'rt-1');
  });

  test('a caller whose token was already rotated past gets the newer token '
      'without a second refresh', () async {
    server.handle('POST /oauth/token', (request) async {
      refreshCalls++;
      request.response.statusCode = 400;
      await request.response.close();
    });
    await store.save(
      account,
      OAuthTokens(
        accessToken: 'at-2',
        refreshToken: 'rt-2',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );

    // A request that 401'd with the pre-rotation at-1 while another
    // caller's refresh completed: the single-use rt-2 must not be spent.
    final token = await coordinator.refreshToken(account, 'at-1');

    expect(token, 'at-2');
    expect(refreshCalls, 0);
  });
}
