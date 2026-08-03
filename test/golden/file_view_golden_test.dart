import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/code/presentation/file_view_screen.dart';

import '../features/code/support/fixture_repository_tree_repository.dart';

void main() {
  testWidgets('File view matches the highlighted-blob golden', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: FileViewScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          filePath: 'lib/core/app_theme.dart',
          repository: FixtureRepositoryTreeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FileViewScreen),
      matchesGoldenFile('goldens/file_view_screen.png'),
    );
  });
}
