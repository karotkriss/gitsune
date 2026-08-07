import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';

void main() {
  test('upgrades a version 1 database without losing cached data', () async {
    final directory = await Directory.systemTemp.createTemp(
      'gitsune-migration-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final databaseFile = File('${directory.path}/gitsune.sqlite');

    final database = AppDatabase.forTesting(
      NativeDatabase(
        databaseFile,
        setup: (database) {
          database.execute('''
            CREATE TABLE local_cache_entries (
              instance_host TEXT NOT NULL,
              account_id TEXT NOT NULL,
              cache_key TEXT NOT NULL,
              value TEXT NOT NULL,
              updated_at INTEGER NOT NULL,
              PRIMARY KEY (instance_host, account_id, cache_key)
            )
          ''');
          database.execute(
            'INSERT INTO local_cache_entries '
            '(instance_host, account_id, cache_key, value, updated_at) '
            'VALUES (?, ?, ?, ?, ?)',
            ['gitlab.example.com', 'alice', 'todo-count', '3', 1],
          );
          database.userVersion = 1;
        },
      ),
    );
    addTearDown(database.close);

    final cachedEntries = await database
        .select(database.localCacheEntries)
        .get();
    expect(cachedEntries.single.value, '3');

    await database
        .into(database.currentUserProfiles)
        .insert(
          CurrentUserProfilesCompanion.insert(
            instanceHost: 'gitlab.example.com',
            accountId: 'alice',
            username: 'alice',
            name: 'Alice',
            updatedAt: DateTime.fromMillisecondsSinceEpoch(1),
          ),
        );
    expect(
      await database.select(database.currentUserProfiles).get(),
      hasLength(1),
    );

    await database
        .into(database.todoItems)
        .insert(
          TodoItemsCompanion.insert(
            instanceHost: 'gitlab.example.com',
            accountId: 'alice',
            todoId: 42,
            authorName: 'Alice',
            authorUsername: 'alice',
            actionName: 'assigned',
            targetType: 'Issue',
            targetUrl: 'https://gitlab.example.com/group/app/-/issues/42',
            body: 'Migrated to-do table is writable',
            state: 'pending',
            createdAt: DateTime.utc(2026, 8, 2),
          ),
        );
    expect(await database.select(database.todoItems).get(), hasLength(1));
  });

  test('upgrades version 9 database with comment draft queue', () async {
    final directory = await Directory.systemTemp.createTemp(
      'gitsune-comment-draft-migration-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final databaseFile = File('${directory.path}/gitsune.sqlite');

    final database = AppDatabase.forTesting(
      NativeDatabase(
        databaseFile,
        setup: (database) {
          database.execute('''
            CREATE TABLE todo_poll_states (
              instance_host TEXT NOT NULL,
              account_id TEXT NOT NULL,
              etag TEXT NULL,
              seen_todo_ids TEXT NOT NULL,
              created_at_high_water TEXT NULL,
              updated_at INTEGER NOT NULL,
              PRIMARY KEY (instance_host, account_id)
            )
          ''');
          database.execute('''
            CREATE TABLE todo_items (
              instance_host TEXT NOT NULL,
              account_id TEXT NOT NULL,
              todo_id INTEGER NOT NULL,
              project_path_with_namespace TEXT NULL,
              author_name TEXT NOT NULL,
              author_username TEXT NOT NULL,
              author_avatar_url TEXT NULL,
              action_name TEXT NOT NULL,
              target_type TEXT NOT NULL,
              target_iid INTEGER NULL,
              target_title TEXT NULL,
              target_url TEXT NOT NULL,
              body TEXT NOT NULL,
              state TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              PRIMARY KEY (instance_host, account_id, todo_id)
            )
          ''');
          database.userVersion = 9;
        },
      ),
    );
    addTearDown(database.close);

    await database
        .into(database.commentDrafts)
        .insert(
          CommentDraftsCompanion.insert(
            instanceHost: 'gitlab.example.com',
            accountId: '1',
            draftId: 42,
            projectId: 7,
            issueIid: 142,
            body: 'Still queued',
          ),
        );
    final draft = (await database.select(database.commentDrafts).get()).single;
    expect(draft.body, 'Still queued');
    expect(draft.retryAfter, isNull);

    // Version 13 added the project id column to the pre-existing to-do table.
    await database
        .into(database.todoItems)
        .insert(
          TodoItemsCompanion.insert(
            instanceHost: 'gitlab.example.com',
            accountId: '1',
            todoId: 7,
            projectId: const Value(7),
            authorName: 'Alice',
            authorUsername: 'alice',
            actionName: 'assigned',
            targetType: 'Issue',
            targetUrl: 'https://gitlab.example.com/group/app/-/issues/7',
            body: 'Deep-linkable to-do',
            state: 'pending',
            createdAt: DateTime.utc(2026, 8, 7),
          ),
        );
    final todo = (await database.select(database.todoItems).get()).single;
    expect(todo.projectId, 7);
  });
}
