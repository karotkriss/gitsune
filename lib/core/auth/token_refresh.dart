import 'package:dio/dio.dart';

import '../network/account_key.dart';
import '../network/gitlab_client.dart';
import 'oauth_config.dart';
import 'token_store.dart';

/// Lazy, on-demand token refresh (the `glab` model in
/// `docs/research/auth-blueprint.md`): no timers; the stored token's expiry
/// is re-checked each time a request needs one, and an expired or
/// near-expiry token is refreshed right then, reading the server's returned
/// expiry.
///
/// GitLab's refresh tokens are single-use and rotate on every refresh, so
/// concurrent requests for the same account must never each fire their own
/// refresh: the second one would spend an already-invalidated token. This
/// coordinator runs at most one refresh per account at a time (single
/// flight); concurrent callers await that one result.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator({
    required this.tokenStore,
    required this.configFor,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final TokenStore tokenStore;

  /// Resolves the OAuth endpoints and client ID for an account's instance.
  final GitLabOAuthConfig Function(AccountKey account) configFor;

  final Dio _dio;
  final _inFlight = <AccountKey, Future<String?>>{};

  /// Safety margin so a request never goes out with a token that expires
  /// mid-flight.
  static const expiryMargin = Duration(seconds: 30);

  /// `TokenReader` for `createGitLabClient`: the stored access token when it
  /// is still fresh, otherwise the result of an on-demand refresh.
  Future<TokenReadResult> readToken(AccountKey account) async {
    final tokens = await tokenStore.read(account);
    if (tokens == null) {
      return const TokenReadResult(null);
    }
    final expiresAt = tokens.expiresAt;
    final fresh =
        expiresAt == null ||
        DateTime.now().isBefore(expiresAt.subtract(expiryMargin));
    if (fresh || tokens.refreshToken == null) {
      // Without a refresh token an expired token can only be sent and let
      // the 401 surface as an auth failure.
      return TokenReadResult(tokens.accessToken);
    }
    return TokenReadResult(
      await refreshToken(account, tokens.accessToken),
      refreshAttempted: true,
    );
  }

  /// `TokenRefresher` for `createGitLabClient`. [rejectedAccessToken] is the
  /// token the caller found expired or got a 401 with; if the store already
  /// holds a newer one (a refresh completed while this caller was in
  /// flight), that token is returned without spending the single-use
  /// refresh token again.
  Future<String?> refreshToken(
    AccountKey account,
    String? rejectedAccessToken,
  ) => _inFlight[account] ??= _refresh(account, rejectedAccessToken)
      // Not an expression body: Map.remove returns the removed value, and a
      // Future returned from a whenComplete callback would be awaited - the
      // in-flight future waiting on itself.
      .whenComplete(() {
        _inFlight.remove(account);
      });

  Future<String?> _refresh(AccountKey account, String? rejected) async {
    final current = await tokenStore.read(account);
    final refreshToken = current?.refreshToken;
    if (current == null || refreshToken == null) {
      return null;
    }
    if (rejected != null && current.accessToken != rejected) {
      return current.accessToken;
    }

    final config = configFor(account);
    final Object? body;
    try {
      final response = await _dio.post<Object?>(
        config.tokenEndpoint.toString(),
        data: {
          'grant_type': 'refresh_token',
          'client_id': config.clientId,
          'refresh_token': refreshToken,
          'redirect_uri': oauthRedirectUri,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      body = response.data;
    } on DioException {
      // A failed refresh (revoked app, rotated credentials, expired SSO) is
      // an auth failure for this account; E2.6 marks it for re-auth.
      return null;
    }

    final tokens = _parseRefreshResponse(body);
    if (tokens == null) {
      return null;
    }
    // One save rotates access token, refresh token, and expiry atomically:
    // no window where the old refresh token is spent but the new one is not
    // yet stored.
    await tokenStore.save(account, tokens);
    return tokens.accessToken;
  }

  OAuthTokens? _parseRefreshResponse(Object? body) {
    if (body is! Map<String, dynamic>) {
      return null;
    }
    final accessToken = body['access_token'];
    final refreshToken = body['refresh_token'];
    final expiresIn = body['expires_in'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty ||
        expiresIn is! int ||
        expiresIn <= 0) {
      return null;
    }
    return OAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }
}
