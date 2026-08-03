import 'dart:convert';
import 'dart:io';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/gitlab_oauth.dart';
import 'package:gitsune/core/auth/oauth_config.dart';
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

const _tokenResponse = {
  'access_token': 'at-1',
  'token_type': 'Bearer',
  'refresh_token': 'rt-1',
  'expires_in': 7200,
  'scope': 'api read_user',
};

void main() {
  test('self-hosted config derives both endpoints from the instance base '
      'URL and uses the pasted Application ID as the client id', () {
    final config = GitLabOAuthConfig.selfHosted(
      baseUrl: Uri.parse('https://gitlab.example.com:8443'),
      applicationId: 'pasted-application-id',
    );
    expect(config.clientId, 'pasted-application-id');
    expect(
      config.authorizeEndpoint,
      Uri.parse('https://gitlab.example.com:8443/oauth/authorize'),
    );
    expect(
      config.tokenEndpoint,
      Uri.parse('https://gitlab.example.com:8443/oauth/token'),
    );
  });

  test('self-hosted authorization request carries the Application ID and '
      'the same fixed redirect gitlab.com uses', () {
    final oauth = GitLabOAuth(
      config: GitLabOAuthConfig.selfHosted(
        baseUrl: Uri.parse('https://gitlab.example.com'),
        applicationId: 'pasted-application-id',
      ),
      tokenStore: _MemoryTokenStore(),
    );
    final request = oauth.buildAuthorizationRequest();
    expect(request.clientId, 'pasted-application-id');
    expect(request.redirectUrl, 'dev.gitsune://oauth-callback');
    expect(request.scopes, ['api', 'read_user']);
    expect(
      request.serviceConfiguration?.authorizationEndpoint,
      'https://gitlab.example.com/oauth/authorize',
    );
    expect(
      request.serviceConfiguration?.tokenEndpoint,
      'https://gitlab.example.com/oauth/token',
    );
  });

  test('authorization request targets gitlab.com with the baked-in '
      'public client id, fixed redirect, and blueprint scopes', () {
    final oauth = GitLabOAuth(
      config: GitLabOAuthConfig.gitlabCom,
      tokenStore: _MemoryTokenStore(),
    );
    final request = oauth.buildAuthorizationRequest();
    expect(request.clientId, gitlabComClientId);
    expect(request.redirectUrl, 'dev.gitsune://oauth-callback');
    expect(request.scopes, ['api', 'read_user']);
    expect(
      request.serviceConfiguration?.authorizationEndpoint,
      'https://gitlab.com/oauth/authorize',
    );
    expect(
      request.serviceConfiguration?.tokenEndpoint,
      'https://gitlab.com/oauth/token',
    );
  });

  group('against the fake server', () {
    late FakeGitLabServer server;

    setUp(() async {
      server = await FakeGitLabServer.start();
    });

    tearDown(() => server.close());

    // Every fake-server test runs as a self-hosted instance: endpoints
    // derived from the server's base URL, client id overridden (E2.2).
    GitLabOAuth oauth({Authorizer? authorizer, TokenStore? tokenStore}) =>
        GitLabOAuth(
          config: GitLabOAuthConfig.selfHosted(
            baseUrl: server.baseUri,
            applicationId: 'test-client',
          ),
          tokenStore: tokenStore ?? _MemoryTokenStore(),
          authorizer: authorizer,
        );

    test('exchangeCode posts a PKCE public-client exchange and parses '
        'the token response', () async {
      late Map<String, String> form;
      server.handle('POST /oauth/token', (request) async {
        form = Uri.splitQueryString(await utf8.decoder.bind(request).join());
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(_tokenResponse));
        await request.response.close();
      });

      final before = DateTime.now();
      final tokens = await oauth().exchangeCode(
        code: 'the-code',
        codeVerifier: 'the-verifier',
      );

      expect(form['grant_type'], 'authorization_code');
      expect(form['client_id'], 'test-client');
      expect(form['code'], 'the-code');
      expect(form['code_verifier'], 'the-verifier');
      expect(form['redirect_uri'], oauthRedirectUri);
      expect(form.containsKey('client_secret'), isFalse);

      expect(tokens.accessToken, 'at-1');
      expect(tokens.refreshToken, 'rt-1');
      // Expiry comes from the server's expires_in, measured from receipt.
      final expiresAt = tokens.expiresAt!;
      expect(
        expiresAt.isAfter(before.add(const Duration(seconds: 7199))),
        isTrue,
      );
      expect(
        expiresAt.isBefore(DateTime.now().add(const Duration(seconds: 7201))),
        isTrue,
      );
    });

    test('signIn drives authorize, exchanges its code and verifier, '
        'resolves the account, and persists the tokens under its composite '
        'key', () async {
      server.respondJson('POST /oauth/token', _tokenResponse);
      String? userAuthHeader;
      server.handle('GET /api/v4/user', (request) async {
        userAuthHeader = request.headers.value('authorization');
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'id': 42, 'username': 'alice'}));
        await request.response.close();
      });
      final store = _MemoryTokenStore();
      AuthorizationRequest? sentToBrowser;
      final session = await oauth(
        tokenStore: store,
        authorizer: (request) async {
          sentToBrowser = request;
          return const AuthorizationResponse(
            authorizationCode: 'code-1',
            codeVerifier: 'verifier-1',
          );
        },
      ).signIn();

      expect(sentToBrowser?.clientId, 'test-client');
      // Who signed in is resolved with the just-issued token, and storage
      // is keyed by the composite account key.
      expect(userAuthHeader, 'Bearer at-1');
      final account = AccountKey(
        instanceHost: server.baseUri.authority,
        accountId: '42',
      );
      expect(session.account, account);
      expect(session.tokens.accessToken, 'at-1');
      expect(store.tokens[account]?.accessToken, 'at-1');
      expect(store.tokens[account]?.refreshToken, 'rt-1');
    });

    test('signIn refuses an authorize response without a code and '
        'persists nothing', () async {
      final store = _MemoryTokenStore();
      final attempt = oauth(
        tokenStore: store,
        authorizer: (_) async => const AuthorizationResponse(),
      ).signIn();

      await expectLater(attempt, throwsStateError);
      expect(store.tokens, isEmpty);
    });
  });
}
