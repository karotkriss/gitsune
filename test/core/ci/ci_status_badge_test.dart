import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/ci/ci_status_badge.dart';
import 'package:gitsune/core/theme/app_theme.dart';

void main() {
  test('normalizes GitLab API states and keeps unknown states displayable', () {
    expect(CiStatus.fromApi('success'), CiStatus.success);
    expect(
      CiStatus.fromApi('waiting_for_resource'),
      CiStatus.waitingForResource,
    );
    expect(CiStatus.fromApi('canceling'), CiStatus.canceling);
    expect(CiStatus.fromApi('new_server_state'), CiStatus.unknown);
  });

  testWidgets('exposes every status through a reusable semantic badge', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Wrap(
            children: [
              for (final status in CiStatus.values)
                CiStatusBadge(status: status),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CiStatusBadge), findsNWidgets(CiStatus.values.length));
    expect(find.bySemanticsLabel('CI status: Passed'), findsOneWidget);
    expect(
      find.bySemanticsLabel('CI status: Waiting for resource'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('CI status: Unknown'), findsOneWidget);
    semantics.dispose();
  });
}
