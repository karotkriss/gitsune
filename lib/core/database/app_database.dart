import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'account_scope.dart';

part 'app_database.g.dart';

/// A generic per-account local cache, scoped by [AccountScoped]. This is the
/// foundation layer's proof table: it demonstrates the scoping pattern that
/// later feature tables (E3.3+) follow, without owning any feature's data.
class LocalCacheEntries extends Table with AccountScoped {
  TextColumn get cacheKey => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId, cacheKey};
}

/// The current-user profile, one row per account: E3.3's concrete proof of
/// the offline-first repository pattern (see `lib/core/repository/`).
class CurrentUserProfiles extends Table with AccountScoped {
  TextColumn get username => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId};
}

@DriftDatabase(tables: [LocalCacheEntries, CurrentUserProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'gitsune'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, _) async {
      if (from < 2) {
        await migrator.createTable(currentUserProfiles);
      }
    },
  );
}
