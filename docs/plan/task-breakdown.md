# Gitsune v1 task breakdown

This is the pickable-task companion to `docs/plan/roadmap.md`.
Tasks are grouped into epics; each task carries a one-line acceptance note and its dependencies, and each is sized so a single contributor can pick it up.
The `Phase` column ties each epic back to the roadmap phase that schedules it.

Dependencies reference other task IDs in this document.
"Design system landed" means the phase-two design system is in the repository, per `docs/plan/phase-plan.md`.
Every task inherits the operating principles in `docs/plan/roadmap.md` (fixtures-first, REST-primary, feature-first, account-scoped, no project-operated servers), so those are not repeated per task.

## Epic index

| Epic | Title | Phase |
| --- | --- | --- |
| E0 | Project foundation and CI | 0 |
| E1 | Design system integration and app shell | 0 |
| E2 | Authentication and sessions | 1 |
| E3 | API and data layer (core) | 0 to 1 |
| E4 | Rendering and content | 2 to 3 |
| E5 | Notifications inbox (To-Do List) | 2 |
| E6 | Issues | 2 |
| E7 | Merge request review and approval | 3 |
| E8 | CI/CD pipelines and jobs | 3 |
| E9 | Code browsing | 4 |
| E10 | Search | 4 |
| E11 | Releases | 4 |
| E12 | Notification delivery layers | 5 |
| E13 | Platform table stakes | 6 |
| E14 | Offline read cache and draft queue | 6 |
| E15 | Store launch and signing | 7 |
| E16 | Hardening | 7 |

---

## E0: Project foundation and CI (Phase 0)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E0.1 Scaffold Flutter project, feature-first single package, Riverpod wired | `flutter analyze` is clean on an app that boots to an empty themed screen, and the `core`-versus-feature boundary is enforced (features import `core`, never the reverse) | none |
| E0.2 Fixtures-first test harness: recorded-fixture loader, in-process fake HTTP server, golden infra (dark, font-stable) | one command runs unit, widget, and golden tests with no external network access and no secrets, and the suite includes passing sample fixture and golden tests | E0.1 |
| E0.3 GitHub Actions CI: format, analyze, test, build-sanity for Android and iOS, secret-free | PR CI is green on the scaffold for the Android and iOS build targets and references no secrets | E0.1, E0.2 |
| E0.4 F-Droid build-flavor scaffold with proprietary push dependencies removed | the F-Droid flavor builds in CI and contains no FCM or other proprietary push dependency | E0.1, E0.3 |

## E1: Design system integration and app shell (Phase 0)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E1.1 Design-token theme layer: tanuki-orange accent, dark-only, Pajamas semantic ramps, GitLab Sans and Mono | the theme exposes accent, semantic, and typography tokens, a token-swatch golden passes, and swapping the token file re-brands the app with no other code change | E0.1, design system landed |
| E1.2 Liquid-glass implementation spike (runs in parallel with E0/E1) | a chosen Flutter approach isolates modest app-wide and heavy overlay glass behind one seam, preserves full sigma-24 fidelity, and documents reproducible Impeller emulator evidence, its performance ceiling, and the open real-device validation | none |
| E1.3 App shell: four-tab bottom nav (Home, To-Dos/Notifications, Explore/Search, Profile), routing, empty themed screens | all four tabs navigate and a golden of each empty dark-theme screen passes | E1.1 |
| E1.4 Home shortcut-tile card (reorderable): Issues, MRs, To-Do List, Pipelines, Projects, Groups | tile rows render with Pajamas ramp colors and GitLab glyphs, reordering persists per account, and a golden passes | E1.3 |
| E1.5 Glass overlay components (modal, drawer, sheet) built on the spike's approach | overlay components render heavy glass within the spike's documented budget and a golden passes | E1.2, E1.3 |
| E1.6 Reconcile `docs/research/design-direction.md` with the closed design review | the doc no longer contradicts the shipped design system on interactive accent, theme scope, and liquid-glass adoption, with the superseded positions updated | design system landed |

## E2: Authentication and sessions (Phase 1)

Implementation detail: `docs/research/auth-blueprint.md`.

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E2.1 OAuth2 PKCE flow via `flutter_appauth`, system browser, custom-scheme redirect, no secret stored | gitlab.com one-tap sign-in completes in the system browser and stores a token, with no webview and no client secret | E3.1 |
| E2.2 Self-hosted endpoint derivation and client-ID override | authorize and token endpoints derive from a self-hosted base URL, and the pasted Application ID is used as the client ID | E2.1 |
| E2.3 Guided self-hosted registration wizard | the wizard walks the user through registration and accepts only the Application ID, and each named failure case (registration disabled, PKCE too old, redirect-URI mismatch, confidential left checked, scope mismatch, pasted whitespace) shows a correct, actionable message | E2.2 |
| E2.4 PAT fallback behind "having trouble signing in" | PAT sign-in works, is reachable only from the secondary affordance (never the primary screen), and a failed request routes to re-enter-token | E2.1 |
| E2.5 Secure token storage namespaced per account, with rotating refresh | tokens are stored per account in secure storage, and refresh reads the server's expiry, rotates single-use tokens atomically, retries a 401 exactly once, and never double-refreshes under concurrent requests | E2.1 |
| E2.6 Multi-account and multi-instance session model with failed-refresh isolation | accounts across instances coexist keyed by the composite key, and a failed refresh marks only that account for re-auth while keeping it in the switcher | E2.5 |
| E2.7 Sign-in screen: instance field visible and pre-filled `gitlab.com`, no credential fields, inline error on bad URL | the screen matches the design-direction sign-in surface, an unreachable or non-GitLab URL shows an inline error, and a golden passes | E2.1, E1.3 |

