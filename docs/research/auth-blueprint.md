# Authentication blueprint

This document is the implementation-level detail behind `docs/decisions/0001-auth-posture.md`: how OAuth2 with PKCE works end to end for both gitlab.com and self-hosted instances, the exact shape of the self-hosted registration wizard, session and refresh handling, and every edge case identified so far.

Claims are sourced inline: a citation into GitLab's own CLI source code (`glab`, read from a public clone), a docs.gitlab.com page, or `flutter_appauth` package documentation.
Claims not backed by one of those are marked `[inferred]`.

## The precedent: how GitLab's own CLI does OAuth

GitLab's own command-line tool, `glab`, already ships a production OAuth2-with-PKCE flow, and it is the direct model for Gitsune's approach, verified by reading its source directly.

The flow, end to end:

1. **Resolve the client ID.** On gitlab.com, `glab` uses a baked-in default client ID.
   On a self-hosted instance, it reads a `client_id` the user has configured locally; if none is set, it errors with a clear instruction to configure one first.
2. **Resolve the OAuth endpoints.** gitlab.com uses fixed, well-known endpoints.
   A self-hosted instance's endpoints are derived directly from the instance's base URL (`<base>/oauth/authorize`, `<base>/oauth/token`).
3. **Run Authorization Code with PKCE against a local callback.** `glab` generates a random state value and a PKCE code verifier, builds the authorization URL with an S256 PKCE challenge, opens the system browser, and on callback validates the state, requires a non-empty authorization code, and exchanges it for tokens by sending the code verifier, with no client secret involved at all, since this is a public client.
4. **Persist the token.** The access token, refresh token, and expiry are written to local, OS-appropriate secure storage, using the operating system's keyring where one is available.

`glab` also refreshes lazily: rather than refreshing on a timer, it re-checks the stored token's expiry each time an API call needs one, and refreshes on demand when needed, persisting the newly rotated refresh token every time, since GitLab invalidates the old refresh token on every use.

`glab`'s redirect uses a local loopback HTTP listener, which a desktop command-line tool can run but a mobile app cannot.
That is the one piece Gitsune's mobile implementation changes; everything else, the baked default client ID for gitlab.com, the per-instance client ID override for self-hosted, S256 PKCE, rotate-and-persist refresh, and storage in the OS's secure credential store, carries over directly.

