import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_merge_box.dart';

import '../support/fixture_merge_requests_repository.dart';

void main() {
  final now = DateTime.utc(2026, 8, 2, 10);

  Widget detailScreen(FixtureMergeRequestsRepository repository) => MaterialApp(
    theme: buildAppTheme(),
    home: MergeRequestDetailScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      mergeIid: 142,
      repository: repository,
      now: now,
    ),
  );

  FilledButton mergeButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(const ValueKey('merge-button')));

  // The approvals summary also appears in the Approvals section, so scope
  // text assertions to the merge box.
  Finder inBox(String text) => find.descendant(
    of: find.byType(MergeRequestMergeBox),
    matching: find.text(text),
  );

  testWidgets('merge box reflects all four readiness inputs', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(detailScreen(FixtureMergeRequestsRepository()));
    await tester.pumpAndSettle();

    // Pipeline (running), approvals (1 of 2), mergeability, and the
    // unresolved-discussion count from the default fixtures.
    expect(inBox('Pipeline running'), findsOneWidget);
    expect(inBox('1 of 2 approved'), findsOneWidget);
    expect(inBox('Can be merged'), findsOneWidget);
    expect(inBox('1 unresolved discussion'), findsOneWidget);
    expect(find.bySemanticsLabel('1 unresolved discussion'), findsOneWidget);

    // Outstanding approvals and the unresolved discussion block merging.
    expect(mergeButton(tester).onPressed, isNull);
    expect(find.text('Approve'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('approve, unapprove, and merge update the surface', (
    tester,
  ) async {
    // Only the resolved discussion fixture, so discussions do not block.
    final repository = FixtureMergeRequestsRepository(
      discussionFixtures: const ['merge_request_142_discussions_page2'],
    );
    await tester.pumpWidget(detailScreen(repository));
    await tester.pumpAndSettle();

    expect(inBox('All discussions resolved'), findsOneWidget);
    expect(mergeButton(tester).onPressed, isNull);

    await tester.ensureVisible(find.byKey(const ValueKey('approve-button')));
    await tester.tap(find.byKey(const ValueKey('approve-button')));
    await tester.pumpAndSettle();
    expect(repository.approveCalls, 1);
    expect(inBox('2 of 2 approved'), findsOneWidget);
    expect(find.text('Unapprove'), findsOneWidget);
    expect(mergeButton(tester).onPressed, isNotNull);

    await tester.ensureVisible(find.byKey(const ValueKey('approve-button')));
    await tester.tap(find.byKey(const ValueKey('approve-button')));
    await tester.pumpAndSettle();
    expect(repository.unapproveCalls, 1);
    expect(inBox('1 of 2 approved'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(mergeButton(tester).onPressed, isNull);

    await tester.ensureVisible(find.byKey(const ValueKey('approve-button')));
    await tester.tap(find.byKey(const ValueKey('approve-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('merge-button')));
    await tester.tap(find.byKey(const ValueKey('merge-button')));
    await tester.pumpAndSettle();
    expect(repository.mergeCalls, 1);
    expect(find.text('This merge request has been merged.'), findsOneWidget);
    expect(find.byKey(const ValueKey('merge-button')), findsNothing);
    // The header badge may be scrolled offstage after tapping merge.
    expect(find.text('Merged', skipOffstage: false), findsOneWidget);
  });

  testWidgets('refresh releases only the obsolete action lock', (tester) async {
    final repository = _DelayedApproveRepository(
      discussionFixtures: const ['merge_request_142_discussions_page2'],
    );
    final approved = await FixtureMergeRequestsRepository().approve(7, 142);
    await tester.pumpWidget(detailScreen(repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('approve-button')));
    await tester.tap(find.byKey(const ValueKey('approve-button')));
    await tester.pump();
    expect(repository.approveCalls, 1);

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('approve-button')));
    await tester.tap(find.byKey(const ValueKey('approve-button')));
    await tester.pump();
    expect(repository.approveCalls, 2);

    repository.approvals[0].complete(approved);
    await tester.pump();
    final approve = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('approve-button')),
    );
    expect(approve.onPressed, isNull);

    repository.approvals[1].complete(approved);
    await tester.pumpAndSettle();
    expect(find.text('Unapprove'), findsOneWidget);
  });
}

class _DelayedApproveRepository extends FixtureMergeRequestsRepository {
  _DelayedApproveRepository({required super.discussionFixtures});

  final approvals = <Completer<MergeRequestApprovals>>[];

  @override
  Future<MergeRequestApprovals> approve(int projectId, int mergeIid) {
    approveCalls++;
    final request = Completer<MergeRequestApprovals>();
    approvals.add(request);
    return request.future;
  }
}
