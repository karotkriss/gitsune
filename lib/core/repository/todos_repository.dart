import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import '../network/keyset_paginator.dart';
import 'offline_first_repository.dart';

/// The to-dos repository on GitLab's Todos API (`GET /api/v4/todos`),
/// account-scoped and paginated across the whole collection on every [refresh]
/// by reusing the E3.4 paginator's `Link` header traversal.
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
  Future<void> _refreshQueue = Future<void>.value();

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

  /// Replaces the cache from GitLab's offset-paginated Todos endpoint.
  ///
  /// A server-side insertion or removal between page fetches can repeat or skip
  /// a row. Repeated IDs are collapsed; skipped rows wait for the next resync.
  @override
  Future<void> refresh() {
    final refresh = _refreshQueue.then((_) => _performRefresh());
    _refreshQueue = refresh.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return refresh;
  }

  Future<void> _performRefresh() async {
    final paginator = KeysetPaginator<TodoItemsCompanion>(
      dio: client,
      initialUri: _todosListUri(client),
      decode: (json) => _decodeTodo(json, account),
    );

    final rowsById = <int, TodoItemsCompanion>{};
    try {
      while (paginator.hasMore) {
        final page = await paginator.loadNext();
        for (final row in page.items) {
          rowsById[row.todoId.value] = row;
        }
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
        (batch) => batch.insertAll(database.todoItems, rowsById.values),
      );
    });
  }
}

Uri _todosListUri(Dio client) {
  final base = Uri.parse(client.options.baseUrl);
  final path = base.path.endsWith('/')
      ? '${base.path}todos'
      : '${base.path}/todos';
  return base.replace(
    path: path,
    queryParameters: {'page': '1', 'per_page': '100'},
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
