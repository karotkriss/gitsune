import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/features/home/home_tiles.dart';

void main() {
  const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');

  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('emits the default order for an account with nothing stored', () async {
    final store = HomeTileOrderStore(database: database, account: account);

    expect(await store.watchOrder().first, HomeTile.values);
  });

  test('round-trips a saved order across store instances', () async {
    final store = HomeTileOrderStore(database: database, account: account);
    final reversed = HomeTile.values.reversed.toList();
    await store.saveOrder(reversed);

    final reopened = HomeTileOrderStore(database: database, account: account);
    expect(await reopened.watchOrder().first, reversed);
  });

  test('scopes the order per account', () async {
    const otherAccount = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: '2',
    );
    final store = HomeTileOrderStore(database: database, account: account);
    final otherStore = HomeTileOrderStore(
      database: database,
      account: otherAccount,
    );
    final reversed = HomeTile.values.reversed.toList();
    await store.saveOrder(reversed);

    expect(await store.watchOrder().first, reversed);
    expect(await otherStore.watchOrder().first, HomeTile.values);
  });

  test('drops unknown stored ids and appends missing tiles', () async {
    await database
        .into(database.homeTileOrders)
        .insert(
          HomeTileOrdersCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            tileOrder: 'todos,retiredTile,issues',
            updatedAt: DateTime.utc(2026, 8, 3),
          ),
        );
    final store = HomeTileOrderStore(database: database, account: account);

    expect(await store.watchOrder().first, [
      HomeTile.todos,
      HomeTile.issues,
      HomeTile.mergeRequests,
      HomeTile.pipelines,
      HomeTile.projects,
      HomeTile.groups,
    ]);
  });
}
