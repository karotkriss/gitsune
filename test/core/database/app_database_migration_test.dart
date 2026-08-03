import 'dart:io';

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

  test('upgrades version 9 comment drafts with delivery state', () async {
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
            CREATE TABLE comment_drafts (
              instance_host TEXT NOT NULL,
              account_id TEXT NOT NULL,
              draft_id INTEGER NOT NULL,
              project_id INTEGER NOT NULL,
              issue_iid INTEGER NOT NULL,
              body TEXT NOT NULL,
              last_error TEXT NULL,
              PRIMARY KEY (instance_host, account_id, draft_id)
            )
          ''');
          database.execute('''
            INSERT INTO comment_drafts
              (instance_host, account_id, draft_id, project_id, issue_iid, body)
            VALUES ('gitlab.example.com', '1', 42, 7, 142, 'Still queued')
          ''');
          database.userVersion = 9;
        },
      ),
    );
    addTearDown(database.close);

    final draft = (await database.select(database.commentDrafts).get()).single;
    expect(draft.body, 'Still queued');
    expect(draft.retryAfter, isNull);
  });
}
