import 'dart:convert';
import 'dart:io';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/gitlab_oauth.dart';
import 'package:gitsune/core/auth/oauth_config.dart';
import 'package:gitsune/core/auth/token_store.dart';

import '../../support/fake_gitlab_server.dart';

class _MemoryTokenStore implements TokenStore {
  OAuthTokens? tokens;

  @override
  Future<void> save(OAuthTokens tokens) async => this.tokens = tokens;

  @override
  Future<OAuthTokens?> read() async => tokens;

  @override
  Future<void> clear() async => tokens = null;
}

const _tokenResponse = {
  'access_token': 'at-1',
  'token_type': 'Bearer',
  'refresh_token': 'rt-1',
  'expires_in': 7200,
  'scope': 'api read_user',
};

void main() {
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

    GitLabOAuth oauth({Authorizer? authorizer, TokenStore? tokenStore}) =>
        GitLabOAuth(
          config: GitLabOAuthConfig(
            clientId: 'test-client',
            authorizeEndpoint: server.baseUri.replace(path: '/oauth/authorize'),
            tokenEndpoint: server.baseUri.replace(path: '/oauth/token'),
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
      expect(expiresAt.isAfter(before.add(const Duration(seconds: 7199))),
          isTrue);
      expect(
        expiresAt.isBefore(DateTime.now().add(const Duration(seconds: 7201))),
        isTrue,
      );
    });

    test('signIn drives authorize, exchanges its code and verifier, and '
        'persists the tokens', () async {
      server.respondJson('POST /oauth/token', _tokenResponse);
      final store = _MemoryTokenStore();
      AuthorizationRequest? sentToBrowser;
      final tokens = await oauth(
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
      expect(tokens.accessToken, 'at-1');
      expect(store.tokens?.accessToken, 'at-1');
      expect(store.tokens?.refreshToken, 'rt-1');
    });

    test('signIn refuses an authorize response without a code and '
        'persists nothing', () async {
      final store = _MemoryTokenStore();
      final attempt = oauth(
        tokenStore: store,
        authorizer: (_) async => const AuthorizationResponse(),
      ).signIn();

      await expectLater(attempt, throwsStateError);
      expect(store.tokens, isNull);
    });
  });
}
