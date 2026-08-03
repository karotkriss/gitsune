import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/database/app_database.dart';
import 'core/repository/offline_first_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/issues/data/issues_repository.dart';
import 'features/shell/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: GitsuneApp()));
}

class GitsuneApp extends StatefulWidget {
  const GitsuneApp({super.key, this.issuesRepository, this.todosRepository});

  final IssuesRepository? issuesRepository;
  final OfflineFirstRepository<List<TodoItem>>? todosRepository;

  @override
  State<GitsuneApp> createState() => _GitsuneAppState();
}

class _GitsuneAppState extends State<GitsuneApp> {
  late final GoRouter _router = buildAppRouter(
    issuesRepository: widget.issuesRepository,
    todosRepository: widget.todosRepository,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gitsune',
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
