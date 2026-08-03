import 'dart:async';

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
    'renders pipeline and stage-grouped job statuses with per-status actions',
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
      // The failed and running jobs already visible in the TEST stage carry
      // their retry and cancel actions.
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Run'), findsNothing);
      expect(find.bySemanticsLabel('Retry'), findsOneWidget);
      expect(find.bySemanticsLabel('Cancel'), findsOneWidget);
      expect(
        tester.getSize(find.widgetWithText(TextButton, 'Cancel')).height,
        greaterThanOrEqualTo(48),
      );
      await tester.scrollUntilVisible(
        find.text('DEPLOY'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('DEPLOY'), findsOneWidget);
      // The manual job in the DEPLOY stage carries the run action.
      expect(find.text('Run'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('CLEANUP'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('CLEANUP'), findsOneWidget);
      expect(repository.loads, 1);
      semantics.dispose();
    },
  );

  testWidgets(
    'tapping retry calls the repository and reflects the returned status',
    (tester) async {
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

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(repository.retriedJobIds, [503]);
      expect(find.text('Retry'), findsNothing);
    },
  );

  testWidgets(
    'tapping cancel calls the repository and reflects the returned status',
    (tester) async {
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

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.canceledJobIds, [502]);
      expect(find.text('Cancel'), findsNothing);
    },
  );

  testWidgets(
    'tapping run calls the repository and reflects the returned status',
    (tester) async {
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
      await tester.scrollUntilVisible(
        find.text('Run'),
        240,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Run'));
      await tester.pumpAndSettle();

      expect(repository.playedJobIds, [506]);
      expect(find.text('Run'), findsNothing);
    },
  );

  testWidgets('action completion cannot update a replacement pipeline', (
    tester,
  ) async {
    final oldRepository = _DeferredCancelRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PipelineDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          pipelineId: 88123,
          repository: oldRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: PipelineDetailScreen(
          projectId: 8,
          projectPath: 'gitsune/other',
          pipelineId: 99234,
          repository: FixturePipelinesRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    oldRepository.completeCancel();
    await tester.pump();

    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('action result wins over an older refresh response', (
    tester,
  ) async {
    final repository = _DeferredRefreshRepository();
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

    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(repository.loads, 2);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('Cancel'), findsNothing);

    await repository.completeRefresh();
    await refresh;
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('loading failure remains display-only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const PipelineDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          pipelineId: 88123,
          repository: _FailingPipelineRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load this pipeline.'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });

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

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) =>
      _fixture.retryJob(projectId, jobId);

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) =>
      _fixture.cancelJob(projectId, jobId);

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) =>
      _fixture.playJob(projectId, jobId);

  @override
  Future<String> loadJobLog(int projectId, int jobId) =>
      _fixture.loadJobLog(projectId, jobId);
}

class _DeferredCancelRepository implements PipelinesRepository {
  final _fixture = FixturePipelinesRepository();
  final _cancel = Completer<PipelineJob>();

  void completeCancel() {
    _cancel.complete(
      const PipelineJob(
        id: 502,
        name: 'test:flutter',
        stage: 'test',
        status: CiStatus.canceled,
        allowFailure: false,
      ),
    );
  }

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) =>
      _fixture.loadPipeline(projectId, pipelineId);

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) =>
      _fixture.retryJob(projectId, jobId);

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) => _cancel.future;

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) =>
      _fixture.playJob(projectId, jobId);

  @override
  Future<String> loadJobLog(int projectId, int jobId) =>
      _fixture.loadJobLog(projectId, jobId);
}

class _DeferredRefreshRepository implements PipelinesRepository {
  final _fixture = FixturePipelinesRepository();
  final _refresh = Completer<PipelineDetails>();
  int loads = 0;

  Future<void> completeRefresh() async {
    _refresh.complete(await _fixture.loadPipeline(7, 88123));
  }

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) {
    loads++;
    if (loads == 1) return _fixture.loadPipeline(projectId, pipelineId);
    return _refresh.future;
  }

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) =>
      _fixture.retryJob(projectId, jobId);

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) =>
      _fixture.cancelJob(projectId, jobId);

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) =>
      _fixture.playJob(projectId, jobId);

  @override
  Future<String> loadJobLog(int projectId, int jobId) =>
      _fixture.loadJobLog(projectId, jobId);
}

class _FailingPipelineRepository implements PipelinesRepository {
  const _FailingPipelineRepository();

  @override
  Future<PipelineDetails> loadPipeline(int projectId, int pipelineId) {
    throw Exception('fixture failure');
  }

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) =>
      throw UnimplementedError();

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) =>
      throw UnimplementedError();

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) =>
      throw UnimplementedError();

  @override
  Future<String> loadJobLog(int projectId, int jobId) =>
      throw UnimplementedError();
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

  @override
  Future<PipelineJob> retryJob(int projectId, int jobId) =>
      _fixture.retryJob(projectId, jobId);

  @override
  Future<PipelineJob> cancelJob(int projectId, int jobId) =>
      _fixture.cancelJob(projectId, jobId);

  @override
  Future<PipelineJob> playJob(int projectId, int jobId) =>
      _fixture.playJob(projectId, jobId);

  @override
  Future<String> loadJobLog(int projectId, int jobId) =>
      _fixture.loadJobLog(projectId, jobId);
}
