import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/pagination_cursor_store.dart';

void main() {
  late AppDatabase db;
  late PaginationCursorStore store;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = PaginationCursorStore(db);
  });

  tearDown(() => db.close());

  const alice = AccountKey(instanceHost: 'gitlab.com', accountId: 'alice');
  const bob = AccountKey(instanceHost: 'gitlab.com', accountId: 'bob');

  test('reading an unsaved cursor returns null', () async {
    expect(await store.read(alice, 'projects'), isNull);
  });

  test('a saved cursor is read back', () async {
    await store.save(
      alice,
      'projects',
      'https://gitlab.com/api/v4/projects?cursor=abc',
    );

    expect(
      await store.read(alice, 'projects'),
      'https://gitlab.com/api/v4/projects?cursor=abc',
    );
  });

  test('saving again for the same account and collection overwrites', () async {
    await store.save(alice, 'projects', 'cursor-1');
    await store.save(alice, 'projects', 'cursor-2');

    expect(await store.read(alice, 'projects'), 'cursor-2');
  });

  test('clearing removes the cursor', () async {
    await store.save(alice, 'projects', 'cursor-1');
    await store.clear(alice, 'projects');

    expect(await store.read(alice, 'projects'), isNull);
  });

  test('two accounts on the same instance do not collide', () async {
    await store.save(alice, 'projects', 'alice-cursor');
    await store.save(bob, 'projects', 'bob-cursor');

    expect(await store.read(alice, 'projects'), 'alice-cursor');
    expect(await store.read(bob, 'projects'), 'bob-cursor');
  });

  test('two collections for the same account do not collide', () async {
    await store.save(alice, 'projects', 'projects-cursor');
    await store.save(alice, 'issues', 'issues-cursor');

    expect(await store.read(alice, 'projects'), 'projects-cursor');
    expect(await store.read(alice, 'issues'), 'issues-cursor');
  });
}
