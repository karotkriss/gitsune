import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/token_store.dart';

/// In-memory [FlutterSecureStorage] so the store's real encode/decode path
/// runs without platform channels.
class _MemorySecureStorage extends FlutterSecureStorage {
  final values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}

void main() {
  test('saved tokens survive a round-trip through secure storage', () async {
    final storage = _MemorySecureStorage();
    final store = SecureTokenStore(storage: storage);
    final expiresAt = DateTime.utc(2026, 8, 3, 12);

    await store.save(
      OAuthTokens(
        accessToken: 'at-1',
        refreshToken: 'rt-1',
        expiresAt: expiresAt,
      ),
    );

    final read = await store.read();
    expect(read?.accessToken, 'at-1');
    expect(read?.refreshToken, 'rt-1');
    expect(read?.expiresAt, expiresAt);
    expect(storage.values, hasLength(1));
  });

  test('null optional fields round-trip as null', () async {
    final store = SecureTokenStore(storage: _MemorySecureStorage());
    await store.save(const OAuthTokens(accessToken: 'at-only'));

    final read = await store.read();
    expect(read?.accessToken, 'at-only');
    expect(read?.refreshToken, isNull);
    expect(read?.expiresAt, isNull);
  });

  test('an empty store reads as signed out', () async {
    expect(await SecureTokenStore(storage: _MemorySecureStorage()).read(),
        isNull);
  });

  test('a corrupt stored entry reads as signed out, not a crash', () async {
    final storage = _MemorySecureStorage();
    storage.values['gitsune.oauth.tokens'] = 'not json';
    expect(await SecureTokenStore(storage: storage).read(), isNull);

    storage.values['gitsune.oauth.tokens'] = '{"wrong": "shape"}';
    expect(await SecureTokenStore(storage: storage).read(), isNull);
  });

  test('clear removes the stored session', () async {
    final storage = _MemorySecureStorage();
    final store = SecureTokenStore(storage: storage);
    await store.save(const OAuthTokens(accessToken: 'at-1'));
    await store.clear();
    expect(await store.read(), isNull);
    expect(storage.values, isEmpty);
  });
}
