import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/account_key.dart';

/// One signed-in session's stored access credentials.
///
/// OAuth sessions include the refresh token and expiry returned by the token
/// endpoint. PAT sessions use the PAT as [accessToken] and leave both optional
/// fields null so they never enter the OAuth refresh flow.
class OAuthTokens {
  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  /// Parses a token-endpoint response body, computing [expiresAt] from the
  /// server's `expires_in` at receipt time (never a hardcoded lifetime).
  factory OAuthTokens.fromTokenResponse(Map<String, dynamic> body) {
    final expiresIn = body['expires_in'];
    return OAuthTokens(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String?,
      expiresAt: expiresIn is int
          ? DateTime.now().add(Duration(seconds: expiresIn))
          : null,
    );
  }

  /// Decodes a value produced by [encode]; throws [FormatException] if the
  /// stored value is not a valid encoding.
  factory OAuthTokens.decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Malformed stored OAuth tokens');
    }

    final accessToken = decoded['accessToken'];
    final refreshToken = decoded['refreshToken'];
    final expiresAt = decoded['expiresAt'];
    if (accessToken is! String ||
        refreshToken != null && refreshToken is! String ||
        expiresAt != null && expiresAt is! String) {
      throw const FormatException('Malformed stored OAuth tokens');
    }

    final parsedExpiresAt = expiresAt == null
        ? null
        : DateTime.tryParse(expiresAt);
    if (expiresAt != null && parsedExpiresAt == null) {
      throw const FormatException('Malformed stored OAuth tokens');
    }

    return OAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken as String?,
      expiresAt: parsedExpiresAt,
    );
  }

  final String accessToken;
  final String? refreshToken;

  /// When the access token expires, computed from the server's `expires_in`
  /// at receipt time (never a hardcoded lifetime); null if the server sent
  /// no expiry.
  final DateTime? expiresAt;

  String encode() => jsonEncode({
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt?.toIso8601String(),
  });
}

/// Where sessions' tokens live, namespaced per account by the composite key
/// (`instanceHost` + `accountId`, the same scoping as
/// `core/database/account_scope.dart`) so multiple accounts and instances
/// coexist without collision.
abstract interface class TokenStore {
  Future<void> save(AccountKey account, OAuthTokens tokens);
  Future<OAuthTokens?> read(AccountKey account);
  Future<void> clear(AccountKey account);
}

/// [TokenStore] backed by the platform's Keychain/Keystore secure storage.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({this._storage = const FlutterSecureStorage()});

  final FlutterSecureStorage _storage;

  // Hosts cannot contain '/', so keys are collision-free across accounts.
  static String _key(AccountKey account) =>
      'gitsune.oauth.tokens.${account.instanceHost}/${account.accountId}';

  /// One write persists access token, refresh token, and expiry together as
  /// a single value, so a rotation can never strand a half-updated pair.
  @override
  Future<void> save(AccountKey account, OAuthTokens tokens) =>
      _storage.write(key: _key(account), value: tokens.encode());

  @override
  Future<OAuthTokens?> read(AccountKey account) async {
    final raw = await _storage.read(key: _key(account));
    if (raw == null) {
      return null;
    }
    try {
      return OAuthTokens.decode(raw);
    } on FormatException {
      // A corrupt entry means signed out, not crashed.
      return null;
    }
  }

  @override
  Future<void> clear(AccountKey account) => _storage.delete(key: _key(account));
}
