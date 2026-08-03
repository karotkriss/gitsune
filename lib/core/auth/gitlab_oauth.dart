import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'oauth_config.dart';
import 'token_store.dart';

/// Runs the authorization leg in the system browser (Chrome Custom Tabs on
/// Android, the web authentication session on iOS; never an embedded web
/// view) and returns the authorization code plus the S256 PKCE verifier
/// AppAuth generated and bound to it. Injected in tests, where no browser
/// exists.
typedef Authorizer =
    Future<AuthorizationResponse> Function(AuthorizationRequest request);

Future<AuthorizationResponse> _systemBrowserAuthorizer(
  AuthorizationRequest request,
) => FlutterAppAuth().authorize(request);

/// OAuth2 Authorization Code + PKCE sign-in against one GitLab instance,
/// following `docs/research/auth-blueprint.md`.
///
/// The browser leg is delegated to AppAuth, which generates the PKCE pair
/// and validates state natively; the code-for-token exchange then runs here
/// in Dart, so tests can drive it against the fake server and the request
/// provably carries no client secret.
class GitLabOAuth {
  GitLabOAuth({
    required this.config,
    required this.tokenStore,
    Authorizer? authorizer,
    Dio? dio,
  }) : _authorize = authorizer ?? _systemBrowserAuthorizer,
       _dio = dio ?? Dio();

  /// The gitlab.com one-tap sign-in entry point, using the baked-in
  /// Application ID and platform secure storage.
  factory GitLabOAuth.gitlabCom() => GitLabOAuth(
    config: GitLabOAuthConfig.gitlabCom,
    tokenStore: SecureTokenStore(),
  );

  final GitLabOAuthConfig config;
  final TokenStore tokenStore;
  final Authorizer _authorize;
  final Dio _dio;

  AuthorizationRequest buildAuthorizationRequest() => AuthorizationRequest(
    config.clientId,
    oauthRedirectUri,
    serviceConfiguration: AuthorizationServiceConfiguration(
      authorizationEndpoint: config.authorizeEndpoint.toString(),
      tokenEndpoint: config.tokenEndpoint.toString(),
    ),
    scopes: oauthScopes,
  );

  /// Signs in: system-browser authorization, code-for-token exchange, then
  /// persists the tokens so the session survives a restart.
  Future<OAuthTokens> signIn() async {
    final response = await _authorize(buildAuthorizationRequest());
    final code = response.authorizationCode;
    final verifier = response.codeVerifier;
    if (code == null || code.isEmpty || verifier == null || verifier.isEmpty) {
      throw StateError('Authorization returned no code to exchange');
    }
    final tokens = await exchangeCode(code: code, codeVerifier: verifier);
    await tokenStore.save(tokens);
    return tokens;
  }

  /// Exchanges an authorization [code] and its PKCE [codeVerifier] for
  /// tokens. Public client: no secret is ever sent.
  Future<OAuthTokens> exchangeCode({
    required String code,
    required String codeVerifier,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      config.tokenEndpoint.toString(),
      data: {
        'grant_type': 'authorization_code',
        'client_id': config.clientId,
        'code': code,
        'code_verifier': codeVerifier,
        'redirect_uri': oauthRedirectUri,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final body = response.data!;
    final expiresIn = body['expires_in'];
    return OAuthTokens(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String?,
      expiresAt: expiresIn is int
          ? DateTime.now().add(Duration(seconds: expiresIn))
          : null,
    );
  }
}
