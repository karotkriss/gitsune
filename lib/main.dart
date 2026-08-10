import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/account_sessions.dart';
import 'core/auth/active_account.dart';
import 'core/auth/gitlab_oauth.dart';
import 'core/auth/oauth_config.dart';
import 'core/auth/pat_auth.dart';
import 'core/auth/token_refresh.dart';
import 'core/auth/token_store.dart';
import 'core/database/app_database.dart';
import 'core/lock/app_lock.dart';
import 'core/lock/app_lock_gate.dart';
import 'core/network/account_key.dart';
import 'core/network/gitlab_client.dart';
import 'core/repository/offline_first_repository.dart';
import 'core/repository/recently_viewed_repository.dart';
import 'core/repository/todos_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/code/data/repository_tree_repository.dart';
import 'features/home/home_tiles.dart';
import 'features/issues/data/comment_draft_queue.dart';
import 'features/issues/data/issues_repository.dart';
import 'features/merge_requests/data/merge_requests_repository.dart';
import 'features/pipelines/data/pipelines_repository.dart';
import 'features/releases/data/releases_repository.dart';
import 'features/search/data/search_repository.dart';
import 'features/shell/app_shell.dart';

void main() {
  runApp(const ProviderScope(child: GitsuneApp()));
}

/// The composition root: it owns the account registry, the active-account
/// choice, token storage/refresh, and the local database, and it assembles the
/// router for the current signed-in state.
///
/// At startup it loads the persisted active account (the signed-in gate) and
/// builds the signed-in router - with the account-scoped GitLab client and
/// every feature repository bound to that account - when one exists, or the
/// signed-out router otherwise. A completed sign-in (gitlab.com OAuth, the
/// self-hosted wizard, or the PAT fallback) registers the session and makes it
/// active, and that active-account change rebuilds the router into the
/// signed-in app: sign-in produces a live, data-loading app instead of a
/// silent no-op.
///
/// Every collaborator is an injectable seam defaulting to production, so tests
/// drive the whole flow without a browser, a live instance, or platform
/// storage.
class GitsuneApp extends StatefulWidget {
  const GitsuneApp({
    super.key,
    this.appLockController,
    this.database,
    this.tokenStore,
    this.activeAccount,
    this.clientBaseUrl,
    this.signInGitlabCom,
    this.signInSelfHosted,
    this.signInWithToken,
    this.issuesRepository,
    this.todosRepository,
  });

  final AppLockController? appLockController;

  /// The shared local database (one per app, account-scoped by column). Tests
  /// inject an in-memory database; production opens the on-device one lazily.
  final AppDatabase? database;

  /// Per-account secure token storage, read by the refresh coordinator.
  final TokenStore? tokenStore;

  /// The persisted active-account choice; changing it rebuilds the router.
  final ActiveAccountStore? activeAccount;

  /// Points the account-scoped GitLab client at a fake server for tests;
  /// production resolves each account's own instance host.
  final Uri? clientBaseUrl;

  /// gitlab.com OAuth, defaulting to the system-browser flow. Tests inject a
  /// fake so no browser is reached.
  final Future<SignedInAccount> Function()? signInGitlabCom;

  /// Self-hosted OAuth for a validated Application ID, defaulting to the real
  /// flow.
  final Future<SignedInAccount> Function(Uri base, String applicationId)?
  signInSelfHosted;

  /// Personal Access Token sign-in, defaulting to the real validation flow.
  final Future<SignedInAccount> Function(Uri base, String token)?
  signInWithToken;

  /// Overrides the account-scoped issues repository (tests inject a fake).
  final IssuesRepository? issuesRepository;

  /// Overrides the account-scoped to-dos repository (tests inject a fake).
  final OfflineFirstRepository<List<TodoItem>>? todosRepository;

  @override
  State<GitsuneApp> createState() => _GitsuneAppState();
}

class _GitsuneAppState extends State<GitsuneApp> {
  late final AppLockController _appLock =
      widget.appLockController ??
      AppLockController(authenticator: LocalAuthBiometricAuthenticator());

  late final TokenStore _tokenStore = widget.tokenStore ?? SecureTokenStore();
  late final ActiveAccountStore _activeAccount =
      widget.activeAccount ?? ActiveAccountStore();
  bool get _ownsActiveAccount => widget.activeAccount == null;

  // The database and its dependents are created lazily so a signed-out session
  // (including every shell test that never signs in) never opens the on-device
  // database.
  AppDatabase? _databaseInstance;
  AppDatabase get _database =>
      _databaseInstance ??= widget.database ?? AppDatabase();
  bool get _ownsDatabase => widget.database == null;

  AccountSessions? _sessionsInstance;
  AccountSessions get _sessions =>
      _sessionsInstance ??= AccountSessions(_database);

  TokenRefreshCoordinator? _refreshInstance;
  TokenRefreshCoordinator get _refresh =>
      _refreshInstance ??= TokenRefreshCoordinator(
        tokenStore: _tokenStore,
        configFor: _configFor,
        onReauthRequired: _sessions.markNeedsReauth,
      );

  bool _loaded = false;
  GoRouter? _router;
  AccountKey? _account;