## E3: API and data layer / core (Phase 0 to 1)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E3.1 `dio` client skeleton: per-instance base URL, interceptor seams for token injection and one-time 401 refresh-and-retry | a request against the fake server injects a token and retries once on a 401, with the base URL resolved per account | E0.1, E0.2 |
| E3.2 `drift` (SQLite) local database scoped by instance and account | every row carries the composite key and two accounts' data never collide in tests | E0.1 |
| E3.3 Repository layer (offline-first seam): reactive DB stream, background network refresh, stale-while-revalidate | the UI reads a DB stream, a background refresh updates the DB, and the stream re-emits, covered by a unit test | E3.1, E3.2 |
| E3.4 Keyset/cursor pagination with a persisted resume token | fixture collections paginate without total-count headers and resume from a persisted token | E3.1 |

## E4: Rendering and content (Phase 2 to 3)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E4.1 Markdown renderer: `flutter_markdown_plus` plus GitLab references (`#123`, `!456`, `@user`, `~label`) | GitLab references resolve and render, covered by unit tests on reference resolution | E1.1 |
| E4.2 Markdown math and Mermaid support | math and Mermaid blocks render or degrade gracefully | E4.1 |
| E4.3 Diff-hunk parser: GitLab per-file unified-diff hunks into a colored line-by-line model | the parser turns fixture hunks into the correct add/remove/context line model, unit-tested | none |
| E4.4 Syntax-highlighting engine (`re_highlight`) and reusable source-view primitive | per-line highlighting works on diffs and full files, the reusable source view can hand oversized content to its WebView fallback, and a golden passes; `docs/research/technology-assessment.md` owns the repository file-view fallback contract | E4.3 |

## E5: Notifications inbox / To-Do List (Phase 2)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E5.1 Todos data layer (repository and reactive stream) on the Todos API | to-dos load, cache, and expose the reactive stream that the phase-five poller reuses | E3.3 |
| E5.2 To-Do List UI with swipe triage (done and snooze, with undo) and filter sheet by reason | the list triages by swipe with undo on every destructive swipe, filtering by reason works, and a golden passes | E5.1, E1.3 |
| E5.3 Open-underlying-item deep-linking with web fallback | opening a to-do routes to its in-app surface where present, otherwise to web | E5.2 |
| E5.4 Illustrated empty state | an empty To-Do List shows the illustrated empty state and a golden passes | E5.2 |

## E6: Issues (Phase 2)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E6.1 Issue list and detail (thread anatomy, metadata pills, scoped-label pills) | the issue view matches the design-direction anatomy and a golden passes | E3.3, E4.1 |
| E6.2 Issue create and comment | an issue can be created and a comment posted against the fake server, with markdown rendering in drafts | E6.1 |
| E6.3 Issue triage: label, assign, state change | label, assignee, and open/close changes persist and reflect as inline state-change events | E6.1 |

## E7: Merge request review and approval (Phase 3)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E7.1 MR list and detail shell (branch chips, collapsible Pipelines and Approvals sections) | the MR view renders monospace branch chips and collapsible sections, and a golden passes | E3.3, E4.1 |
| E7.2 Diff view with per-line highlighting, jump-to-file, and oversized-diff web fallback | diffs render with highlighting, jump-to-file works, and an oversized diff falls back to web | E4.3, E4.4, E7.1 |
| E7.3 Inline comments and thread resolution | line-level comments can be added and threads resolved against the fake server, and the unresolved count surfaces | E7.2 |
| E7.4 Approve/unapprove and merge box (pipeline, approval, mergeability, unresolved count; accent-colored merge) | the merge box reflects all four inputs, approve/unapprove and merge work, and an `integration_test` covers the review actions | E7.3, E8.1 |

## E8: CI/CD pipelines and jobs (Phase 3)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E8.1 Pipeline and job status surface (circular status badges) | pipeline and job status render with Pajamas status badges and a golden passes | E3.3 |
| E8.2 Job-log viewer | job logs scroll for a fixture job and long logs stay smooth | E8.1 |
| E8.3 Retry, cancel, and run-manual-job actions | each action fires the correct API call against the fake server and updates status | E8.1 |

## E9: Code browsing (Phase 4)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E9.1 Repository tree drill-down (one directory level per screen, breadcrumb, GitLab file-type icons) | a fixture repo tree navigates by drill-down with a working breadcrumb and a golden passes | E3.3 |
| E9.2 File view: GitLab Mono, syntax highlighting, line numbers, wrap toggle | a file renders highlighted with line numbers and a working wrap toggle | E9.1, E4.4 |

