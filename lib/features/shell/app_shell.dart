import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/gs_icons.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../todos/todos_screen.dart';

/// Builds the app router: four tab branches behind [AppShell], each keeping
/// its own navigation stack.
///
/// A fresh router per app instance (rather than a shared global) so app
/// restarts and tests never inherit a previous instance's location.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/home',
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
