import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'account_scope.dart';

part 'app_database.g.dart';

class MicrosecondDateTimeConverter extends TypeConverter<DateTime, int> {
  const MicrosecondDateTimeConverter();

  @override
  DateTime fromSql(int fromDb) => DateTime.fromMicrosecondsSinceEpoch(fromDb);

  @override
  int toSql(DateTime value) => value.microsecondsSinceEpoch;
}

/// The signed-in account registry (E2.6): one row per session, keyed by the
/// composite key, so accounts across instances coexist. [needsReauth] marks
/// a session whose token refresh the instance rejected; the row stays
/// registered so the switcher keeps listing it and re-authentication can be
/// scoped to just that account. See `core/auth/account_sessions.dart`.
class Accounts extends Table with AccountScoped {
  BoolColumn get needsReauth => boolean().withDefault(const Constant(false))();
  IntColumn get addedAt =>
      integer().map(const MicrosecondDateTimeConverter())();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId};
}

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
  IntColumn get projectId => integer().nullable()();
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

/// The bounded per-account cache of recently viewed items (issues, merge
/// requests, pipelines), keyed by item type plus project and item id.
/// [payload] is the item's API-shaped JSON and [lastViewedAt] drives
/// least-recently-viewed eviction. See
/// `core/repository/recently_viewed_repository.dart`.
class RecentlyViewedItems extends Table with AccountScoped {
  TextColumn get itemType => text()();
  IntColumn get projectId => integer()();
  IntColumn get itemId => integer()();
  TextColumn get payload => text()();
  DateTimeColumn get lastViewedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {
    instanceHost,
    accountId,
    itemType,
    projectId,
    itemId,
  };
}

/// Cached releases of a project (`GET /projects/:id/releases`), scoped per
/// account. [assetsJson] is the release's raw `assets` API object (sources
/// plus links) and [position] preserves GitLab's server-side ordering
/// (newest release first). See
/// `features/releases/data/releases_repository.dart`.
class ReleaseEntries extends Table with AccountScoped {
  IntColumn get projectId => integer()();
  TextColumn get tagName => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  DateTimeColumn get releasedAt => dateTime()();
  TextColumn get authorName => text().nullable()();
  TextColumn get assetsJson => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId, projectId, tagName};
}

/// Queued comment drafts awaiting send (the E14.2 offline outbox), scoped
/// per account. [draftId] is allocated transactionally after the greatest
/// persisted id and orders the queue.
/// [lastError] is null while the draft is queued for sending; a permanent
/// server rejection sets it (e.g. `HTTP 403`), which surfaces the draft as
/// failed and excludes it from further send attempts. See
/// `features/issues/data/comment_draft_queue.dart`.
class CommentDrafts extends Table with AccountScoped {
  IntColumn get draftId => integer()();
  IntColumn get projectId => integer()();
  IntColumn get issueIid => integer()();
  TextColumn get body => text()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get retryAfter => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId, draftId};
}

/// The persisted Home shortcut-tile order, one row per account holding the
/// comma-separated tile ids. See `features/home/home_tiles.dart`.
class HomeTileOrders extends Table with AccountScoped {
  TextColumn get tileOrder => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId};
}

/// The baseline background poller's per-account conditional-request state.
/// See `core/notifications/todos_poller.dart`.
class TodoPollStates extends Table with AccountScoped {
  TextColumn get etag => text().nullable()();
  TextColumn get seenTodoIds => text()();
  TextColumn get createdAtHighWater => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId};
}

/// One account's scheduled quiet hours (E12.2): while enabled and the local
/// time is inside the window, new-to-do notifications are suppressed. Bounds
/// are minutes since local midnight, and a start later than the end wraps
/// past midnight (e.g. 22:00-07:00). See
/// `core/notifications/quiet_hours.dart`.
class QuietHoursSettings extends Table with AccountScoped {
  BoolColumn get enabled => boolean()();
  IntColumn get startMinutes => integer()();
  IntColumn get endMinutes => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {instanceHost, accountId};
}

@DriftDatabase(
  tables: [
    Accounts,
    LocalCacheEntries,
    CurrentUserProfiles,
    PaginationCursors,
    TodoItems,
    RepositoryTreeEntries,
    RecentlyViewedItems,
    HomeTileOrders,
    ReleaseEntries,
    TodoPollStates,
    CommentDrafts,
    QuietHoursSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'gitsune'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 13;

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
      if (from < 6) {
        await migrator.createTable(recentlyViewedItems);
      }
      if (from < 7) {
        await migrator.createTable(homeTileOrders);
      }
      if (from < 8) {
        await migrator.createTable(releaseEntries);
      }
      if (from < 9) {
        await migrator.createTable(todoPollStates);
      }
      if (from < 10) {
        await migrator.createTable(commentDrafts);
      }
      if (from < 11) {
        await migrator.createTable(quietHoursSettings);
      }
      if (from < 12) {
        await migrator.createTable(accounts);
      }
      // Only databases that created todoItems before version 13 need the
      // column added; the `from < 4` createTable already used today's shape.
      if (from >= 4 && from < 13) {
        await migrator.addColumn(todoItems, todoItems.projectId);
      }
    },
  );
}
