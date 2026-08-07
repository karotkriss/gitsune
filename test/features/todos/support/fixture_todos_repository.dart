import 'dart:async';

import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/repository/offline_first_repository.dart';

class FixtureTodosRepository implements OfflineFirstRepository<List<TodoItem>> {
  FixtureTodosRepository([List<TodoItem>? initialTodos])
    : _todos = List.of(initialTodos ?? fixtureTodos());

  final _updates = StreamController<List<TodoItem>>.broadcast();
  List<TodoItem> _todos;
  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount += 1;
  }

  @override
  Stream<List<TodoItem>> watch() async* {
    yield List.unmodifiable(_todos);
    yield* _updates.stream;
  }

  void emit(List<TodoItem> todos) {
    _todos = List.of(todos);
    _updates.add(List.unmodifiable(_todos));
  }

  Future<void> dispose() => _updates.close();
}

List<TodoItem> fixtureTodos() => [
  fixtureTodo(
    id: 102,
    actionName: 'review_requested',
    targetType: 'MergeRequest',
    targetIid: 142,
    targetTitle: 'Add instance switcher sheet',
    body: 'Ade requested your review',
    createdAt: DateTime.utc(2026, 8, 1, 21),
  ),
  fixtureTodo(
    id: 101,
    actionName: 'assigned',
    targetType: 'Issue',
    targetIid: 233,
    targetTitle: 'Sign-in: PAT fallback hidden behind wrong affordance',
    body: 'Priya assigned you',
    createdAt: DateTime.utc(2026, 8, 1, 9),
  ),
  fixtureTodo(
    id: 88101,
    actionName: 'build_failed',
    targetType: 'Pipeline',
    body: 'Pipeline failed on main',
    createdAt: DateTime.utc(2026, 7, 31, 10),
  ),
];

TodoItem fixtureTodo({
  required int id,
  required String actionName,
  required String targetType,
  int? projectId = 1,
  int? targetIid,
  String? targetTitle,
  String? targetUrl,
  required String body,
  required DateTime createdAt,
}) {
  final targetPath = switch (targetType) {
    'MergeRequest' => 'merge_requests/${targetIid ?? id}',
    'Issue' => 'issues/${targetIid ?? id}',
    'Pipeline' => 'pipelines/$id',
    _ => 'todos/$id',
  };
  return TodoItem(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
    todoId: id,
    projectId: projectId,
    projectPathWithNamespace: 'gitsune/app',
    authorName: 'Fixture Author',
    authorUsername: 'fixture',
    actionName: actionName,
    targetType: targetType,
    targetIid: targetIid,
    targetTitle: targetTitle,
    targetUrl:
        targetUrl ?? 'https://gitlab.example.com/gitsune/app/-/$targetPath',
    body: body,
    state: 'pending',
    createdAt: createdAt,
  );
}
