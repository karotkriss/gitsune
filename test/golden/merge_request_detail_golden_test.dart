import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_detail_screen.dart';

import '../features/merge_requests/support/fixture_merge_requests_repository.dart';

void main() {
  testWidgets('merge request detail matches the dark review-shell golden', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MergeRequestDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: FixtureMergeRequestsRepository(),
          now: DateTime.utc(2026, 8, 2, 10),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MergeRequestDetailScreen),
      matchesGoldenFile('goldens/merge_request_detail.png'),
    );
  });
}
