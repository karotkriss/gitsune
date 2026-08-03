import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// One signed-in session's OAuth tokens as returned by the token endpoint.
class OAuthTokens {
  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  /// Decodes a value produced by [encode]; throws [FormatException] if the
  /// stored value is not a valid encoding.
  factory OAuthTokens.decode(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> || decoded['accessToken'] is! String) {
      throw const FormatException('Malformed stored OAuth tokens');
    }
    final expiresAt = decoded['expiresAt'];
    return OAuthTokens(
      accessToken: decoded['accessToken'] as String,
      refreshToken: decoded['refreshToken'] as String?,
      expiresAt: expiresAt is String ? DateTime.parse(expiresAt) : null,
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

/// Where a session's tokens live. E2.5 extends this seam with per-account
/// namespacing and rotating refresh; E2.1 needs only save/read/clear.
abstract interface class TokenStore {
  Future<void> save(OAuthTokens tokens);
  Future<OAuthTokens?> read();
  Future<void> clear();
}

/// [TokenStore] backed by the platform's Keychain/Keystore secure storage.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({this._storage = const FlutterSecureStorage()});

  final FlutterSecureStorage _storage;

  // ponytail: one fixed key holds the single signed-in session; E2.5
  // namespaces keys per AccountKey for multi-account.
  static const _key = 'gitsune.oauth.tokens';

  @override
  Future<void> save(OAuthTokens tokens) =>
      _storage.write(key: _key, value: tokens.encode());

  @override
  Future<OAuthTokens?> read() async {
    final raw = await _storage.read(key: _key);
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
  Future<void> clear() => _storage.delete(key: _key);
}