  @override
  void initState() {
    super.initState();
    _appLock.load();
    _activeAccount.addListener(_onActiveAccountChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _activeAccount.load();
    if (!mounted) return;
    setState(() {
      _account = _activeAccount.value;
      _router = _buildRouter(_account);
      _loaded = true;
    });
  }

  void _onActiveAccountChanged() {
    if (!_loaded || _activeAccount.value == _account) return;
    final previous = _router;
    setState(() {
      _account = _activeAccount.value;
      _router = _buildRouter(_account);
    });
    // Dispose the replaced router after the new keyed subtree has mounted, so
    // the unmounting Router never touches an already-disposed config.
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  @override
  void dispose() {
    _activeAccount.removeListener(_onActiveAccountChanged);
    _router?.dispose();
    if (_ownsActiveAccount) _activeAccount.dispose();
    if (widget.appLockController == null) _appLock.dispose();
    if (_ownsDatabase && _databaseInstance != null) {
      unawaited(_databaseInstance!.close());
    }
    super.dispose();
  }

  GitLabOAuthConfig _configFor(AccountKey account) {
    if (account.instanceHost == 'gitlab.com') {
      return GitLabOAuthConfig.gitlabCom;
    }
    // ponytail: self-hosted OAuth refresh needs the instance's Application ID,
    // which isn't persisted (PAT sessions never refresh, gitlab.com uses the
    // baked-in client). Deriving the endpoints keeps gitlab.com and PAT correct
    // while a self-hosted OAuth token that can't refresh falls back to re-auth.
    // Upgrade path: persist the Application ID at sign-in and thread it here.
    final base = Uri.https(account.instanceHost);
    return GitLabOAuthConfig(
      clientId: gitlabComClientId,
      authorizeEndpoint: base.replace(path: '/oauth/authorize'),
      tokenEndpoint: base.replace(path: '/oauth/token'),
    );
  }

  Future<SignedInAccount> _defaultGitlabCom() => GitLabOAuth(
    config: GitLabOAuthConfig.gitlabCom,
    tokenStore: _tokenStore,
  ).signIn();

  Future<SignedInAccount> _defaultSelfHosted(Uri base, String applicationId) =>
      GitLabOAuth(
        config: GitLabOAuthConfig.selfHosted(
          baseUrl: base,
          applicationId: applicationId,
        ),
        tokenStore: _tokenStore,
      ).signIn();

  Future<SignedInAccount> _defaultPat(Uri base, String token) =>
      signInWithPat(baseUrl: base, token: token, tokenStore: _tokenStore);

  /// The single completion every sign-in path funnels through: register the
  /// session, then make it active. The active-account change rebuilds the
  /// router into the signed-in app.
  Future<void> _completeSignIn(SignedInAccount signedIn) async {
    await _sessions.signedIn(signedIn.account);
    await _activeAccount.setActive(signedIn.account);
  }

  Future<void> _signInGitlabCom() async =>
      _completeSignIn(await (widget.signInGitlabCom ?? _defaultGitlabCom)());

  Future<void> _signInSelfHosted(Uri base, String applicationId) async =>
      _completeSignIn(
        await (widget.signInSelfHosted ?? _defaultSelfHosted)(
          base,
          applicationId,
        ),
      );

  Future<void> _signInWithToken(Uri base, String token) async =>
      _completeSignIn(
        await (widget.signInWithToken ?? _defaultPat)(base, token),
      );

  GoRouter _buildRouter(AccountKey? account) {
    if (account == null) {
      return buildAppRouter(
        appLockController: _appLock,
        signIn: _signInGitlabCom,
        signInSelfHosted: _signInSelfHosted,
        signInWithToken: _signInWithToken,
        issuesRepository: widget.issuesRepository,
        todosRepository: widget.todosRepository,
      );
    }

    final client = createGitLabClient(
      account: account,
      readToken: _refresh.readToken,
      refreshToken: _refresh.refreshToken,
      baseUrl: widget.clientBaseUrl,
    );
    final issues = widget.issuesRepository ?? GitLabIssuesRepository(client);
    final todos =
        widget.todosRepository ??
        TodosRepository(database: _database, client: client, account: account);

    return buildAppRouter(
      appLockController: _appLock,
      accountSessions: _sessions,
      activeAccountStore: _activeAccount,
      tokenStore: _tokenStore,
      signIn: _signInGitlabCom,
      signInSelfHosted: _signInSelfHosted,
      signInWithToken: _signInWithToken,
      homeTileOrderStore: HomeTileOrderStore(
        database: _database,
        account: account,
      ),
      issuesRepository: issues,
      commentDraftQueue: CommentDraftQueue(
        database: _database,
        account: account,
        repository: issues,
        // Reconnect-triggered flush stays deliberately unwired (see
        // CommentDraftQueue); drafts still persist and flush on the next send.
        onReconnect: const Stream.empty(),
      ),
      mergeRequestsRepository: GitLabMergeRequestsRepository(client),
      pipelinesRepository: GitLabPipelinesRepository(client),
      releasesRepository: GitLabReleasesRepository(
        database: _database,
        client: client,
        account: account,
      ),
      repositoryTreeRepository: GitLabRepositoryTreeRepository(
        database: _database,
        client: client,
        account: account,
      ),
      searchRepository: GitLabSearchRepository(client),
      todosRepository: todos,
      recentlyViewedCache: RecentlyViewedCache(
        database: _database,
        account: account,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _router == null) {
      return MaterialApp(
        title: 'Gitsune',
        theme: buildAppTheme(),
        home: const Scaffold(body: SizedBox.shrink()),
      );
    }
    return MaterialApp.router(
      // A fresh Router subtree per active account so switching (or signing in
      // and out) never reuses the previous account's routes or navigation.
      key: ValueKey(_account),
      title: 'Gitsune',
      theme: buildAppTheme(),
      routerConfig: _router,
      builder: (context, child) =>
          AppLockGate(controller: _appLock, child: child!),
    );
  }
}
