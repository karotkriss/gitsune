import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/ci/ci_status_badge.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/presentation/job_log_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../support/fixture_pipelines_repository.dart';

const _job = PipelineJob(
  id: 502,
  name: 'test:flutter',
  stage: 'test',
  status: CiStatus.running,
  allowFailure: false,
);

Widget _screen(FixturePipelinesRepository repository) => MaterialApp(
  theme: buildAppTheme(),
  home: JobLogScreen(
    projectId: 7,
    jobId: 502,
    repository: repository,
    job: _job,
    ref: 'feat/status-surface',
  ),
);

void main() {
  testWidgets('renders the fixture trace with header, badge, and ref', (
    tester,
  ) async {
    final repository = FixturePipelinesRepository();
    await tester.pumpWidget(_screen(repository));
    await tester.pumpAndSettle();

    expect(repository.logLoads, 1);
    expect(find.text('test:flutter'), findsOneWidget);
    expect(find.byType(CiStatusBadge), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('feat/status-surface'), findsOneWidget);
    expect(
      find.text('Running with gitlab-runner 17.5.3 (12345678)'),
      findsOneWidget,
    );
    expect(find.text(r'$ flutter analyze'), findsOneWidget);
    // Section markers and escape bytes never render raw.
    expect(find.textContaining('section_start'), findsNothing);
    expect(find.textContaining('\x1b'), findsNothing);
    expect(find.text('Preparing the "docker" executor'), findsOneWidget);
    // A \r progress line shows only its final state.
    expect(find.text('00:12 +42: All tests passed!'), findsOneWidget);
    expect(find.textContaining('00:03 +0'), findsNothing);
  });

  testWidgets('renders log lines in the mono face with SGR colors applied', (
    tester,
  ) async {
    await tester.pumpWidget(_screen(FixturePipelinesRepository()));
    await tester.pumpAndSettle();

    final mono = buildAppTheme().extension<GsTheme>()!.mono;
    final line = tester.widget<Text>(find.text('Analyzing gitsune...'));
    expect(line.style?.fontFamily, mono.fontFamily);

    final command = tester.widget<Text>(find.text(r'$ flutter analyze'));
    final span = (command.textSpan! as TextSpan).children!.single as TextSpan;
    expect(span.style?.color, const Color(0xFF33D17A));
    expect(span.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('builds long logs lazily and keeps them scrollable', (
    tester,
  ) async {
    const totalLines = 5000;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: JobLogScreen(
          projectId: 7,
          jobId: 502,
          repository: _LongLogRepository(totalLines),
          job: _job,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('log line 0 of the long trace'), findsOneWidget);
    // The list is virtualized: the tail is not built until scrolled to, and
    // only about a viewport's worth of the trace exists as widgets.
    expect(find.textContaining('log line 4999'), findsNothing);
    expect(
      find.byType(Text).evaluate().length,
      lessThan(totalLines ~/ 10),
      reason: 'a long log must not build all its lines at once',
    );

    await tester.scrollUntilVisible(
      find.text('log line 4999 of the long trace'),
      10000,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('log line 4999 of the long trace'), findsOneWidget);
    expect(find.textContaining('log line 0 of'), findsNothing);
    expect(find.byType(Text).evaluate().length, lessThan(totalLines ~/ 10));
  });

  testWidgets('shows the failure state when the trace cannot load', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: JobLogScreen(
          projectId: 7,
          jobId: 502,
          repository: _FailingLogRepository(),
          job: _job,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load this job log.'), findsOneWidget);
  });

  testWidgets('a tapped job row opens its log through the router', (
    tester,
  ) async {
    final repository = FixturePipelinesRepository();
    final router = buildAppRouter(
      pipelinesRepository: repository,
      initialLocation: '/projects/7/pipelines/88123?projectPath=gitsune%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('test:flutter'));
    await tester.pumpAndSettle();

    expect(find.byType(JobLogScreen), findsOneWidget);
    expect(find.text('test:flutter'), findsOneWidget);
    expect(find.byType(CiStatusBadge), findsOneWidget);
    expect(find.text('feat/status-surface'), findsOneWidget);
    expect(find.text(r'$ flutter test'), findsOneWidget);
  });

  testWidgets('a deep link without job details falls back to the job id', (
    tester,
  ) async {
    final router = buildAppRouter(
      pipelinesRepository: FixturePipelinesRepository(),
      initialLocation: '/projects/7/jobs/502/log',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('Job #502'), findsNWidgets(2)); // App bar and header.
    expect(find.byType(CiStatusBadge), findsNothing);
    expect(find.text(r'$ flutter analyze'), findsOneWidget);
  });
}

class _LongLogRepository extends FixturePipelinesRepository {
  _LongLogRepository(this.lines);

  final int lines;

  @override
  Future<String> loadJobLog(int projectId, int jobId) async => [
    for (var i = 0; i < lines; i++) 'log line $i of the long trace',
  ].join('\n');
}

class _FailingLogRepository extends FixturePipelinesRepository {
  @override
  Future<String> loadJobLog(int projectId, int jobId) =>
      throw Exception('fixture failure');
}
