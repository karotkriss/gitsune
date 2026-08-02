import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('same instance, different accounts do not collide', () async {
    const instance = 'gitlab.com';
    final now = DateTime.now();

    await db
        .into(db.localCacheEntries)
        .insert(
          LocalCacheEntriesCompanion.insert(
            instanceHost: instance,
            accountId: 'alice',
            cacheKey: 'todo-count',
            value: '3',
            updatedAt: now,
          ),
        );
    await db
        .into(db.localCacheEntries)
        .insert(
          LocalCacheEntriesCompanion.insert(
            instanceHost: instance,
            accountId: 'bob',
            cacheKey: 'todo-count',
            value: '7',
            updatedAt: now,
          ),
        );

    final rows = await db.select(db.localCacheEntries).get();
    expect(rows, hasLength(2));

    final alice = rows.singleWhere((r) => r.accountId == 'alice');
    final bob = rows.singleWhere((r) => r.accountId == 'bob');
    expect(alice.value, '3');
    expect(bob.value, '7');
  });

  test('different instances, same username do not collide', () async {
    final now = DateTime.now();

    await db
        .into(db.localCacheEntries)
        .insert(
          LocalCacheEntriesCompanion.insert(
            instanceHost: 'gitlab.com',
            accountId: 'alice',
            cacheKey: 'todo-count',
            value: '3',
            updatedAt: now,
          ),
        );
    await db
        .into(db.localCacheEntries)
        .insert(
          LocalCacheEntriesCompanion.insert(
            instanceHost: 'gitlab.example.com',
            accountId: 'alice',
            cacheKey: 'todo-count',
            value: '99',
            updatedAt: now,
          ),
        );

    final rows = await db.select(db.localCacheEntries).get();
    expect(rows, hasLength(2));

    final dotCom = rows.singleWhere((r) => r.instanceHost == 'gitlab.com');
    final selfHosted = rows.singleWhere(
      (r) => r.instanceHost == 'gitlab.example.com',
    );
    expect(dotCom.value, '3');
    expect(selfHosted.value, '99');
  });

  test('the composite key is instanceHost + accountId + cacheKey', () {
    expect(db.localCacheEntries.primaryKey, {
      db.localCacheEntries.instanceHost,
      db.localCacheEntries.accountId,
      db.localCacheEntries.cacheKey,
    });
  });
}
