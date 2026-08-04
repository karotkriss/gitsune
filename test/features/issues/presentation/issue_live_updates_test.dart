import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/network/graphql_subscriptions.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/data/issues_repository.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';

import '../../../support/fake_cable_server.dart';
import '../support/fixture_issues_repository.dart';

/// E12.3: an open issue screen live-updates from GraphQL subscription events,
/// and the subscription stops on background and on screen close.
void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 8, 2, 10);
  late FakeCableServer server;

  setUp(() async {
    server = await FakeCableServer.start();
  });

  tearDown(() => server.close());

  Widget buildScreen({IssuesRepository? repository, Issue? initialIssue}) =>
      MaterialApp(
        theme: buildAppTheme(),
        home: IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: repository ?? FixtureIssuesRepository(),
          subscriptions: GraphQlSubscriptions(
            account: const AccountKey(
              instanceHost: 'gitlab.example.com',
              accountId: '7',
            ),
            readToken: (_) async => const TokenReadResult('token-live'),
            cableUri: server.uri,
          ),
          initialIssue: initialIssue,
          now: now,
        ),
      );

  Future<void> pumpUntil(WidgetTester tester, bool Function() condition) async {
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException('pumpUntil condition not met');
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await tester.pump();
    }
  }

  Future<FakeCableConnection> settleSubscribed(
    WidgetTester tester, {
    int connection = 0,
  }) async {
    await tester.pumpAndSettle();
    await waitUntil(
      () =>
          server.connections.length > connection &&
          server.connections[connection].identifier != null,
    );
    return server.connections[connection];
  }

  testWidgets('the open issue screen live-updates its title', (tester) async {
    await tester.pumpWidget(buildScreen());
    final connection = await settleSubscribed(tester);

    expect(connection.authorization, 'Bearer token-live');
    final identifier =
        jsonDecode(connection.identifier!) as Map<String, dynamic>;
    expect(identifier['channel'], 'GraphqlChannel');
    expect(identifier['variables'], {'issuableId': 'gid://gitlab/Issue/1420'});

    expect(find.text('Keep draft comments after reconnecting'), findsWidgets);
    connection.pushResult({
      'issuableTitleUpdated': {'title': 'Renamed while the screen was open'},
    });
    await pumpUntil(
      tester,
      () =>
          find.text('Renamed while the screen was open').evaluate().isNotEmpty,
    );
    expect(find.text('Keep draft comments after reconnecting'), findsNothing);
  });

  testWidgets('a pending refresh cannot overwrite a live title', (
    tester,
  ) async {
    final fixtureRepository = FixtureIssuesRepository();
    final initialIssue = await fixtureRepository.loadIssue(7, 142);
    final repository = _DelayedIssueRepository();
    await tester.pumpWidget(
      buildScreen(repository: repository, initialIssue: initialIssue),
    );
    await waitUntil(
      () =>
          server.connections.isNotEmpty &&
          server.connections.single.identifier != null,
    );
    final connection = server.connections.single;

    connection.pushResult({
      'issuableTitleUpdated': {'title': 'Newest subscription title'},
    });
    await pumpUntil(
      tester,
      () => find.text('Newest subscription title').evaluate().isNotEmpty,
    );

    repository.issue.complete(initialIssue);
    await tester.pumpAndSettle();

    expect(find.text('Newest subscription title'), findsWidgets);
    expect(find.text(initialIssue.title), findsNothing);
  });

  testWidgets('backgrounding stops the subscription; showing resumes it', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    final connection = await settleSubscribed(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await waitUntil(() => connection.closed);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final resumed = await settleSubscribed(tester, connection: 1);

    resumed.pushResult({
      'issuableTitleUpdated': {'title': 'Renamed after resume'},
    });
    await pumpUntil(
      tester,
      () => find.text('Renamed after resume').evaluate().isNotEmpty,
    );
  });

  testWidgets('closing the screen stops the subscription', (tester) async {
    await tester.pumpWidget(buildScreen());
    final connection = await settleSubscribed(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    await waitUntil(() => connection.closed);
  });
}

class _DelayedIssueRepository extends FixtureIssuesRepository {
  final issue = Completer<Issue>();

  @override
  Future<Issue> loadIssue(int projectId, int issueIid) => issue.future;
}
