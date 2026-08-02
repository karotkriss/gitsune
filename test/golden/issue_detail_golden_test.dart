import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';

import '../features/issues/support/fixture_issues_repository.dart';

void main() {
  testWidgets('issue detail matches the dark thread-anatomy golden', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: FixtureIssuesRepository(),
          now: DateTime.utc(2026, 8, 2, 10),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(IssueDetailScreen),
      matchesGoldenFile('goldens/issue_detail.png'),
    );
  });
}