Source: gitlab.com/gitlab-org/cli (the `glab` CLI's own OAuth implementation, read from a public clone); docs.gitlab.com/api/oauth2/.

## The mobile adaptation: the redirect

A mobile app cannot reliably run a local HTTP listener the way a desktop CLI can; the mobile equivalent of a redirect target is a custom URI scheme (or, with more setup cost, a verified web-linked redirect such as Android App Links or iOS Universal Links).

**Gitsune uses one custom URI scheme, identical on every instance.**
Because Gitsune owns the scheme, the redirect URI is the exact same fixed string whether the user is signing in to gitlab.com or any self-hosted instance, which is what lets the self-hosted wizard show the user one copy-pasteable value.

A custom scheme has no operating-system-enforced ownership on its own, which is the classic hijack risk with this approach, but PKCE closes that hole: an attacker who intercepts the redirect only gets an authorization code, which is worthless without the code verifier held only inside the legitimate app.
This is exactly why GitLab's own CLI already uses PKCE, and it is why PKCE is treated as non-negotiable here.

GitLab's OAuth implementation does accept non-HTTPS custom-scheme redirect URIs; this is an established pattern (GitLab has, for example, allowlisted the pattern in its content security policy specifically to support editor integrations using a custom scheme), though a hardened self-managed instance could in principle be configured to reject one, which the self-hosted wizard needs to handle gracefully as a failure case rather than assume never happens.

The `flutter_appauth` package implements this cleanly on both platforms: it registers the redirect scheme through standard Android and iOS build configuration, generates the PKCE verifier and challenge automatically, and, critically, opens the system browser (Safari's authentication session view on iOS, Chrome Custom Tabs on Android) rather than an embedded web view.
Using the system browser, not an embedded web view, is essential: it is what makes existing instance sessions, single sign-on redirects, and multi-factor authentication prompts work exactly as they do on the web, and increasingly, some identity providers actively block embedded web views for security reasons.

Sources: docs.gitlab.com/api/oauth2/; flutter_appauth package documentation (pub.dev/packages/flutter_appauth); GitLab's own VS Code integration, which registers a custom-scheme redirect against GitLab OAuth as a public precedent for this pattern.

## Authorization and token flow

```text
Sign-in (gitlab.com):
  the app has a baked-in client ID for gitlab.com
        |
        v
  the app requests authorization + token exchange with:
     redirect = <gitsune's fixed custom scheme>://oauth-callback
     authorize endpoint = https://gitlab.com/oauth/authorize
     token endpoint     = https://gitlab.com/oauth/token
     scopes = [api, read_user]
     PKCE S256, generated automatically
        |
   the system browser opens GitLab's sign-in page
        |
   the user signs in (password, SSO, multi-factor - all happen here, in the browser)
        |
   GitLab redirects back to the app's custom scheme with a code and state
        |
   the app validates state, exchanges the code + PKCE verifier for tokens
   (no client secret sent - this is a public client)
   then resolves the signed-in account through GET /api/v4/user
        |
        v
   access token, refresh token, and expiry are returned and stored
   as one value in the platform's secure credential store, namespaced by
   the instance host and GitLab account ID

Sign-in (a self-hosted instance):
  identical, except:
   - the client ID comes from the wizard (the user pastes their instance's
     Application ID), not a baked-in value
   - the authorize/token endpoints are derived from the instance's own URL
   - the instance URL must use HTTPS

Refreshing a token (any account):
  the app sends the stored refresh token to the instance's token endpoint
  (no PKCE verifier needed for a refresh - only the initial code exchange needs it)
        |
        v
  a NEW access token and a NEW refresh token come back, and the old pair
  is invalidated - both stored tokens must be replaced atomically
```

Facts pinned to source: GitLab's documented default access-token lifetime is two hours, with a rotating refresh token that invalidates the previous pair on every use; refresh does not require the original PKCE code verifier.
Source: docs.gitlab.com/api/oauth2/.

## The self-hosted registration wizard

This is the guided flow a user walks through the first time they connect a self-hosted instance and choose OAuth (gitlab.com skips this entirely, since its client ID is baked in).
The goal is to get the user to a valid client ID with the least possible friction, and to fail gracefully into the Personal Access Token fallback when an instance's policy makes OAuth registration impossible.

**What the user is creating:** an OAuth application on their own GitLab instance, at user scope, which does not require administrator rights.
GitLab exposes this under the user's own profile settings (an "Applications" page reachable without any special permission); a group- or instance-wide equivalent also exists for administrators who want to register one application that serves every user on the instance, which the wizard can surface as an alternative for administrators.

**The fields the wizard tells the user to enter:**

| Field | What the wizard supplies | Why |
| --- | --- | --- |
| Name | A suggested, recognizable name | Free text; helps the user recognize the application later |
| Redirect URI | Gitsune's fixed custom-scheme redirect | Must match byte-for-byte; the wizard shows a copy button and warns against extra whitespace |
| Confidential | Unchecked | Gitsune is a public client with no secret; leaving this checked breaks the flow |
| Scopes | `api` and `read_user` | Grants the read/write API access and user identity access Gitsune requires |
| Expire access tokens | Left at its default (on) | Gitsune depends on GitLab's standard expiring-token-plus-refresh behavior |

After saving, GitLab shows an Application ID, which is all the wizard asks the user to paste back; it never asks for or stores the accompanying secret, since the application is registered as public.
The wizard trims surrounding whitespace from the pasted ID, rejects interior whitespace, and rejects values with GitLab's `gloas-` application-secret prefix.

**Every failure the wizard needs to handle gracefully:**

1. **Registration is disabled by instance policy**, or the signed-in user lacks the rights to create one. This is the one structural boundary of Gitsune's OAuth-first approach: on such an instance, OAuth registration is simply not possible, and the wizard routes the user directly to the Personal Access Token fallback.
2. **The instance is too old** for a needed piece of OAuth behavior; PKCE support has been present for long enough that this is unlikely on any currently supported GitLab version, but the wizard degrades to the PAT path if it detects an incompatibility.
3. **The redirect URI does not match exactly**, which GitLab reports as an explicit "invalid redirect URI" error; the wizard re-displays the exact expected string.
4. **The Confidential checkbox was left checked**, which makes the server expect a client secret Gitsune will never send; the wizard explains this specific fix.
5. **A scope mismatch**; the wizard tells the user to select both `api` and `read_user`.
6. **A paste error**, such as accidental whitespace in the pasted Application ID; the wizard trims and validates the format before storing it.

Source: docs.gitlab.com/integration/oauth_provider/ (application registration paths and fields); GitLab's documentation on public-client OAuth application setup (clearing the confidential checkbox).

## Sessions, refresh, and the token-fallback boundary

Access tokens are short-lived (around two hours by GitLab's default) with rotating refresh tokens, so refresh logic needs to be reliable rather than an afterthought.
The implementation refreshes lazily when a stored token is within 30 seconds of expiry, reads the replacement expiry from the server's `expires_in`, and retries exactly once after an unexpected 401 before surfacing an authentication failure.
Access token, refresh token, and expiry are encoded in one JSON value and replaced in one secure-storage write, so readers never observe a partially rotated token pair.
Tokens without a refresh token are sent as-is even after expiry so the resulting 401 surfaces as the authentication failure.
Refresh is single-flight per account, so concurrent requests await one refresh instead of spending the same single-use refresh token more than once.
A 401 refresh call carries the rejected access token; if another request has already stored a newer token, a straggler reuses that token without refreshing again.
A failed refresh returns no token and leaves the stored value untouched; E2.6 owns marking that account for re-authentication.

When a refresh genuinely fails (the user revoked the app, an administrator rotated credentials, or a single-sign-on session expired), Gitsune does not sign the user out of every connected account.
The E2.6 session model will mark only that one account as needing re-authentication, keep it visible in the account switcher, and prompt re-authentication scoped to that account while preserving the current screen.

**The Personal Access Token fallback stays deliberately minimal.**
It exists specifically for the one structural case where OAuth-first cannot work: an instance that forbids user-level OAuth application creation, where the signed-in user is not an administrator either.
It is never presented as an equal alternative to OAuth on the primary sign-in screen; it lives behind a secondary "having trouble signing in" affordance.
The fallback asks for a PAT with the `api` scope, validates it through `GET /api/v4/user` using the same `Authorization: Bearer` form used for subsequent API requests, and uses the returned account ID with the instance host as the token's composite storage key.
Once validated, the PAT is stored as an access token in the platform secure credential store with no refresh token and no expiry.
Personal Access Tokens do not refresh, so a failed request on a token-based account goes straight to "re-enter your token" rather than attempting a refresh.

## Edge cases

| Edge case | What happens | How Gitsune handles it |
| --- | --- | --- |
| Single sign-on or SAML-fronted instance | The authorization step runs in the system browser, so the instance's identity-provider redirect, cookies, and any existing session all work exactly as they do on the web | No special handling needed; this is the core reason the system-browser flow is required rather than optional |
| Multi-factor authentication | Handled entirely inside the system browser during sign-in | No special handling needed |
| Group-level single sign-on enforcement | OAuth applications work with group-level SSO enforcement on current GitLab versions; older versions may reject a token against an SSO-enforced group until a browser session is established | Surface a clear "sign in to your group's SSO first" prompt if this specific failure occurs on an older instance |
| Short or custom access-token lifetimes set by an administrator | Gitsune already reads the token lifetime from the server's response rather than assuming two hours | No special handling needed beyond driving refresh off the actual returned expiry |
| Registration disabled by administrator policy | OAuth-first is not possible on that instance | Route to the Personal Access Token fallback, per the wizard's first failure case above |
| An unusually hardened instance rejects the non-HTTPS custom-scheme redirect | Registration fails with an invalid-redirect error | Offer a verified web-linked redirect (Android App Links / iOS Universal Links) as an alternative registration path |

## Implementation summary

- **Packages:** `flutter_appauth` for the OAuth2-with-PKCE flow using the system browser and explicit (not auto-discovered) endpoints, and `flutter_secure_storage` for token storage in the platform's Keychain or Keystore-backed secure storage.
- **Shipped configuration:** one baked-in gitlab.com client ID, registered once by this project, and one fixed custom URI scheme used identically on every instance.
- **Per-instance endpoint derivation:** the authorize and token endpoints are always derived from the instance's own base URL, following the same trimming rules GitLab's own CLI uses.
- **Requested scopes:** `api read_user`.
- **Non-negotiables:** never embed a web view for sign-in; never disable PKCE; never store a client secret on the device; never silently fall back from a failed OAuth account to a Personal Access Token; never put the Personal Access Token option on the primary sign-in screen; never hardcode a fixed token lifetime instead of reading the server's actual response.
