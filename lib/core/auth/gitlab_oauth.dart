import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../network/account_key.dart';
import 'oauth_config.dart';
import 'token_store.dart';

/// A completed sign-in: which account it is, and its tokens.
typedef SignedInAccount = ({AccountKey account, OAuthTokens tokens});

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

  /// The self-hosted sign-in entry point (E2.2): endpoints derived from the
  /// instance [baseUrl], the user's pasted [applicationId] as the client ID,
  /// and the same fixed redirect and secure storage as gitlab.com. The E2.3
  /// registration wizard calls this once it has a validated Application ID.
  factory GitLabOAuth.selfHosted({
    required Uri baseUrl,
    required String applicationId,
  }) {
    if (baseUrl.scheme != 'https') {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Self-hosted OAuth requires HTTPS',
      );
    }
    return GitLabOAuth(
      config: GitLabOAuthConfig.selfHosted(
        baseUrl: baseUrl,
        applicationId: applicationId,
      ),
      tokenStore: SecureTokenStore(),
    );
  }

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
  /// persists the tokens under the account's composite key so the session
  /// survives a restart and coexists with other accounts.
  Future<SignedInAccount> signIn() async {
    final response = await _authorize(buildAuthorizationRequest());
    final code = response.authorizationCode;
    final verifier = response.codeVerifier;
    if (code == null || code.isEmpty || verifier == null || verifier.isEmpty) {
      throw StateError('Authorization returned no code to exchange');
    }
    final tokens = await exchangeCode(code: code, codeVerifier: verifier);
    final account = await _resolveAccount(tokens);
    await tokenStore.save(account, tokens);
    return (account: account, tokens: tokens);
  }

  /// Resolves who just signed in (`GET /api/v4/user` with the new token), so
  /// storage can be namespaced per account rather than a global slot.
  Future<AccountKey> _resolveAccount(OAuthTokens tokens) async {
    final response = await _dio.get<Map<String, dynamic>>(
      config.tokenEndpoint.resolve('/api/v4/user').toString(),
      options: Options(
        headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
      ),
    );
    return AccountKey(
      instanceHost: config.tokenEndpoint.authority,
      accountId: (response.data!['id'] as num).toString(),
    );
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
    return OAuthTokens.fromTokenResponse(response.data!);
  }
}
