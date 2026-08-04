import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/fake_gitlab_server.dart';

/// End-to-end coverage for the E7.4 review actions: approve, unapprove, and
/// merge run against the in-process fake GitLab server (never a live
/// instance), through the real Dio client, repository, and merge box UI.
///
/// Run against a device or emulator:
///   flutter test integration_test/merge_request_review_actions_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('approve, unapprove, and merge run end to end', (tester) async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    // Payloads are inlined because device-side tests cannot read the
    // host-only test/fixtures/ directory; the shapes mirror those fixtures.
    var approvalsJson = _approvals(approved: false);
    var mergeRequestJson = _mergeRequest(state: 'opened');
    server.handle('GET /api/v4/projects/7/merge_requests/142', (request) async {
      await _respond(request, mergeRequestJson);
    });
    server.handle('GET /api/v4/projects/7/merge_requests/142/approvals', (
      request,
    ) async {
      await _respond(request, approvalsJson);
    });
    server.respondJson('GET /api/v4/projects/7/merge_requests/142/pipelines', [
      {
        'id': 88123,
        'status': 'success',
        'ref': 'refs/merge-requests/142/head',
        'sha': '731af8923c51e65101fc3cbb3275ce0a3e849311',
      },
    ]);
    server.respondJson(
      'GET /api/v4/projects/7/merge_requests/142/discussions',
      const [],
    );
    server.handle('POST /api/v4/projects/7/merge_requests/142/approve', (
      request,
    ) async {
      approvalsJson = _approvals(approved: true);
      await _respond(request, approvalsJson, statusCode: HttpStatus.created);
    });
    server.handle('POST /api/v4/projects/7/merge_requests/142/unapprove', (
      request,
    ) async {
      approvalsJson = _approvals(approved: false);
      await _respond(request, approvalsJson, statusCode: HttpStatus.created);
    });
    server.handle('PUT /api/v4/projects/7/merge_requests/142/merge', (
      request,
    ) async {
      mergeRequestJson = _mergeRequest(state: 'merged');
      await _respond(request, mergeRequestJson);
    });

    const account = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'marin',
    );
    final repository = GitLabMergeRequestsRepository(
      createGitLabClient(
        account: account,
        baseUrl: server.baseUri.resolve('/api/v4'),
        readToken: (_) async => const TokenReadResult('fixture-token'),
        refreshToken: (_, _) async => fail('refresh should not be called'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MergeRequestDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: repository,
        ),
      ),
    );

    final approveButton = find.byKey(const ValueKey('approve-button'));
    final mergeButton = find.byKey(const ValueKey('merge-button'));

    // Approve: the approval summary and merge gate reflect the server state.
    await _waitFor(tester, find.text('0 of 1 approved'));
    expect(_mergeEnabled(tester, mergeButton), isFalse);
    await tester.ensureVisible(approveButton);
    await tester.tap(approveButton);
    await _waitFor(tester, find.text('1 of 1 approved'));
    expect(find.text('Unapprove'), findsOneWidget);
    expect(_mergeEnabled(tester, mergeButton), isTrue);

    // Unapprove: the outstanding approval blocks merging again.
    await tester.tap(approveButton);
    await _waitFor(tester, find.text('0 of 1 approved'));
    expect(find.text('Approve'), findsOneWidget);
    expect(_mergeEnabled(tester, mergeButton), isFalse);

    // Merge: re-approve, then merge and watch the surface fold it in.
    await tester.tap(approveButton);
    await _waitFor(tester, find.text('1 of 1 approved'));
    await tester.ensureVisible(mergeButton);
    await tester.tap(mergeButton);
    await _waitFor(tester, find.text('This merge request has been merged.'));
    expect(find.text('Merged'), findsOneWidget);
    expect(mergeButton, findsNothing);
  });
}

bool _mergeEnabled(WidgetTester tester, Finder mergeButton) =>
    tester.widget<FilledButton>(mergeButton).onPressed != null;

/// Pumps real frames until [finder] matches; integration tests run in real
/// time, so network round trips complete between pumps.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for $finder');
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _respond(
  HttpRequest request,
  Object? body, {
  int statusCode = HttpStatus.ok,
}) async {
  request.response.statusCode = statusCode;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(body));
  await request.response.close();
}

Map<String, dynamic> _approvals({required bool approved}) => {
  'id': 50142,
  'iid': 142,
  'project_id': 7,
  'approvals_required': 1,
  'approvals_left': approved ? 0 : 1,
  'user_has_approved': approved,
  'user_can_approve': !approved,
  'approved_by': [
    if (approved)
      {
        'user': {
          'id': 23,
          'username': 'marin',
          'name': 'Marin Petrova',
          'avatar_url': null,
        },
      },
  ],
};

Map<String, dynamic> _mergeRequest({required String state}) => {
  'id': 50142,
  'project_id': 7,
  'iid': 142,
  'title': 'Add instance switcher sheet',
  'description': 'Adds a compact account switcher.',
  'state': state,
  'draft': false,
  'author': {
    'id': 18,
    'username': 'ade',
    'name': 'Ade Ogunleye',
    'avatar_url': null,
  },
  'source_branch': 'feat/instance-switcher',
  'target_branch': 'main',
  'created_at': '2026-07-30T09:00:00.000Z',
  'updated_at': '2026-08-02T08:00:00.000Z',
  'user_notes_count': 5,
  'labels': const [],
  'changes_count': '4',
  'merge_status': 'can_be_merged',
  'detailed_merge_status': state == 'opened' ? 'mergeable' : 'not_open',
  'blocking_discussions_resolved': true,
};
