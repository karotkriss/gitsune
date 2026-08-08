// Store-listing screenshot generator (E15.5).
//
// Renders real app screens (the same screens and fixture repositories the
// golden tests use) at each store's required pixel dimensions and writes the
// PNGs into `store/screenshots/`. Run it explicitly; it lives outside `test/`
// so the normal suite never runs it and `test/flutter_test_config.dart`'s
// deterministic Ahem font override does not apply (store screenshots must
// render the real GitLab Sans/Mono fonts).
//
//   flutter test tool/store_screenshots_test.dart
//
// See store/README.md for the store specs behind the three device profiles.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/code/presentation/file_view_screen.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_changes_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:gitsune/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';
import 'package:gitsune/features/todos/todos_screen.dart';

import '../test/features/code/support/fixture_repository_tree_repository.dart';
import '../test/features/issues/support/fixture_issues_repository.dart';
import '../test/features/merge_requests/support/fixture_merge_requests_repository.dart';
import '../test/features/pipelines/support/fixture_pipelines_repository.dart';
import '../test/features/todos/support/fixture_todos_repository.dart';

class _Profile {
  const _Profile(this.dir, this.logical, this.dpr);

  final String dir;
  final Size logical;
  final double dpr;
}

// Physical output = logical * dpr. Specs are in store/README.md.
const _profiles = [
  // Google Play phone: 9:16, 1080x1920 (F-Droid reuses this set).
  _Profile('play/phone', Size(360, 640), 3),
  // App Store iPhone 6.9": 1290x2796.
  _Profile('appstore/iphone-6-9', Size(430, 932), 3),
  // App Store iPad 13": 2064x2752.
  _Profile('appstore/ipad-13', Size(1032, 1376), 2),
];

typedef _Screen = (String, Widget Function(WidgetTester tester));

// Order matters: file names are numbered, and stores show them in order,
// so the strongest story (to-dos, MR review) leads.
final List<_Screen> _screens = [
  (
    'todos',
    (tester) {
      final repository = FixtureTodosRepository();
      addTearDown(repository.dispose);
      return TodosScreen(
        repository: repository,
        now: DateTime.utc(2026, 8, 2, 10),
      );
    },
  ),
  (
    'merge_request_detail',
    (tester) => MergeRequestDetailScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      mergeIid: 142,
      repository: FixtureMergeRequestsRepository(),
      now: DateTime.utc(2026, 8, 2, 10),
    ),
  ),
  (
    'merge_request_changes',
    (tester) => MergeRequestChangesScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      mergeIid: 142,
      repository: FixtureMergeRequestsRepository(),
    ),
  ),
  (
    'pipeline_detail',
    (tester) => PipelineDetailScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      pipelineId: 88123,
      repository: FixturePipelinesRepository(),
    ),
  ),
  (
    'issue_detail',
    (tester) => IssueDetailScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      issueIid: 142,
      repository: FixtureIssuesRepository(),
      now: DateTime.utc(2026, 8, 2, 10),
    ),
  ),
  (
    'file_view',
    (tester) => FileViewScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      filePath: 'lib/core/app_theme.dart',
      repository: FixtureRepositoryTreeRepository(),
    ),
  ),
  ('sign_in', (tester) => const SignInScreen()),
];

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    final bytes = File(asset).readAsBytesSync();
    loader.addFont(
      Future.value(
        ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length),
      ),
    );
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    // flutter_tester renders unknown font families as Ahem blocks; load the
    // app's real bundled fonts so store screenshots show real text.
    await _loadFont('GitLab Sans', [
      'assets/fonts/GitLabSans.ttf',
      'assets/fonts/GitLabSans-Italic.ttf',
    ]);
    await _loadFont('GitLab Mono', [
      'assets/fonts/GitLabMono.ttf',
      'assets/fonts/GitLabMono-Italic.ttf',
    ]);
  });

  for (final profile in _profiles) {
    for (final (index, (name, builder)) in _screens.indexed) {
      testWidgets('$name at ${profile.dir}', (tester) async {
        tester.view.devicePixelRatio = profile.dpr;
        tester.view.physicalSize = profile.logical * profile.dpr;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        const boundaryKey = Key('store-screenshot');
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(),
              home: builder(tester),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        final file = File(
          'store/screenshots/${profile.dir}/${index + 1}_$name.png',
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: profile.dpr);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          file
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
        });

        final decoded = await tester.runAsync(
          () async => ui.instantiateImageCodec(file.readAsBytesSync()),
        );
        final frame = await tester.runAsync(() => decoded!.getNextFrame());
        final size = Size(
          frame!.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
        expect(size, profile.logical * profile.dpr);
      });
    }
  }
}
