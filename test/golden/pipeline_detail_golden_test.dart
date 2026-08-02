import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/pipelines/presentation/pipeline_detail_screen.dart';

import '../features/pipelines/support/fixture_pipelines_repository.dart';

void main() {
  testWidgets('pipeline detail matches the dark status-surface golden', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PipelineDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          pipelineId: 88123,
          repository: FixturePipelinesRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(PipelineDetailScreen),
      matchesGoldenFile('goldens/pipeline_detail.png'),
    );
  });
}
