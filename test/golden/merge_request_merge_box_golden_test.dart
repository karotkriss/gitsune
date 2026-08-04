import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_merge_box.dart';

import '../support/fixtures.dart';

void main() {
  testWidgets('merge box matches the blocked and ready goldens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final mergeRequest = MergeRequest.fromJson(
      Map<String, dynamic>.from(Fixtures.json('merge_request_142') as Map),
    );
    final blockedApprovals = MergeRequestApprovals.fromJson(
      Map<String, dynamic>.from(
        Fixtures.json('merge_request_142_approvals') as Map,
      ),
    );
    final readyApprovals = MergeRequestApprovals.fromJson(
      Map<String, dynamic>.from(
        Fixtures.json('merge_request_142_approved') as Map,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MergeRequestMergeBox(
                  mergeRequest: mergeRequest,
                  pipelineStatus: CiStatus.failed,
                  pipelinesLoading: false,
                  approvals: blockedApprovals,
                  approvalsLoading: false,
                  unresolvedCount: 2,
                  discussionsLoading: false,
                  actionInFlight: false,
                  onApprove: () {},
                  onUnapprove: () {},
                  onMerge: () {},
                ),
                const SizedBox(height: 16),
                MergeRequestMergeBox(
                  mergeRequest: mergeRequest,
                  pipelineStatus: CiStatus.success,
                  pipelinesLoading: false,
                  approvals: readyApprovals,
                  approvalsLoading: false,
                  unresolvedCount: 0,
                  discussionsLoading: false,
                  actionInFlight: false,
                  onApprove: () {},
                  onUnapprove: () {},
                  onMerge: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/merge_request_merge_box.png'),
    );
  });
}
