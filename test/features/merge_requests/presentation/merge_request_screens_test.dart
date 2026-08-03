import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status_badge.dart';
import 'package:gitsune/core/icons/gs_icons.dart';
import 'package:gitsune/core/markdown/gs_markdown.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_components.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_list_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';

import '../support/fixture_merge_requests_repository.dart';

void main() {
  final now = DateTime.utc(2026, 8, 2, 10);

  testWidgets('merge request list renders branch anatomy and paginates', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureMergeRequestsRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MergeRequestListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add instance switcher sheet'), findsOneWidget);
    expect(find.text('feat/instance-switcher'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.text('feat/instance-switcher'))
          .style
          ?.fontFamily,
      'GitLab Mono',
    );
    expect(find.text('main'), findsAtLeastNWidgets(1));
    expect(find.byType(MergeRequestStateBadge), findsAtLeastNWidgets(3));
    final firstRow = find.bySemanticsLabel(
      RegExp(
        r'Open merge request !142.*Source branch feat/instance-switcher, '
        r'target branch main.*5 comments.*Updated 2h by ade',
      ),
    );
    expect(firstRow, findsOneWidget);
    expect(
      tester
          .getSemantics(firstRow)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(repository.nextPageLoads, 1);
    expect(find.text('Remove stale session banner'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Draft merge request !139')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('detail renders markdown and collapsible shell sections', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureMergeRequestsRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MergeRequestDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: repository,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GsMarkdown), findsOneWidget);
    expect(
      find.textContaining('multi-instance', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('feat/instance-switcher'), findsOneWidget);
    expect(find.text('4 files changed'), findsOneWidget);
    expect(find.text('Pipelines'), findsOneWidget);
    expect(find.text('Approvals'), findsOneWidget);
    expect(find.text('1 of 2 approved'), findsOneWidget);
    expect(find.byType(CiStatusBadge), findsNWidgets(4));
    expect(
      find.textContaining('Pipeline #88123', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Priya Sharma'), findsOneWidget);
    final pipelinesHeader = find.bySemanticsLabel(
      RegExp(r'Pipelines, Running'),
    );
    expect(
      tester
          .getSemantics(pipelinesHeader)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('pipelines-section-toggle')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Pipeline #88123', findRichText: true),
      findsNothing,
    );
    expect(find.text('Priya Sharma'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('approvals-section-toggle')),
    );
    await tester.tap(find.byKey(const ValueKey('approvals-section-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Priya Sharma'), findsNothing);
    expect(repository.detailLoads, 1);
    semantics.dispose();
  });

  testWidgets('detail survives independent supplemental request failures', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MergeRequestDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: _FailingSupplementsRepository(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add instance switcher sheet'), findsOneWidget);
    expect(find.text('4 files changed'), findsOneWidget);
    expect(find.text('Unable to load Pipelines.'), findsOneWidget);
    expect(find.text('Unable to load Approvals.'), findsOneWidget);
  });

  testWidgets('router exposes merge requests as project destinations', (
    tester,
  ) async {
    final repository = FixtureMergeRequestsRepository();
    final router = buildAppRouter(
      mergeRequestsRepository: repository,
      initialLocation: '/projects/7/merge_requests?projectPath=gitsune%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MergeRequestListScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('merge-request-row-142')));
    await tester.pumpAndSettle();

    expect(find.byType(MergeRequestDetailScreen), findsOneWidget);
    expect(find.text('gitsune/app · !142'), findsOneWidget);
  });

  testWidgets('state badges use state-accurate Pajamas glyphs', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Column(
            children: [
              MergeRequestStateBadge(state: MergeRequestState.opened),
              MergeRequestStateBadge(state: MergeRequestState.merged),
              MergeRequestStateBadge(state: MergeRequestState.closed),
              MergeRequestStateBadge(
                state: MergeRequestState.opened,
                draft: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.widgetList<GsIcon>(find.byType(GsIcon)).map((icon) => icon.glyph),
      [
        GsIconGlyph.mergeRequestOpen,
        GsIconGlyph.merge,
        GsIconGlyph.mergeRequestClosed,
        GsIconGlyph.mergeRequestOpen,
      ],
    );
    expect(find.bySemanticsLabel('Merge request state: Draft'), findsOneWidget);
    semantics.dispose();
  });

  test('relative timestamps stay compact and deterministic', () {
    expect(
      formatMergeRequestRelativeTime(DateTime.utc(2026, 8, 2, 9, 48), now),
      '12m',
    );
    expect(
      formatMergeRequestRelativeTime(DateTime.utc(2026, 8, 1, 10), now),
      '1d',
    );
    expect(
      formatMergeRequestRelativeTime(DateTime.utc(2026, 7, 1, 12), now),
      '2026-07-01',
    );
  });
}

class _FailingSupplementsRepository extends FixtureMergeRequestsRepository {
  @override
  Future<MergeRequestPipelinePage> loadFirstPipelinePage(
    int projectId,
    int mergeIid,
  ) => Future.error(StateError('pipeline failure'));

  @override
  Future<MergeRequestApprovals> loadApprovals(int projectId, int mergeIid) =>
      Future.error(StateError('approval failure'));
}
