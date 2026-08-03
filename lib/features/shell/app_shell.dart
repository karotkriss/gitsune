import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/repository/offline_first_repository.dart';
import '../../core/repository/recently_viewed_repository.dart';
import '../code/data/repository_tree_repository.dart';
import '../code/presentation/repository_tree_screen.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../home/home_tiles.dart';
import '../issues/data/issue_models.dart';
import '../issues/data/issues_repository.dart';
import '../issues/presentation/issue_detail_screen.dart';
import '../issues/presentation/issue_list_screen.dart';
import '../merge_requests/data/merge_request_models.dart';
import '../merge_requests/data/merge_requests_repository.dart';
import '../merge_requests/presentation/merge_request_changes_screen.dart';
import '../merge_requests/presentation/merge_request_detail_screen.dart';
import '../merge_requests/presentation/merge_request_list_screen.dart';
import '../pipelines/data/pipeline_models.dart';
import '../pipelines/data/pipelines_repository.dart';
import '../pipelines/presentation/job_log_screen.dart';
import '../pipelines/presentation/pipeline_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../search/data/search_repository.dart';
import '../search/presentation/search_screen.dart';
import '../sign_in/sign_in_screen.dart';
import '../todos/todos_screen.dart';

/// Builds the app router: four tab branches behind [AppShell], each keeping
/// its own navigation stack.
///
/// A fresh router per app instance (rather than a shared global) so app
/// restarts and tests never inherit a previous instance's location.
///
/// The optional feature repositories enable their project routes once the
/// account and project composition root owns a signed-in GitLab client.
/// Keeping those dependencies optional lets the shell boot before E2's account
/// wiring lands without hiding the route contracts exposed to project
/// navigation. [searchRepository] swaps the Explore tab's placeholder for the
/// real [SearchScreen], while [todosRepository] binds the To-Dos tab to its
/// offline-first cache stream and [homeTileOrderStore] persists the Home
/// tab's tile order per account. [recentlyViewedCache] lets the issue, merge
/// request, and pipeline detail screens serve recently viewed items offline.
GoRouter buildAppRouter({
  HomeTileOrderStore? homeTileOrderStore,
  IssuesRepository? issuesRepository,
  MergeRequestsRepository? mergeRequestsRepository,
  PipelinesRepository? pipelinesRepository,
  RepositoryTreeRepository? repositoryTreeRepository,
  SearchRepository? searchRepository,
  OfflineFirstRepository<List<TodoItem>>? todosRepository,
  RecentlyViewedCache? recentlyViewedCache,
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
                builder: (context, state) => HomeScreen(
                  tileOrderStore: homeTileOrderStore,
                  // Only the To-Do List has a global destination yet; the
                  // other tiles route once their sections land (E6+).
                  onTileTap: (tile) {
                    if (tile == HomeTile.todos) context.go('/todos');
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/todos',
                builder: (context, state) => todosRepository == null
                    ? const TodosScreen()
                    : TodosScreen(repository: todosRepository),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => searchRepository != null
                    ? SearchScreen(repository: searchRepository)
                    : const ExploreScreen(),
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
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
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
              recentlyViewedCache: recentlyViewedCache,
              initialIssue: state.extra is Issue ? state.extra! as Issue : null,
            );
          },
        ),
      ],
      if (repositoryTreeRepository != null)
        GoRoute(
          path: '/projects/:projectId/tree',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            final projectPath =
                state.uri.queryParameters['projectPath'] ??
                'Project $projectId';
            final ref = state.uri.queryParameters['ref'] ?? '';
            final path = state.uri.queryParameters['path'] ?? '';
            final history = state.extra is _RepositoryTreeRouteHistory
                ? state.extra! as _RepositoryTreeRouteHistory
                : const _RepositoryTreeRouteHistory();
            return RepositoryTreeScreen(
              projectId: projectId,
              projectPath: projectPath,
              ref: ref,
              path: path,
              repository: repositoryTreeRepository,
              onDirectoryTap: (entry) => context.push(
                Uri(
                  path: '/projects/$projectId/tree',
                  queryParameters: {
                    'projectPath': projectPath,
                    if (ref.isNotEmpty) 'ref': ref,
                    'path': entry.path,
                  },
                ).toString(),
                extra: _RepositoryTreeRouteHistory(
                  ancestorLevels: history.ancestorLevels + 1,
                ),
              ),
              // Each drill-down pushed one route, so jumping to an ancestor
              // pops one route per intervening directory level.
              onAncestorTap: (ancestorPath) {
                final levels = _treeDepth(path) - _treeDepth(ancestorPath);
                if (levels <= history.ancestorLevels) {
                  for (var level = 0; level < levels; level++) {
                    context.pop();
                  }
                } else {
                  context.push(
                    Uri(
                      path: '/projects/$projectId/tree',
                      queryParameters: {
                        'projectPath': projectPath,
                        if (ref.isNotEmpty) 'ref': ref,
                        if (ancestorPath.isNotEmpty) 'path': ancestorPath,
                      },
                    ).toString(),
                    extra: const _RepositoryTreeRouteHistory(),
                  );
                }
              },
            );
          },
        ),
      if (pipelinesRepository != null) ...[
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
              recentlyViewedCache: recentlyViewedCache,
              onJobTap: (pipeline, job) => context.push(
                Uri(
                  path: '/projects/$projectId/jobs/${job.id}/log',
                  queryParameters: {'ref': pipeline.ref},
                ).toString(),
                extra: job,
              ),
            );
          },
        ),
        GoRoute(
          path: '/projects/:projectId/jobs/:jobId/log',
          builder: (context, state) => JobLogScreen(
            projectId: int.parse(state.pathParameters['projectId']!),
            jobId: int.parse(state.pathParameters['jobId']!),
            repository: pipelinesRepository,
            job: state.extra is PipelineJob
                ? state.extra! as PipelineJob
                : null,
            ref: state.uri.queryParameters['ref'],
          ),
        ),
      ],
      if (mergeRequestsRepository != null) ...[
        GoRoute(
          path: '/projects/:projectId/merge_requests',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            final projectPath =
                state.uri.queryParameters['projectPath'] ??
                'Project $projectId';
            return MergeRequestListScreen(
              projectId: projectId,
              projectPath: projectPath,
              repository: mergeRequestsRepository,
              onMergeRequestTap: (mergeRequest) => context.push(
                Uri(
                  path:
                      '/projects/$projectId/merge_requests/'
                      '${mergeRequest.iid}',
                  queryParameters: {'projectPath': projectPath},
                ).toString(),
                extra: mergeRequest,
              ),
            );
          },
        ),
        GoRoute(
          path: '/projects/:projectId/merge_requests/:mergeIid',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            final projectPath =
                state.uri.queryParameters['projectPath'] ??
                'Project $projectId';
            return MergeRequestDetailScreen(
              projectId: projectId,
              projectPath: projectPath,
              mergeIid: int.parse(state.pathParameters['mergeIid']!),
              repository: mergeRequestsRepository,
              recentlyViewedCache: recentlyViewedCache,
              initialMergeRequest: state.extra is MergeRequest
                  ? state.extra! as MergeRequest
                  : null,
              onShowChanges: (mergeRequest) => context.push(
                Uri(
                  path:
                      '/projects/$projectId/merge_requests/'
                      '${mergeRequest.iid}/changes',
                  queryParameters: {'projectPath': projectPath},
                ).toString(),
                extra: mergeRequest,
              ),
            );
          },
        ),
        GoRoute(
          path: '/projects/:projectId/merge_requests/:mergeIid/changes',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            return MergeRequestChangesScreen(
              projectId: projectId,
              projectPath:
                  state.uri.queryParameters['projectPath'] ??
                  'Project $projectId',
              mergeIid: int.parse(state.pathParameters['mergeIid']!),
              repository: mergeRequestsRepository,
              webUrl: state.extra is MergeRequest
                  ? (state.extra! as MergeRequest).webUrl
                  : null,
            );
          },
        ),
      ],
    ],
  );
}

int _treeDepth(String path) => path.isEmpty ? 0 : path.split('/').length;

class _RepositoryTreeRouteHistory {
  const _RepositoryTreeRouteHistory({this.ancestorLevels = 0});

  final int ancestorLevels;
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
