import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/ci/ci_status_badge.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/data/pipelines_repository.dart';
import 'package:gitsune/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../support/fixture_pipelines_repository.dart';

void main() {
  testWidgets(
    'renders pipeline and stage-grouped job statuses without actions',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final repository = FixturePipelinesRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: PipelineDetailScreen(
            projectId: 7,
            projectPath: 'gitsune/app',
            pipelineId: 88123,
            repository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pipeline #88123'), findsOneWidget);
      expect(find.text('feat/status-surface'), findsOneWidget);
      expect(find.text('a73f91c2'), findsOneWidget);
      expect(find.text('BUILD'), findsOneWidget);
      expect(find.text('TEST'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('BUILD')).dy,
        lessThan(tester.getTopLeft(find.text('TEST')).dy),
      );
      expect(find.text('DEPLOY'), findsNothing);
      expect(find.text('test:integration'), findsOneWidget);
      expect(
        find.bySemanticsLabel('test:flutter, Running, test stage, 48s.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('DEPLOY'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('DEPLOY'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('CLEANUP'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('CLEANUP'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Run'), findsNothing);
      expect(repository.loads, 1);
      semantics.dispose();
    },
  );

  testWidgets(
    'router exposes pipeline detail as a pushed project destination',
    (tester) async {
      final repository = FixturePipelinesRepository();
      final router = buildAppRouter(
        pipelinesRepository: repository,
        initialLocation:
            '/projects/7/pipelines/88123?projectPath=gitsune%2Fapp',
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PipelineDetailScreen), findsOneWidget);
      expect(find.text('gitsune/app · #88123'), findsOneWidget);
      expect(find.text('Jobs · 8'), findsOneWidget);
    },
  );

  testWidgets('status surface remains usable on a compact phone viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

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

    expect(tester.takeException(), isNull);
    expect(find.text('Pipeline #88123'), findsOneWidget);
    expect(find.text('test:flutter'), findsOneWidget);
  });

  testWidgets('allowed failures keep failed semantics with a warning badge', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PipelineDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          pipelineId: 88123,
          repository: _AllowedFailureRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('audit, Failed, test stage, 12s, allowed to fail.'),
      findsOneWidget,
    );
    expect(
      tester
          .widgetList<CiStatusBadge>(find.byType(CiStatusBadge))
          .map((badge) => badge.status),
      contains(CiStatus.warning),
    );
    semantics.dispose();
  });

  testWidgets('large pipeline job lists build lazily and remain reachable', (
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
          repository: _LargePipelineRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('matrix:199'), findsNothing);
    expect(find.byType(CiStatusBadge).evaluate().length, lessThan(201));

    await tester.scrollUntilVisible(
      find.text('matrix:199'),
      500,
      maxScrolls: 100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('matrix:199'), findsOneWidget);
  });

  test('formats compact CI durations and known pipeline sources', () {
    expect(formatCiDuration(null), 'Not started');
    expect(formatCiDuration(48), '48s');
    expect(formatCiDuration(138), '2m 18s');
    expect(formatCiDuration(3600), '1h');
    expect(formatCiDuration(3782), '1h 3m');
    expect(formatPipelineSource('merge_request_event'), 'Merge request');
    expect(formatPipelineSource('future_source'), 'Pipeline');
  });
}

class _LargePipelineRepository implements PipelinesRepository {
  final _fixture = FixturePipelinesRepository();

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) async {
    final details = await _fixture.loadPipeline(projectId, pipelineId);
    return PipelineDetails(
      pipeline: details.pipeline,
      jobs: List.generate(
        200,
        (index) => PipelineJob(
          id: index,
          name: 'matrix:$index',
          stage: 'matrix',
          status: CiStatus.pending,
          allowFailure: false,
        ),
      ),
    );
  }
}

class _AllowedFailureRepository implements PipelinesRepository {
  final _fixture = FixturePipelinesRepository();

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) async {
    final details = await _fixture.loadPipeline(projectId, pipelineId);
    return PipelineDetails(
      pipeline: details.pipeline,
      jobs: const [
        PipelineJob(
          id: 1,
          name: 'audit',
          stage: 'test',
          status: CiStatus.failed,
          badgeStatus: CiStatus.warning,
          allowFailure: true,
          duration: 12,
        ),
      ],
    );
  }
}
