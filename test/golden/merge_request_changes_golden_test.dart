import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_changes_screen.dart';

import '../features/merge_requests/support/fixture_merge_requests_repository.dart';

void main() {
  testWidgets('merge request changes matches the highlighted diff golden', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MergeRequestChangesScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: FixtureMergeRequestsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MergeRequestChangesScreen),
      matchesGoldenFile('goldens/merge_request_changes.png'),
    );
  });
}
