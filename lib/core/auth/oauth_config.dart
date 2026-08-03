/// OAuth2 configuration for GitLab sign-in.
///
/// Gitsune is a public OAuth client using Authorization Code + PKCE
/// (`docs/research/auth-blueprint.md`): no client secret exists anywhere in
/// the app, so the Application IDs here are public identifiers, safe to ship
/// in source.
library;

/// Gitsune's registered gitlab.com OAuth application (public client, PKCE).
const gitlabComClientId =
    '3a81e41d6dfc8fb4b4cadcfc2ef5fd6963efed145591ceef69ce5bf0ec4d82b0';

/// Gitsune's fixed custom-scheme redirect, byte-identical on every instance
/// (the E2.3 self-hosted wizard shows the user this exact string).
///
/// The scheme derives from the app org `dev.gitsune`. It is registered
/// natively via the `appAuthRedirectScheme` manifest placeholder in
/// `android/app/build.gradle.kts` and `CFBundleURLTypes` in
/// `ios/Runner/Info.plist`; keep all three in sync.
const oauthRedirectUri = 'dev.gitsune://oauth-callback';

/// Read/write scopes per the auth blueprint (`read_api` read-only mode is a
/// later, separate offering).
const oauthScopes = ['api', 'read_user'];

/// One instance's OAuth endpoints and client ID.
class GitLabOAuthConfig {
  const GitLabOAuthConfig({
    required this.clientId,
    required this.authorizeEndpoint,
    required this.tokenEndpoint,
  });

  /// gitlab.com's baked-in configuration. A self-hosted instance instead
  /// derives endpoints from its base URL and takes the user's pasted
  /// Application ID (E2.2).
  static final gitlabCom = GitLabOAuthConfig(
    clientId: gitlabComClientId,
    authorizeEndpoint: Uri.parse('https://gitlab.com/oauth/authorize'),
    tokenEndpoint: Uri.parse('https://gitlab.com/oauth/token'),
  );

  final String clientId;
  final Uri authorizeEndpoint;
  final Uri tokenEndpoint;
}
