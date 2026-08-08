import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/account_sessions.dart';
import 'package:gitsune/core/auth/active_account.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/ci/ci_status.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/lock/app_lock.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/notifications/push_delivery.dart';
import 'package:gitsune/core/notifications/quiet_hours.dart';
import 'package:gitsune/core/notifications/todos_poller.dart';
import 'package:gitsune/core/notifications/relay_setup.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/accounts/accounts_screen.dart';
import 'package:gitsune/features/code/presentation/file_view_screen.dart';
import 'package:gitsune/features/home/home_screen.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';
import 'package:gitsune/features/issues/presentation/issue_list_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_changes_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_detail_screen.dart';
import 'package:gitsune/features/merge_requests/presentation/merge_request_list_screen.dart';
import 'package:gitsune/features/pipelines/data/pipeline_models.dart';
import 'package:gitsune/features/pipelines/presentation/job_log_screen.dart';
import 'package:gitsune/features/pipelines/presentation/pipeline_detail_screen.dart';
import 'package:gitsune/features/profile/profile_screen.dart';
import 'package:gitsune/features/search/data/search_models.dart';
import 'package:gitsune/features/settings/push_delivery_screen.dart';
import 'package:gitsune/features/settings/quiet_hours_screen.dart';
import 'package:gitsune/features/settings/relay_wizard_screen.dart';
import 'package:gitsune/features/search/presentation/search_screen.dart';
import 'package:gitsune/features/shell/app_shell.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';
import 'package:gitsune/features/todos/todos_screen.dart';
import 'package:gitsune/main.dart';

import '../features/code/support/fixture_repository_tree_repository.dart';
import '../features/issues/support/fixture_issues_repository.dart';
import '../features/merge_requests/support/fixture_merge_requests_repository.dart';
import '../features/pipelines/support/fixture_pipelines_repository.dart';
import '../features/releases/support/fixture_releases_repository.dart';
import '../features/search/support/fixture_search_repository.dart';
import '../features/todos/support/fixture_todos_repository.dart';
import '../support/fake_biometric_authenticator.dart';
import '../support/memory_secure_storage.dart';

/// E16.1: every key screen must satisfy the framework's own accessibility
/// guidelines - Android/iOS minimum touch targets, a semantic label on every
/// tappable, and WCAG AA text contrast - enforced, not just inspected.
Future<void> expectMeetsA11yGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

Widget _app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

class _NoopPushGateway implements AndroidPushGateway {
  @override
  void bind({
    required void Function(Uri endpoint, String instance) onEndpoint,
    required Future<void> Function(String body, String instance) onMessage,
    required void Function(String instance) onUnregistered,
  }) {}

  @override
  Future<void> register(String instance) async {}

  @override
  Future<void> unregister(String instance) async {}
}

class _SilentNotifier implements TodoNotifier {
  @override
  Future<void> showNewTodo({
    required AccountKey account,
    required int todoId,
    required String title,
    required String body,
  }) async {}
}

