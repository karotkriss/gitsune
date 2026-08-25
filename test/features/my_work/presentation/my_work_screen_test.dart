import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/my_work/data/my_work_repository.dart';
import 'package:gitsune/features/my_work/presentation/my_work_screen.dart';

import '../support/fixture_my_work_repository.dart';

void main() {
  final now = DateTime.utc(2026, 8, 10, 10);

  Widget app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

  testWidgets('my issues lists both pages of the assigned queue', (
    tester,
  ) async {
    final repository = FixtureMyWorkRepository();
    await tester.pumpWidget(
      app(MyIssuesScreen(repository: repository, now: now)),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Issues'), findsOneWidget);
    expect(find.text('Keep draft comments after reconnecting'), findsOneWidget);
    expect(
      find.text('Show pending uploads in the offline queue'),
      findsOneWidget,
    );
    // The short first page does not fill the viewport, so the next page
    // loads immediately - the same viewport-fill behavior as the project
    // issue list.
    expect(repository.nextIssuePageLoads, 1);
    expect(find.text('Document the refresh retry behavior'), findsOneWidget);
    expect(repository.issueScopeLoads, [MyWorkScope.assigned]);
  });

  testWidgets('switching to Authored reloads the issue queue with the '
      'authored scope', (tester) async {
    final repository = FixtureMyWorkRepository();
    await tester.pumpWidget(
      app(MyIssuesScreen(repository: repository, now: now)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Authored by me'));
    await tester.pumpAndSettle();

    expect(repository.issueScopeLoads, [
      MyWorkScope.assigned,
      MyWorkScope.authored,
    ]);
  });

  testWidgets('tapping an issue row reports the issue', (tester) async {
    final repository = FixtureMyWorkRepository();
    final tapped = <Issue>[];
    await tester.pumpWidget(
      app(
        MyIssuesScreen(
          repository: repository,
          onIssueTap: tapped.add,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep draft comments after reconnecting'));
    expect(tapped.map((issue) => issue.iid), [142]);
  });

  testWidgets('an empty issue queue explains the active scope', (tester) async {
    final repository = FixtureMyWorkRepository(issues: const []);
    await tester.pumpWidget(
      app(MyIssuesScreen(repository: repository, now: now)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet.'), findsOneWidget);
    expect(
      find.text('Open issues assigned to you appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Authored by me'));
    await tester.pumpAndSettle();

    expect(find.text('Open issues you opened appear here.'), findsOneWidget);
  });

  testWidgets('my merge requests lists the queue and reports taps', (
    tester,
  ) async {
    final repository = FixtureMyWorkRepository();
    final tapped = <MergeRequest>[];
    await tester.pumpWidget(
      app(
        MyMergeRequestsScreen(
          repository: repository,
          onMergeRequestTap: tapped.add,
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Merge Requests'), findsOneWidget);
    expect(find.text('Add instance switcher sheet'), findsOneWidget);
    expect(find.text('Cache recently viewed issues'), findsOneWidget);
    expect(repository.mergeRequestScopeLoads, [MyWorkScope.assigned]);

    await tester.tap(find.text('Add instance switcher sheet'));
    expect(tapped.map((mergeRequest) => mergeRequest.iid), [142]);
  });
}
