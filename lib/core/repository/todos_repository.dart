import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import '../network/keyset_paginator.dart';
import 'offline_first_repository.dart';

/// The to-dos repository on GitLab's Todos API (`GET /api/v4/todos`),
/// account-scoped and keyset-paginated (E3.4) across the whole collection on
/// every [refresh].
///
/// [watch] is the reactive stream that phase five's background poller
/// (E12.1) will also read from to decide what's new since its last poll;
/// this repository only establishes that stream and its [refresh] entry
/// point for reuse, the poller itself (scheduling, conditional requests,
/// notifications) is out of scope here.
class TodosRepository implements OfflineFirstRepository<List<TodoItem>> {
  TodosRepository({
    required this.database,
    required this.client,
    required this.account,
  });

  final AppDatabase database;
  final Dio client;
  final AccountKey account;

  @override
  Stream<List<TodoItem>> watch() {
    final query = database.select(database.todoItems)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  @override
  Future<void> refresh() async {
    final paginator = KeysetPaginator<TodoItemsCompanion>(
      dio: client,
      initialUri: _todosListUri(client),
      decode: (json) => _decodeTodo(json, account),
    );

    final rows = <TodoItemsCompanion>[];
    try {
      while (paginator.hasMore) {
        final page = await paginator.loadNext();
        rows.addAll(page.items);
      }
    } on DioException {
      return;
    }

    await database.transaction(() async {
      await (database.delete(database.todoItems)..where(
            (t) =>
                t.instanceHost.equals(account.instanceHost) &
                t.accountId.equals(account.accountId),
          ))
          .go();
      await database.batch(
        (batch) => batch.insertAll(database.todoItems, rows),
      );
    });
  }
}

Uri _todosListUri(Dio client) {
  final base = Uri.parse(client.options.baseUrl);
  final path = base.path.endsWith('/') ? '${base.path}todos' : '${base.path}/todos';
  return base.replace(
    path: path,
    queryParameters: {
      'pagination': 'keyset',
      'per_page': '100',
      'order_by': 'id',
      'sort': 'desc',
    },
  );
}

TodoItemsCompanion _decodeTodo(Map<String, dynamic> json, AccountKey account) {
  final project = json['project'] as Map<String, dynamic>?;
  final group = json['group'] as Map<String, dynamic>?;
  final author = json['author'] as Map<String, dynamic>?;
  final target = json['target'] as Map<String, dynamic>?;
  return TodoItemsCompanion.insert(
    instanceHost: account.instanceHost,
    accountId: account.accountId,
    todoId: json['id'] as int,
    projectPathWithNamespace: Value(
      project?['path_with_namespace'] as String? ??
          group?['full_path'] as String?,
    ),
    authorName: author?['name'] as String? ?? '',
    authorUsername: author?['username'] as String? ?? '',
    authorAvatarUrl: Value(author?['avatar_url'] as String?),
    actionName: json['action_name'] as String,
    targetType: json['target_type'] as String,
    targetIid: Value(target?['iid'] as int?),
    targetTitle: Value(target?['title'] as String?),
    targetUrl: json['target_url'] as String,
    body: json['body'] as String? ?? '',
    state: json['state'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
