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

/// Cached current-user profiles, scoped to one row per account.
class CurrentUserProfiles extends Table with AccountScoped {
  TextColumn get username => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId};
}

/// The persisted resume token for one account's keyset-paginated collection
/// (e.g. `projects`), so an interrupted listing can resume across app
/// restarts. See `core/network/pagination_cursor_store.dart`.
class PaginationCursors extends Table with AccountScoped {
  TextColumn get collectionKey => text()();
  TextColumn get cursorUri => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId, collectionKey};
}

/// Cached to-dos from the Todos API (`GET /api/v4/todos`), scoped per
/// account. See `core/repository/todos_repository.dart`.
class TodoItems extends Table with AccountScoped {
  IntColumn get todoId => integer()();
  TextColumn get projectPathWithNamespace => text().nullable()();
  TextColumn get authorName => text()();
  TextColumn get authorUsername => text()();
  TextColumn get authorAvatarUrl => text().nullable()();
  TextColumn get actionName => text()();
  TextColumn get targetType => text()();
  IntColumn get targetIid => integer().nullable()();
  TextColumn get targetTitle => text().nullable()();
  TextColumn get targetUrl => text()();
  TextColumn get body => text()();
  TextColumn get state => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId, todoId};
}

/// Cached repository tree entries (`GET /projects/:id/repository/tree`),
/// one row per directory entry, scoped per account. [parentPath] is the
/// directory the entry lives in (`''` for the repository root) and
/// [position] preserves GitLab's server-side ordering (trees first,
/// alphabetical) within that directory. [ref] is the requested ref, `''`
/// when browsing the instance's default branch. See
/// `features/code/data/repository_tree_repository.dart`.
class RepositoryTreeEntries extends Table with AccountScoped {
  IntColumn get projectId => integer()();
  TextColumn get ref => text()();
  TextColumn get parentPath => text()();
  TextColumn get name => text()();
  TextColumn get path => text()();
  TextColumn get entryType => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {
    instanceHost,
    accountId,
    projectId,
    ref,
    parentPath,
    name,
  };
}

@DriftDatabase(
  tables: [
    LocalCacheEntries,
    CurrentUserProfiles,
    PaginationCursors,
    TodoItems,
    RepositoryTreeEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'gitsune'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, _) async {
      if (from < 2) {
        await migrator.createTable(currentUserProfiles);
      }
      if (from < 3) {
        await migrator.createTable(paginationCursors);
      }
      if (from < 4) {
        await migrator.createTable(todoItems);
      }
      if (from < 5) {
        await migrator.createTable(repositoryTreeEntries);
      }
    },
  );
}
