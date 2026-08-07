import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/network/account_key.dart';

import '../../support/memory_secure_storage.dart';

void main() {
  const alice = AccountKey(instanceHost: 'gitlab.com', accountId: '1');

  test('starts null and stays null loading an empty store', () async {
    final store = ActiveAccountStore(storage: MemorySecureStorage());
    await store.load();
    expect(store.value, isNull);
  });

  test('setActive persists across store instances', () async {
    final storage = MemorySecureStorage();
    await ActiveAccountStore(storage: storage).setActive(alice);

    final reloaded = ActiveAccountStore(storage: storage);
    await reloaded.load();
    expect(reloaded.value, alice);
  });

  test('setActive(null) clears the persisted choice', () async {
    final storage = MemorySecureStorage();
    final store = ActiveAccountStore(storage: storage);
    await store.setActive(alice);
    await store.setActive(null);

    expect(store.value, isNull);
    final reloaded = ActiveAccountStore(storage: storage);
    await reloaded.load();
    expect(reloaded.value, isNull);
  });

  test('a corrupt persisted value loads as null instead of failing', () async {
    final storage = MemorySecureStorage();
    storage.values['gitsune.activeAccount'] = 'not json';
    final store = ActiveAccountStore(storage: storage);
    await store.load();
    expect(store.value, isNull);
  });

  test('switching is a single state change', () async {
    final store = ActiveAccountStore(storage: MemorySecureStorage());
    var notifications = 0;
    store.addListener(() => notifications++);

    await store.setActive(alice);

    expect(store.value, alice);
    expect(notifications, 1);
  });
}
