/// Ad-hoc web demo gallery: browse every built Gitsune screen with in-memory
/// sample data, no sign-in, no network, no database.
///
/// Not part of the app. Run with:
///
///     flutter run -d web-server --web-port 8099 -t lib/demo/gallery_main.dart
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/glass_demo/glass_demo_screen.dart';
import '../features/glass_demo/glass_overlays_demo_screen.dart';
import '../features/shell/app_shell.dart';
import 'demo_repositories.dart';

void main() => runApp(const DemoGalleryApp());

String _projectRoute(String subPath) => Uri(
  path: '/projects/7/$subPath',
  queryParameters: {'projectPath': 'gitsune/app'},
).toString();

class DemoGalleryApp extends StatelessWidget {
  const DemoGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitsune demo gallery',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _GalleryScreen(),
    );
  }
}

class _GalleryEntry {
  const _GalleryEntry(this.title, this.subtitle, this.body);

  final String title;
  final String subtitle;
  final Widget Function() body;
}

class _GalleryScreen extends StatelessWidget {
  const _GalleryScreen();

  static final List<_GalleryEntry> _entries = [
    _GalleryEntry(
      'App shell (four tabs)',
      'The real frame: Home, To-Dos, Explore (search), Profile',
      () => const _DemoAppHost(initialLocation: '/home'),
    ),
    _GalleryEntry(
      'Issues',
      'List, infinite scroll, tap a row for detail with markdown, '
          'labels, assignees, comments',
      () => _DemoAppHost(initialLocation: _projectRoute('issues')),
    ),
    _GalleryEntry(
      'Issue detail',
      'Straight to issue #142',
      () => _DemoAppHost(initialLocation: _projectRoute('issues/142')),
    ),
    _GalleryEntry(
      'Merge requests',
      'List, tap for detail: approvals, pipelines, merge, changes',
      () => _DemoAppHost(initialLocation: _projectRoute('merge_requests')),
    ),
    _GalleryEntry(
      'Merge request changes',
      'MR !142 diff review with syntax highlighting and discussions',
      () =>
          _DemoAppHost(initialLocation: _projectRoute('merge_requests/142')),
    ),
    _GalleryEntry(
      'Pipeline detail',
      'Pipeline #88123 stages and jobs; tap a job for its ANSI log',
      () => _DemoAppHost(initialLocation: _projectRoute('pipelines/88123')),
    ),
    _GalleryEntry(
      'Releases',
      'Release list and detail with downloadable assets',
      () => _DemoAppHost(initialLocation: _projectRoute('releases')),
    ),
    _GalleryEntry(
      'Code browser',
      'Repository tree drill-down and file view',
      () => _DemoAppHost(initialLocation: _projectRoute('tree')),
    ),
    _GalleryEntry(
      'To-Dos',
      'To-do list; tapping deep-links into issue, MR, and pipeline detail',
      () => const _DemoAppHost(initialLocation: '/todos'),
    ),
    _GalleryEntry(
      'Search (Explore tab)',
      'Type anything: projects, issues, MRs, and code results',
      () => const _DemoAppHost(initialLocation: '/explore'),
    ),
    _GalleryEntry(
      'Profile',
      'Profile tab (settings entries need real accounts, so most are '
          'inactive here)',
      () => const _DemoAppHost(initialLocation: '/profile'),
    ),
    _GalleryEntry(
      'Sign-in',
      'Visual only: the OAuth browser leg is native-only',
      () => const _DemoAppHost(initialLocation: '/signin'),
    ),
    _GalleryEntry(
      'Glass demo',
      'Liquid-glass spike: modest + heavy surfaces over a busy list',
      () => const _PhoneFrame(child: GlassDemoScreen()),
    ),
    _GalleryEntry(
      'Glass overlays demo',
      'Reusable heavy-glass overlay primitives',
      () => const _PhoneFrame(child: GlassOverlaysDemoScreen()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gitsune demo gallery')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Every built screen, fed by in-memory GitLab-shaped sample '
              'data. No network, no sign-in. Screens render in a '
              'phone-width frame.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final entry in _entries)
            ListTile(
              title: Text(entry.title),
              subtitle: Text(entry.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _GalleryPage(
                    title: entry.title,
                    child: entry.body(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A pushed gallery page: slim bar back to the menu, demo surface below.
class _GalleryPage extends StatelessWidget {
  const _GalleryPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        toolbarHeight: 44,
      ),
      body: child,
    );
  }
}

/// A full app instance (real router, real screens) over the demo
/// repositories, opened at [initialLocation].
class _DemoAppHost extends StatefulWidget {
  const _DemoAppHost({required this.initialLocation});

  final String initialLocation;

  @override
  State<_DemoAppHost> createState() => _DemoAppHostState();
}

class _DemoAppHostState extends State<_DemoAppHost> {
  late final GoRouter _router = buildAppRouter(
    issuesRepository: DemoIssuesRepository(),
    mergeRequestsRepository: DemoMergeRequestsRepository(),
    pipelinesRepository: DemoPipelinesRepository(),
    releasesRepository: DemoReleasesRepository(),
    repositoryTreeRepository: DemoRepositoryTreeRepository(),
    searchRepository: DemoSearchRepository(),
    todosRepository: DemoTodosRepository(),
    // There is no filesystem on web; the demo repository fakes the download,
    // and the screen catches a resolver failure with a snackbar anyway.
    resolveDownloadsDirectory: () async => Directory('gitsune-demo'),
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PhoneFrame(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}

/// Centers its child at phone width so screens keep their intended layout
/// in a desktop browser, and scopes MediaQuery.size to the frame.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
