import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/gs_icons.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../issues/data/issue_models.dart';
import '../issues/data/issues_repository.dart';
import '../issues/presentation/issue_detail_screen.dart';
import '../issues/presentation/issue_list_screen.dart';
import '../pipelines/data/pipelines_repository.dart';
import '../pipelines/presentation/pipeline_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../todos/todos_screen.dart';

/// Builds the app router: four tab branches behind [AppShell], each keeping
/// its own navigation stack.
///
/// A fresh router per app instance (rather than a shared global) so app
/// restarts and tests never inherit a previous instance's location.
///
/// [issuesRepository] and [pipelinesRepository] enable their project routes
/// once the account and project composition root owns a signed-in GitLab
/// client. Keeping those dependencies optional lets the shell boot before E2's
/// account wiring lands without hiding the route contracts exposed to project
/// navigation.
GoRouter buildAppRouter({
  IssuesRepository? issuesRepository,
  PipelinesRepository? pipelinesRepository,
  String initialLocation = '/home',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/todos',
                builder: (context, state) => const TodosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      if (issuesRepository != null) ...[
        GoRoute(
          path: '/projects/:projectId/issues',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            final projectPath =
                state.uri.queryParameters['projectPath'] ??
                'Project $projectId';
            return IssueListScreen(
              projectId: projectId,
              projectPath: projectPath,
              repository: issuesRepository,
              onIssueTap: (issue) => context.push(
                Uri(
                  path: '/projects/$projectId/issues/${issue.iid}',
                  queryParameters: {'projectPath': projectPath},
                ).toString(),
                extra: issue,
              ),
            );
          },
        ),
        GoRoute(
          path: '/projects/:projectId/issues/:issueIid',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            final projectPath =
                state.uri.queryParameters['projectPath'] ??
                'Project $projectId';
            return IssueDetailScreen(
              projectId: projectId,
              projectPath: projectPath,
              issueIid: int.parse(state.pathParameters['issueIid']!),
              repository: issuesRepository,
              initialIssue: state.extra is Issue ? state.extra! as Issue : null,
            );
          },
        ),
      ],
      if (pipelinesRepository != null)
        GoRoute(
          path: '/projects/:projectId/pipelines/:pipelineId',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            final pipelineId = int.parse(state.pathParameters['pipelineId']!);
            final projectPath =
                state.uri.queryParameters['projectPath'] ??
                'Project $projectId';
            return PipelineDetailScreen(
              projectId: projectId,
              projectPath: projectPath,
              pipelineId: pipelineId,
              repository: pipelinesRepository,
            );
          },
        ),
    ],
  );
}

/// The app shell: the design direction's four-destination bottom tab bar
/// (Home, To-Dos/Notifications, Explore/Search, Profile) around the active
/// branch. Styling comes from `navigationBarTheme` in the token layer.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(icon: GsIcon(GsIconGlyph.home), label: 'Home'),
          NavigationDestination(
            icon: GsIcon(GsIconGlyph.todoDone),
            label: 'To-Dos',
          ),
          NavigationDestination(
            icon: GsIcon(GsIconGlyph.compass),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: GsIcon(GsIconGlyph.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
