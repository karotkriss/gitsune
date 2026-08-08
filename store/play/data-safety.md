# Google Play Data safety questionnaire answers

These are the answers to paste into Play Console's App content -> Data safety form.
They are derived from the app's actual behavior: `docs/decisions/0002-notification-architecture.md` (no project-operated servers), `lib/core/auth/token_store.dart` (tokens in platform secure storage via `flutter_secure_storage`), and the absence of any analytics, crash-reporting, or tracking dependency in `pubspec.yaml`.
Re-verify against the dependency list before each submission.

## Overview answers

| Question | Answer |
| --- | --- |
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not asked when nothing is collected; the app's own traffic is HTTPS/TLS in any case |
| Do you provide a way for users to request that their data is deleted? | Not asked when nothing is collected |

## Why "No" is the truthful answer

Play defines collection as transmitting user data off the device to the developer or to third parties acting on the developer's behalf.
Gitsune transmits data only:

- to the GitLab instance the user explicitly signs into (gitlab.com or their own self-hosted host), as the app's core, user-visible function; the developer operates no servers and receives nothing, and
- if and only if the user opts in and configures it, to a push relay the user owns or chooses (their own ntfy server via UnifiedPush, or a relay account such as Pushover); Gitsune only generates the GitLab webhook configuration and registers for delivery - it never proxies or stores those messages.

Nothing is ever sent to the developer or to any service acting for the developer.
There is no analytics SDK, no crash reporter, no advertising SDK, and no tracking of any kind.

## Data stored on device only (not "collected" under Play's definition)

- OAuth tokens and Personal Access Tokens: Android Keystore-backed secure storage (`flutter_secure_storage`).
- Cached GitLab content (issues, merge requests, pipelines, to-dos, comment drafts): local SQLite database, scoped per account, deleted when the account is removed in-app or the app is uninstalled.
- Settings (quiet hours, tile order, app-lock toggle): local storage.

## Account handling

Gitsune does not create accounts; it signs into existing GitLab accounts.
Play's account-deletion requirement therefore does not apply.
Removing an account in-app deletes every locally cached row for that account (`AccountSessions.remove`).

## Permissions declared in the manifest

| Permission | Why |
| --- | --- |
| `INTERNET` | Talk to the GitLab instance the user signs into |
| `POST_NOTIFICATIONS` | Show local to-do notifications (Android 13+ runtime permission) |
| `USE_BIOMETRIC` | Optional biometric app lock |
