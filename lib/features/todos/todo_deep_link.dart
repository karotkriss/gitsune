import '../../core/database/app_database.dart';

/// The single E5.3 target-resolution mapping: a to-do's underlying item to
/// its in-app route location, or `null` when no in-app surface exists yet
/// (epics, designs, wiki, ...) and the caller should open
/// [TodoItem.targetUrl] in the browser instead.
String? todoRouteLocation(TodoItem todo) {
  final projectId = todo.projectId;
  if (projectId == null) return null;
  final path = switch (todo.targetType) {
    'Issue' when todo.targetIid != null =>
      '/projects/$projectId/issues/${todo.targetIid}',
    'MergeRequest' when todo.targetIid != null =>
      '/projects/$projectId/merge_requests/${todo.targetIid}',
    // Pipeline to-dos carry no usable target iid (the pipeline route and web
    // URL both use the global pipeline id), so resolve it from the URL.
    'Pipeline' => switch (trailingUrlId(todo.targetUrl)) {
      null => null,
      final pipelineId => '/projects/$projectId/pipelines/$pipelineId',
    },
    _ => null,
  };
  if (path == null) return null;
  final projectPath = todo.projectPathWithNamespace;
  return Uri(
    path: path,
    queryParameters: projectPath == null ? null : {'projectPath': projectPath},
  ).toString();
}

/// The trailing numeric path segment of [url], if any.
int? trailingUrlId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.pathSegments.isEmpty) return null;
  return int.tryParse(uri.pathSegments.last);
}
