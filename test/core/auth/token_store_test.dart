import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/network/account_key.dart';

import '../../support/memory_secure_storage.dart';

void main() {
  const alice = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
  const bob = AccountKey(instanceHost: 'gitlab.com', accountId: '2');
  const aliceElsewhere = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: '1',
  );

  test('saved tokens survive a round-trip through secure storage', () async {
    final storage = MemorySecureStorage();
    final store = SecureTokenStore(storage: storage);
    final expiresAt = DateTime.utc(2026, 8, 3, 12);

    await store.save(
      alice,
      OAuthTokens(
        accessToken: 'at-1',
        refreshToken: 'rt-1',
        expiresAt: expiresAt,
      ),
    );

    final read = await store.read(alice);
    expect(read?.accessToken, 'at-1');
    expect(read?.refreshToken, 'rt-1');
    expect(read?.expiresAt, expiresAt);
    expect(storage.values, hasLength(1));
  });

  test('accounts are namespaced by the composite key: same instance, '
      'different account, and same account id on another instance all '
      'coexist', () async {
    final storage = MemorySecureStorage();
    final store = SecureTokenStore(storage: storage);

    await store.save(alice, const OAuthTokens(accessToken: 'at-alice'));
    await store.save(bob, const OAuthTokens(accessToken: 'at-bob'));
    await store.save(
      aliceElsewhere,
      const OAuthTokens(accessToken: 'at-alice-elsewhere'),
    );

    expect(storage.values, hasLength(3));
    expect((await store.read(alice))?.accessToken, 'at-alice');
    expect((await store.read(bob))?.accessToken, 'at-bob');
    expect(
      (await store.read(aliceElsewhere))?.accessToken,
      'at-alice-elsewhere',
    );
  });

  test('clear removes only that account, leaving the others signed in',
      () async {
    final storage = MemorySecureStorage();
    final store = SecureTokenStore(storage: storage);
    await store.save(alice, const OAuthTokens(accessToken: 'at-alice'));
    await store.save(bob, const OAuthTokens(accessToken: 'at-bob'));

    await store.clear(alice);

    expect(await store.read(alice), isNull);
    expect((await store.read(bob))?.accessToken, 'at-bob');
  });

  test('null optional fields round-trip as null', () async {
    final store = SecureTokenStore(storage: MemorySecureStorage());
    await store.save(alice, const OAuthTokens(accessToken: 'at-only'));

    final read = await store.read(alice);
    expect(read?.accessToken, 'at-only');
    expect(read?.refreshToken, isNull);
    expect(read?.expiresAt, isNull);
  });

  test('an empty store reads as signed out', () async {
    expect(
      await SecureTokenStore(storage: MemorySecureStorage()).read(alice),
      isNull,
    );
  });

  test('a corrupt stored entry reads as signed out, not a crash', () async {
    final storage = MemorySecureStorage();
    const key = 'gitsune.oauth.tokens.gitlab.com/1';

    storage.values[key] = 'not json';
    expect(await SecureTokenStore(storage: storage).read(alice), isNull);

    storage.values[key] = '{"wrong": "shape"}';
    expect(await SecureTokenStore(storage: storage).read(alice), isNull);
  });

  test('wrong-typed stored token fields read as signed out', () async {
    final storage = MemorySecureStorage();
    const key = 'gitsune.oauth.tokens.gitlab.com/1';

    storage.values[key] =
        '{"accessToken":"at","refreshToken":7,"expiresAt":null}';
    expect(await SecureTokenStore(storage: storage).read(alice), isNull);

    storage.values[key] =
        '{"accessToken":"at","refreshToken":null,"expiresAt":7}';
    expect(await SecureTokenStore(storage: storage).read(alice), isNull);
  });
}
