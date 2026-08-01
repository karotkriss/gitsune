# 1. Authentication posture: OAuth-first, guided self-hosted registration, PAT fallback

- Status: accepted
- Date: 2026-08-01

## Context

GitLab supports OAuth2 Authorization Code with PKCE for public clients, and GitLab itself recommends PKCE for mobile and desktop apps that cannot hold a client secret.
The complication is that OAuth app identity in GitLab is instance-local by design: a `client_id` registered on gitlab.com only works against gitlab.com, and a self-hosted instance requires its own separately registered OAuth application.
GitLab has work in progress toward dynamic client registration (RFC 7591), but as of this writing that capability is fenced to a specific protocol integration and is not available to general third-party apps.
There is no way to silently register an OAuth client against an arbitrary self-hosted instance today.

The two realistic paths into any given instance are OAuth with a registered application, or a Personal Access Token pasted in by the user.
PAT entry is zero-registration and works against every instance unconditionally, which makes it tempting as the default, but it is also the weaker credential: it is a long-lived bearer secret the user has to generate and manage by hand, and it is the credential type responsible for the most common self-hosted sign-in failures in existing GitLab mobile clients.
The GitLab CLI (`glab`) already ships a production OAuth flow with exactly this shape: a baked-in client ID for gitlab.com, a per-host override for self-hosted instances, PKCE throughout, and rotating refresh tokens persisted to secure storage.
That flow is a proven, GitLab-native precedent for a mobile client to follow, with one necessary adaptation: `glab` uses a local loopback HTTP listener for its redirect, which a desktop CLI can do but a mobile app cannot; a mobile client needs a custom URI scheme redirect instead, with PKCE closing the hijack risk that an unprotected custom scheme would otherwise carry.

## Decision

Gitsune uses OAuth2 Authorization Code with PKCE as the primary sign-in method on both gitlab.com and self-hosted instances.

On gitlab.com, sign-in is one tap: the app ships with a single pre-registered OAuth application and its `client_id` baked in, so there is nothing for the user to configure.

On a self-hosted instance, sign-in walks the user through a guided registration flow: the app tells the user exactly what to enter (an application name, the app's fixed redirect URI, scopes, and the requirement to leave the application public/non-confidential) on their own instance's Applications settings page, which any user can reach without admin rights, and the user pastes back only the resulting Application ID.
The app never asks for or stores the application secret, because it registers as a public client.

A Personal Access Token remains available as a fallback, but it is deliberately de-emphasized: it lives behind a secondary "having trouble signing in" affordance rather than on the primary sign-in screen, and it exists specifically for instances where an administrator has disabled user-level OAuth application creation and the signed-in user is not an admin.
On such an instance, OAuth registration is structurally impossible, and the PAT path is the only way in.

All sign-in flows run in the operating system's own browser (not an embedded web view), so that instance SSO, SAML, and multi-factor authentication behave exactly as they do on the web.

## Consequences

Self-hosted sign-in is not one-tap the way gitlab.com sign-in is; it costs the user a short guided setup the first time they connect a self-hosted instance.
That cost is accepted because it directly addresses the sign-in reliability problems that have plagued existing GitLab mobile clients, and because a guided flow with clear failure messaging is a materially better experience than either a broken assumption of portability or a token field with no explanation.

The app must implement multi-account, multi-instance session management: each signed-in account is keyed by its instance and account identifier, tokens are stored in the platform's secure credential store, refresh is handled per account with the rotation behavior GitLab's OAuth implementation requires, and a failed refresh on one account never signs the user out of every other account.

If GitLab's dynamic client registration work ever widens beyond its current fencing, Gitsune's self-hosted onboarding can adopt silent registration without changing the underlying OAuth flow, since the guided-registration step is the only piece that would be replaced.

See `docs/research/auth-blueprint.md` for the full implementation-level detail behind this decision.
