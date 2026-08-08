# App Store Connect App Privacy answers

These are the answers to paste into App Store Connect's App Privacy section.
They are derived from the app's actual behavior: `docs/decisions/0002-notification-architecture.md` (no project-operated servers), `lib/core/auth/token_store.dart` (tokens in the iOS Keychain via `flutter_secure_storage`), and the absence of any analytics, crash-reporting, or tracking dependency in `pubspec.yaml`.
Re-verify against the dependency list before each submission.

## Declaration

**Data Not Collected** - for every category Apple lists (Contact Info, Health & Fitness, Financial Info, Location, Sensitive Info, Contacts, User Content, Browsing History, Search History, Identifiers, Purchases, Usage Data, Diagnostics, Other Data).

**Tracking:** the app does not track users, so no App Tracking Transparency prompt is used or needed.

## Why "Data Not Collected" is the truthful answer

Apple's definition of "collect" is transmitting data off the device in a way that is accessible to the developer or their partners.
Gitsune transmits data only to the GitLab instance the user explicitly signs into, and - only when the user opts in through the relay wizard - to a push relay service the user chooses and controls (their own ntfy account or Pushover).
The developer operates no servers of any kind and receives nothing.
There is no analytics SDK, no crash reporter, no advertising SDK, and no third-party SDK that phones home.

## Data stored on device only

- OAuth tokens and Personal Access Tokens: iOS Keychain (`flutter_secure_storage`).
- Cached GitLab content (issues, merge requests, pipelines, to-dos, comment drafts): local SQLite database, scoped per account, deleted when the account is removed in-app or the app is deleted.
- Face ID / Touch ID: handled entirely by the operating system through `local_auth`; the app never accesses biometric data.
  `NSFaceIDUsageDescription` is declared in `ios/Runner/Info.plist`.
