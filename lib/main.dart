import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/database/app_database.dart';
import 'core/lock/app_lock.dart';
import 'core/lock/app_lock_gate.dart';
import 'core/repository/offline_first_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/issues/data/issues_repository.dart';
import 'features/shell/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: GitsuneApp()));
}

class GitsuneApp extends StatefulWidget {
  const GitsuneApp({
    super.key,
    this.appLockController,
    this.issuesRepository,
    this.todosRepository,
  });

  final AppLockController? appLockController;
  final IssuesRepository? issuesRepository;
  final OfflineFirstRepository<List<TodoItem>>? todosRepository;

  @override
  State<GitsuneApp> createState() => _GitsuneAppState();
}

class _GitsuneAppState extends State<GitsuneApp> {
  late final AppLockController _appLock =
      widget.appLockController ??
      AppLockController(authenticator: LocalAuthBiometricAuthenticator());
  late final GoRouter _router = buildAppRouter(
    appLockController: _appLock,
    issuesRepository: widget.issuesRepository,
    todosRepository: widget.todosRepository,
  );

  @override
  void initState() {
    super.initState();
    _appLock.load();
  }

  @override
  void dispose() {
    _router.dispose();
    if (widget.appLockController == null) _appLock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gitsune',
      theme: buildAppTheme(),
      routerConfig: _router,
      builder: (context, child) =>
          AppLockGate(controller: _appLock, child: child!),
    );
  }
}