// Cancelling a drift query stream schedules a zero-duration real timer;
// unmount and elapse fake time so no test ends with pending timers.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  final now = DateTime.utc(2026, 8, 2, 10);

  testWidgets('app shell with home tiles and navigation bar', (tester) async {
    final semantics = tester.ensureSemantics();
    final appLock = AppLockController(
      authenticator: FakeBiometricAuthenticator(),
      storage: MemorySecureStorage(),
    );
    addTearDown(appLock.dispose);
    await appLock.load();

    await tester.pumpWidget(GitsuneApp(appLockController: appLock));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('home screen tiles', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const HomeScreen()));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('to-do list with rows and swipe triage', (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureTodosRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      _app(TodosScreen(repository: repository, now: now)),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('to-do reason filter sheet', (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureTodosRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      _app(TodosScreen(repository: repository, now: now)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('todo-filter-button')));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('to-do triage undo announces via a live region', (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureTodosRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      _app(TodosScreen(repository: repository, now: now)),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('todo-row-102')),
      const Offset(360, 0),
    );
    await tester.pumpAndSettle();

    // The snackbar is the silent state change; it must be a live region so
    // screen readers announce the triage and its undo affordance.
    final node = tester.getSemantics(find.text('To-do marked as done.'));
    expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('issue list', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        IssueListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: FixtureIssuesRepository(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('issue detail with thread and comment composer', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        IssueDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          issueIid: 142,
          repository: FixtureIssuesRepository(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('merge request list', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        MergeRequestListScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          repository: FixtureMergeRequestsRepository(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('merge request detail with merge box', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        MergeRequestDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: FixtureMergeRequestsRepository(),
          now: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('merge request changes (diff review)', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        MergeRequestChangesScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          mergeIid: 142,
          repository: FixtureMergeRequestsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('pipeline detail with job actions', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        PipelineDetailScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          pipelineId: 88123,
          repository: FixturePipelinesRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('job log', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        JobLogScreen(
          projectId: 7,
          jobId: 502,
          repository: FixturePipelinesRepository(),
          job: const PipelineJob(
            id: 502,
            name: 'test:flutter',
            stage: 'test',
            status: CiStatus.running,
            allowFailure: false,
          ),
          ref: 'feat/status-surface',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('repository tree', (tester) async {
    final semantics = tester.ensureSemantics();
    final router = buildAppRouter(
      repositoryTreeRepository: FixtureRepositoryTreeRepository(),
      initialLocation: '/projects/7/tree?projectPath=gitsune%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('file view', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        FileViewScreen(
          projectId: 7,
          projectPath: 'gitsune/app',
          filePath: 'lib/core/app_theme.dart',
          repository: FixtureRepositoryTreeRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('search with grouped results', (tester) async {
    final semantics = tester.ensureSemantics();
    final repository = FixtureSearchRepository(
      projects: [
        SearchProject.fromJson(const {
          'id': 7,
          'name': 'app',
          'name_with_namespace': 'gitsune / app',
          'description': 'The Gitsune mobile client.',
          'star_count': 12,
        }),
      ],
      issues: [
        Issue.fromJson(const {
          'id': 1420,
          'project_id': 7,
          'iid': 142,
          'title': 'Keep draft comments after reconnecting',
          'state': 'opened',
          'author': {'id': 11, 'username': 'marin', 'name': 'Marin Alvarez'},
          'created_at': '2026-07-30T10:00:00Z',
          'updated_at': '2026-08-02T08:30:00Z',
          'labels': <dynamic>[],
          'assignees': <dynamic>[],
          'user_notes_count': 2,
        }),
      ],
      mergeRequests: [
        SearchMergeRequest.fromJson(const {
          'id': 5201,
          'project_id': 7,
          'iid': 88,
          'title': 'Retry offline queue after reconnect',
          'state': 'opened',
          'author': {'id': 11, 'username': 'marin', 'name': 'Marin Alvarez'},
          'created_at': '2026-07-28T09:00:00Z',
          'updated_at': '2026-08-01T14:00:00Z',
          'labels': <dynamic>[],
          'user_notes_count': 4,
        }),
      ],
      blobs: [
        SearchBlob.fromJson(const {
          'basename': 'offline_first_repository',
          'data':
              'abstract class OfflineFirstRepository<T> {\n'
              '  Future<T> refresh();\n'
              '}\n',
          'path': 'lib/core/repository/offline_first_repository.dart',
          'filename': 'lib/core/repository/offline_first_repository.dart',
          'ref': 'main',
          'startline': 14,
          'project_id': 7,
        }),
      ],
    );
    await tester.pumpWidget(
      _app(SearchScreen(repository: repository, now: now)),
    );
    await tester.enterText(find.byType(TextField), 'offline');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('release list and detail', (tester) async {
    final semantics = tester.ensureSemantics();
    final router = buildAppRouter(
      releasesRepository: FixtureReleasesRepository(),
      initialLocation: '/projects/7/releases?projectPath=acme%2Fapp',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);

    await tester.tap(find.text('Version 1.2.0'));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('accounts screen', (tester) async {
    final semantics = tester.ensureSemantics();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final sessions = AccountSessions(database);
    const alice = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
    const bob = AccountKey(instanceHost: 'gitlab.example.com', accountId: '2');
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    final activeAccount = ActiveAccountStore(storage: MemorySecureStorage());
    await activeAccount.setActive(alice);

    await tester.pumpWidget(
      _app(
        AccountsScreen(
          sessions: sessions,
          activeAccount: activeAccount,
          tokenStore: SecureTokenStore(storage: MemorySecureStorage()),
          onAddAccount: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    await _unmount(tester);
    semantics.dispose();
  });

  testWidgets('account quick-switch sheet', (tester) async {
    final semantics = tester.ensureSemantics();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final sessions = AccountSessions(database);
    const alice = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
    const bob = AccountKey(instanceHost: 'gitlab.example.com', accountId: '2');
    await sessions.signedIn(alice);
    await sessions.signedIn(bob);
    final activeAccount = ActiveAccountStore(storage: MemorySecureStorage());
    await activeAccount.setActive(alice);

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showAccountSwitchSheet(
                  context,
                  sessions: sessions,
                  activeAccount: activeAccount,
                ),
                child: const Text('Switch'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    await _unmount(tester);
    semantics.dispose();
  });

  testWidgets('sign-in screen', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const SignInScreen()));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('profile screen', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = AppLockController(
      authenticator: FakeBiometricAuthenticator(),
      storage: MemorySecureStorage(),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(ProfileScreen(appLockController: controller)));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('quiet hours settings', (tester) async {
    final semantics = tester.ensureSemantics();
    const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = QuietHoursStore(database: database, account: account);
    await store.save(QuietHours.defaults.copyWith(enabled: true));

    await tester.pumpWidget(_app(QuietHoursScreen(store: store)));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    await _unmount(tester);
    semantics.dispose();
  });

  testWidgets('push delivery settings', (tester) async {
    final semantics = tester.ensureSemantics();
    const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final controller = PushDeliveryController(
      store: PushDeliveryStore(database: database, account: account),
      gateway: _NoopPushGateway(),
      notifier: _SilentNotifier(),
      account: account,
    );
    await controller.load();
    await controller.setEnabled(true);

    await tester.pumpWidget(_app(PushDeliveryScreen(controller: controller)));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    await _unmount(tester);
    semantics.dispose();
  });

  testWidgets('relay wizard settings', (tester) async {
    final semantics = tester.ensureSemantics();
    const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = RelaySetupStore(database: database, account: account);
    await store.save(RelaySetup.defaults.copyWith(enabled: true));

    await tester.pumpWidget(_app(RelayWizardScreen(store: store)));
    await tester.pumpAndSettle();

    await expectMeetsA11yGuidelines(tester);
    await _unmount(tester);
    semantics.dispose();
  });
}
