import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/code/presentation/repository_tree_screen.dart';

import '../features/code/support/fixture_repository_tree_repository.dart';

void main() {
  testWidgets('Repository tree matches the nested-directory golden', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: RepositoryTreeScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          path: 'lib/core',
          repository: FixtureRepositoryTreeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RepositoryTreeScreen),
      matchesGoldenFile('goldens/repository_tree_screen.png'),
    );
  });
}