## E10: Search (Phase 4)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E10.1 Search projects, issues, and merge requests | search returns results across the three entity types against fixtures | E3.3 |
| E10.2 Code search with tier detection and web fallback | code search works where the instance tier supports it and falls back to web with an honest message where it does not | E10.1 |

## E11: Releases (Phase 4)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E11.1 Release list and detail (notes) | releases and their notes render for a fixture project | E3.3 |
| E11.2 Asset download | a release asset downloads | E11.1 |

## E12: Notification delivery layers (Phase 5)

Architecture: `docs/decisions/0002-notification-architecture.md`.
The project operates no servers at any layer.

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E12.1 Baseline background poller: conditional-request Todos polling (ETag/304) via `workmanager`, surfaced as local notifications | a background poll delivers a local notification for a new to-do within the OS scheduling floor and stays cheap through 304s | E5.1 |
| E12.2 Scheduled quiet hours | notifications suppress during configured quiet hours | E12.1 |
| E12.3 Foreground GraphQL subscriptions (bearer token) for live screen updates | an open screen live-updates and the subscription stops on background or close | E3.1 |
| E12.4 Android opt-in: foreground-service poll or UnifiedPush via a user-owned webhook-to-ntfy bridge | the opt-in path delivers to the device and the app generates the correct webhook configuration | E12.1 |
| E12.5 iOS opt-in relay wizard (ntfy or Pushover) that generates GitLab webhook config | the wizard connects a user-controlled relay and outputs the correct webhook configuration | E5.1 |
| E12.6 `registerDevice()` native-push seam shaped to `POST /api/v4/user/push_subscriptions`, adoption deferred | the seam exists and is exercised by a test, with native adoption explicitly deferred behind the feature-flag and credential-sharing gate | E3.1 |

## E13: Platform table stakes (Phase 6)

Dark mode is satisfied by construction (v1 is dark-only); no light theme or theme switcher is built for v1.

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E13.1 Biometric app lock | biometric lock gates the app and degrades correctly where biometrics are unavailable | E1.3 |
| E13.2 Account management surface: every row shows avatar, username, host; quick-switch sheet; add/remove/reorder reusing sign-in | host shows on every row, switching is a single state change, and add/remove/reorder work | E2.6, E2.7 |

## E14: Offline read cache and draft queue (Phase 6)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E14.1 Bounded offline read cache for recently viewed issues, MRs, pipelines (drift, scoped, stale-while-revalidate) | recently viewed items read offline, and the cache is bounded and scoped per account | E3.3, E6.1, E7.1, E8.1 |
| E14.2 Offline comment draft queue with send-on-reconnect | a comment drafted offline queues and flushes when connectivity returns, with an `integration_test` covering the reconnect-and-flush | E14.1 |

## E15: Store launch and signing (Phase 7)

All signing material lives outside the repository and is scoped away from PR jobs.

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E15.1 Android signing (upload key plus Play app-signing) | a signed Android release builds in CI with signing material scoped away from PR jobs | E0.3 |
| E15.2 iOS signing, build, and TestFlight/App Store upload on macOS runners | a signed iOS build uploads to TestFlight from CI | E0.3 |
| E15.3 F-Droid flavor finalization and submission MR to F-Droid's recipe repo | the FCM-free flavor is submitted via merge request to F-Droid's recipe repo and builds under its toolchain | E0.4 |
| E15.4 Google Play account setup and account-type decision (personal closed-testing gate versus verified organization) | the Play account is set up and the account-type choice is recorded against the launch timeline | none |
| E15.5 Store listings: screenshots, descriptions, privacy declarations, honest near-real-time notification wording | complete listings exist for all three stores | E15.1, E15.2, E15.3 |
| E15.6 Cross-signature user documentation (F-Droid and store builds cannot cross-update) | a user-facing note documents the distinct signatures | E15.3 |

## E16: Hardening (Phase 7)

| Task | Acceptance | Depends on |
| --- | --- | --- |
| E16.1 Accessibility pass (touch targets, contrast, screen-reader labels) | key screens meet touch-target and contrast targets and carry screen-reader labels | E5.4, E6.3, E7.4, E8.3, E9.2, E10.2, E11.2, E12.6, E13.2, E14.2 |
| E16.2 Performance pass (long lists under Impeller, image decode-at-display-size, glass within budget) | long lists scroll smoothly, images decode at display size, and both sigma-24 glass intensities sustain 60fps on a mid-range Android reference device under Impeller or the treatment is reduced before release | E5.4, E6.3, E7.4, E8.3, E9.2, E10.2, E11.2, E12.6, E13.2, E14.2, E1.2 |
| E16.3 Security pass (token storage, OAuth flow, no-live-instance guarantee) | a review of token storage and the OAuth flow is clean, and no test or build path touches a live instance | E2.1, E2.2, E2.3, E2.4, E2.5, E2.6 |
