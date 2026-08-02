# Gitsune v1 roadmap

This is the plan of record for building Gitsune v1.
It is the concrete engineering sequence for phase three (development) of `docs/plan/phase-plan.md`, and it assumes every decision in `docs/decisions/` is settled while the design system is landing via a separate change.
The companion task breakdown lives in `docs/plan/task-breakdown.md`: this file defines the phases and their exit criteria, and that file lists the pickable tasks under each epic.

Development has not started.
This repository opens to code contributions at the start of phase three, on the maintainer's go-ahead, and not before.
Publishing this roadmap does not open the gate; it defines what the work is once the gate opens.

## Scope this roadmap covers

The v1 feature set is the eleven-item list in `docs/decisions/0003-v1-scope.md`, built in a dependency order that front-loads the differentiators (authentication, notifications, merge request review, CI/CD, issues) while respecting what each surface depends on.
Everything the roadmap references traces to a settled decision:

- Authentication: `docs/decisions/0001-auth-posture.md` (OAuth2 with PKCE, gitlab.com one-tap, guided self-hosted registration, de-emphasized PAT fallback, multi-instance and multi-account sessions).
- Notifications: `docs/decisions/0002-notification-architecture.md` (layered, no project-operated servers, native-push seam).
- v1 scope: `docs/decisions/0003-v1-scope.md`.
- Store launch: `docs/decisions/0004-app-store-launch-scope.md` (all three stores at v1, iOS on the critical path).
- Hosting and CI: `docs/decisions/0005-hosting-platform.md` (GitHub, macOS runners for iOS).
- Positioning: `docs/decisions/0006-strategy-and-positioning.md`.

## Operating principles

These hold across every phase and are not restated per task.

- **Fixtures-first testing.** GitLab is always faked, never a live instance: bulk cases use recorded, scrubbed JSON fixtures, and HTTP-semantics cases use a small in-process fake server. The full test suite runs with one command, no network, and no secrets, so an outside contributor can run everything a change needs. See `docs/research/technology-assessment.md` for the full testing shape.
- **REST v4 is the primary transport.** REST is the stable contract across the self-hosted version spread; GraphQL is used selectively, per screen, only where REST cannot serve the need (for example live foreground subscriptions). A single `dio` client per account carries token injection, one-time 401 refresh-and-retry, and the per-instance base URL through interceptors.
- **Feature-first, single package.** A `core` layer owns networking, the local database, auth, shared models, and the design-token theme. Feature modules depend on `core` and never on each other in reverse. The design-token theme imports nothing, so the brand layer stays independently swappable and testable.
- **Account scoping is a composite key.** Instance host plus account identifier keys the network client, every database row, and every per-account provider. Switching accounts is a single state change that tears down the previous account's client and state.
- **Offline-first through the repository layer.** The repository layer is the only layer that talks to both the database and the network; the UI reads a reactive database stream and a background refresh updates the database, so the UI updates itself. This seam is independent of the state-management choice.
- **No project-operated servers, at any layer, ever**, per `docs/decisions/0002-notification-architecture.md`.
- **Public-project hygiene.** Every per-change CI job (format, analyze, test, build sanity) runs without secrets so it is safe on outside contributions; signing material and any store credentials are scoped away from those jobs.

## Design system input and the one reconciliation it requires

The closed design review settled the decisions that development implements against while the design system is landing: a **tanuki-orange interactive accent**, a **dark-only** v1 theme, and a **liquid-glass treatment that is modest app-wide and heavy on overlays** (modals, drawers, sheets).
Structure, component naming, typography, iconography, and terminology continue to follow GitLab's Pajamas language as recorded in `docs/research/design-direction.md`: GitLab Sans and GitLab Mono, monospace on every git reference, Pajamas component names, and the product nouns (Merge Request, Pipeline, To-Do List, Project, Group, Approvals).
Because v1 is dark-only, the semantic color ramps (green for success, red for critical, and so on) are retained while the interactive accent is tanuki-orange rather than the blue the earlier research doc recommended.

`docs/research/design-direction.md` predates that design review and still states the superseded positions (blue interactive accent, light and dark designed together, liquid glass out of scope).
A task in the design-system epic reconciles that doc with the closed design review so the repository stops contradicting itself; the roadmap itself follows the newer, settled design decisions.

## Phase map

| Phase | Theme | v1 scope items delivered |
| --- | --- | --- |
| 0 | Foundation: scaffold, CI, design-system theme, app shell, test harness | (enabling) |
| 1 | Authentication core | 1 |
| 2 | Read/write spine, notifications inbox, issues | 2, 5 |
| 3 | Merge request review and CI/CD | 3, 4 |
| 4 | Breadth surfaces: code browsing, search, releases | 6, 7, 8 |
| 5 | Notification delivery layers | 9 |
| 6 | Platform table stakes and offline resilience | 10, 11 |
| 7 | Store launch and hardening | (all, shipped) |

Phases are sequential gates: a phase does not start in earnest until the previous phase clears its exit criteria.
Within a phase, the listed slices can be worked in parallel unless a task's dependencies say otherwise.

---

## Phase 0: Foundation

Stand up the project so that every later phase implements against a stable target rather than building infrastructure ad hoc.

- Flutter project scaffold with the feature-first single-package structure: a `core` layer (networking, database, auth, models, theme) and empty feature-module slots, with Riverpod wired as the state layer.
- GitHub Actions CI: format, analyze, test, and build-sanity for Android, iOS, and the F-Droid build flavor, all secret-free.
- The fixtures-first test harness: a recorded-fixture loader, the in-process fake HTTP server, and golden-test infrastructure configured for the dark theme with cross-machine font stability.
- The design-token theme layer implementing the settled design decisions (tanuki-orange interactive accent, dark-only, Pajamas semantic ramps, GitLab Sans and GitLab Mono).
- The app shell: the four-tab bottom navigation (Home, To-Dos/Notifications, Explore/Search, Profile), routing, and empty themed screens.
- The `dio`-based API client skeleton: per-instance base URL and interceptor seams for token injection and one-time 401 refresh-and-retry, with auth wired in during phase one.

**Parallel dependency, starts with this phase: the liquid-glass implementation spike.**
The dark-only theme and the shell's overlay components depend on a proven way to render liquid glass in Flutter (modest app-wide, heavy on overlays) at 60fps on mid-range Android under Impeller.
This is a de-risking spike run alongside the scaffold rather than a blocker on it: non-glass scaffolding proceeds immediately, and the spike's chosen approach (a blur/backdrop technique or a vetted package, with its performance ceiling documented) feeds the shell and theme components before they are finalized.
If the spike finds no approach that holds the frame budget, it reports that early so the overlay treatment can be dialed back before it is built on.

**Exit criteria:**

- CI is green building a themed but empty app shell for Android, iOS, and the F-Droid flavor.
- The fixtures harness runs the (initially small) suite with one command, no network, no secrets, and a stable golden baseline for the dark theme.
- The liquid-glass spike has delivered a chosen implementation approach with a documented performance ceiling, or an early report that the heavy-overlay treatment needs to be reduced.
- The `dio` client skeleton resolves a per-instance base URL and exposes the token-injection and refresh-retry interceptor seams (unpopulated until phase one).

---

## Phase 1: Authentication core

Deliver v1 scope item 1.
Authentication gates every feature that follows, so it is the first real slice after foundation.
Implementation detail lives in `docs/research/auth-blueprint.md`.

- OAuth2 Authorization Code with PKCE (S256), public client, no client secret ever stored or sent, run entirely in the system browser (`flutter_appauth`), never an embedded webview.
- gitlab.com one-tap sign-in with the baked-in client ID.
- The guided self-hosted registration wizard: it shows the user exactly what to enter on their instance's Applications page (name, the fixed custom-scheme redirect URI byte-for-byte, public/non-confidential, and the `api`/`read_api` plus `read_user` scopes), and the user pastes back only the Application ID.
- The de-emphasized PAT fallback behind a secondary "having trouble signing in" affordance, for instances where user-level OAuth app creation is disabled and the user is not an admin.
- Multi-instance, multi-account session management: tokens namespaced per account in `flutter_secure_storage`, lazy on-demand refresh reading the server's actual expiry, single-use rotating refresh tokens written atomically, no double-refresh under concurrent requests, and a failed refresh that marks only the one account for re-auth without signing out the others.
- The sign-in surface per `docs/research/design-direction.md`: the instance field is permanently visible and pre-filled with `gitlab.com`, there are no credential fields on the primary screen, and an unreachable or non-GitLab URL produces an inline error rather than a silent hang.

**Exit criteria:**

- A user can sign in to gitlab.com in one tap, to a self-hosted instance through the guided wizard, and through the PAT fallback where OAuth registration is impossible.
- Multiple accounts across different instances coexist, and a failed refresh on one isolates to that account.
- The named wizard failure cases (registration disabled, instance too old for PKCE, redirect-URI mismatch, confidential left checked, scope mismatch, pasted whitespace) each surface a correct, actionable message, covered by tests against fixtures and the fake server.
- The token refresh-and-retry round trip and the single-use rotation race are covered by an `integration_test` against the fake server.

---

## Phase 2: Read/write spine, notifications inbox, and issues

Deliver v1 scope items 2 and 5, and build the reusable list/detail/comment/markdown spine that the higher-complexity surfaces reuse.
Notifications inbox is the second-highest v1 priority and low in complexity; issues is a self-contained create/read/update surface that establishes the write patterns merge request review depends on.
Both consume patterns worth building once.

- The shared read/write spine: entity list and detail patterns, pull-to-refresh, error and empty states, the reactive database-backed repository pattern, and keyset/cursor pagination that persists a resume token.
- The markdown renderer: `flutter_markdown_plus` plus the custom GitLab-flavored extensions (`#123`, `!456`, `@user`, `~label`, and the math and Mermaid gaps the base package leaves).
- **Notifications inbox (item 2):** the To-Do List built on the Todos API, with swipe triage (full swipe to done, swipe to snooze, undo on every destructive swipe), a filter sheet by to-do reason, and opening the underlying item. The Todos data layer built here is reused by phase five's background poller.
- **Issues (item 5):** view, create, comment, label, assign, and triage, with the thread anatomy from `docs/research/design-direction.md` (state badge, breadcrumb, markdown body, inline state-change events, pinned bottom comment entry, scoped-label pills).

**Exit criteria:**

- The To-Do List lists, filters, and triages real fixture data, and opening an item deep-links to the relevant surface (or to web where that surface does not exist yet).
- Issues can be viewed, created, commented on, labeled, assigned, and triaged, with markdown and GitLab references rendering correctly.
- The list/detail/comment spine, markdown renderer, and pagination are covered by unit and golden tests, and the Todos data layer exposes the reactive stream the poller will consume.

---

## Phase 3: Merge request review and CI/CD

Deliver v1 scope items 3 and 4, the highest-leverage and highest-complexity surfaces.
This phase opens with the rendering foundation both surfaces and later phases need.

- **Rendering foundation:** the diff-hunk parser (GitLab returns per-file unified-diff hunks; the app parses them into a colored, line-by-line list) and the syntax-highlighting engine (`re_highlight`, with the WebView JavaScript-highlighter reserved as a fallback for full-file views). Budget for vendoring given the single-maintainer risk on these packages.
- **Merge request review and approval (item 3):** list, diff view with per-line syntax highlighting, inline comments, thread resolution, approve and unapprove, and merge, with a graceful view-on-web fallback for oversized diffs. The MR surface follows `docs/research/design-direction.md`: monospace source-to-target branch chips, a collapsible Pipelines section, a collapsible Approvals section, and a merge box that combines pipeline status, approval status, mergeability, and the unresolved-discussion count in one action area, with the merge action in the interactive accent.
- **CI/CD pipeline and job visibility (item 4):** pipeline and job status, a job-log viewer, and the ability to retry, cancel, or run manual jobs.

**Exit criteria:**

- A user can browse to a merge request, read its diffs with syntax highlighting, comment inline, resolve threads, approve or unapprove, and merge; an oversized diff falls back to web cleanly.
- The merge box correctly reflects pipeline, approval, mergeability, and unresolved-discussion state.
- Pipelines and jobs show status and logs, and retry, cancel, and run-manual-job actions work against fixtures.
- The diff-hunk parser and highlighting engine have unit and golden coverage, and the review actions have `integration_test` coverage against the fake server.

---

## Phase 4: Breadth surfaces

Deliver v1 scope items 6, 7, and 8, which round out parity and reuse the rendering foundation from phase three.

- **Code browsing with syntax highlighting (item 6):** a read-only repository tree and file view as drill-down (one directory level per screen plus a breadcrumb, not a side tree), GitLab file-type icons, GitLab Mono, full syntax highlighting, line numbers, and a wrap toggle. This deliberately exceeds GitHub Mobile's own editor, which lacks syntax highlighting.
- **Search (item 7):** projects, issues, and merge requests everywhere, plus code search where the instance's license tier supports it, with an honest fallback to web where it does not. Detect tier capability and degrade gracefully rather than presenting a broken code-search box.
- **Releases (item 8):** view releases and download release assets; creation is deferred past v1.

**Exit criteria:**

- A user can browse a repository tree, open a file with syntax highlighting and line numbers, and toggle wrap.
- Search returns projects, issues, and merge requests; code search works where the tier supports it and falls back to web with an honest message where it does not.
- Releases list and their assets download.
- Each surface has unit and golden coverage against fixtures.

---

## Phase 5: Notification delivery layers

Deliver v1 scope item 9 (the baseline layer) and stand up the rest of the layered architecture from `docs/decisions/0002-notification-architecture.md`, including the seam for GitLab's emerging native push.
The project operates no servers at any layer.

- **Baseline, on by default, every instance (item 9):** conditional-request polling of the Todos API using stored ETags for cheap 304s, scheduled through `workmanager` within the OS background limits, surfaced as local notifications through `flutter_local_notifications`, with scheduled quiet hours. Presented to users as near-real-time, not instant.
- **Foreground live updates:** GraphQL subscriptions over GitLab's real-time channel, authenticated with the user's own token, live only while a screen is open. This supplements the baseline; it does not run in the background.
- **Android opt-in:** either a device-side foreground service that polls, or a user-owned webhook-to-gateway bridge with ntfy as the UnifiedPush distributor, configured by the user.
- **iOS opt-in:** the guided wizard that helps a user connect their own account on a push-relay service they choose and control (ntfy, Pushover), generating the correct GitLab webhook configuration for them to add. This matters for the iOS launch story, since iOS has no zero-relay background push.
- **Native-push seam:** the device-registration layer built around a single `registerDevice()` interface (shaped to GitLab's `POST /api/v4/user/push_subscriptions`) so the native capability can be evaluated later without rework. Adoption stays deferred: it is gated behind GitLab feature flags and an unresolved credential-sharing arrangement for self-hosted instances.

**Exit criteria:**

- Background polling delivers local notifications for new to-dos within the OS scheduling floor, respects quiet hours, and stays cheap through conditional requests.
- Foreground subscriptions live-update an open screen and cleanly stop when it closes or the app backgrounds.
- The Android opt-in path and the iOS relay wizard each produce a working, user-controlled delivery route, with the app generating correct webhook configuration.
- The `registerDevice()` seam exists and is exercised by a test, with native adoption explicitly deferred.

---

## Phase 6: Platform table stakes and offline resilience

Deliver v1 scope items 10 and 11.

- **Table stakes (item 10):** biometric app lock, and multi-instance/multi-account management. Dark mode is satisfied by construction, since v1 is dark-only; no light theme or theme switcher is built for v1. The account management surface follows `docs/research/design-direction.md`: every account row always shows avatar, username, and host (host visibility is a safety feature), a quick-access switch sheet from the profile tab, and a full settings screen for add, remove, and reorder that reuses the sign-in screen unchanged.
- **Bounded offline read cache (item 11):** recently viewed issues, merge requests, and pipelines remain readable without a connection, built on the `drift` (SQLite) database with every row scoped by instance and account and a stale-while-revalidate policy; comment drafts queue and send when connectivity returns. This deliberately exceeds GitHub Mobile, which has no offline mode.

**Exit criteria:**

- Biometric app lock gates access and degrades correctly where biometrics are unavailable.
- Account management shows host on every row, switches accounts in one state change, and adds/removes/reorders accounts.
- Recently viewed issues, merge requests, and pipelines are readable offline, and a comment drafted offline sends when connectivity returns.
- The offline read paths and the draft queue have integration coverage against the fake server (including the reconnect-and-flush round trip).

---

## Phase 7: Store launch and hardening

Ship to all three stores at once per `docs/decisions/0004-app-store-launch-scope.md`, with iOS on the critical path, and clear the quality bar before release.

- **Signing:** three separate identities, never in the repository and scoped away from PR jobs. Android upload key plus Play app-signing, an Apple distribution certificate and profile via a signing-automation tool, and F-Droid's own signature. Document for users that the F-Droid build and the store builds carry different signatures and cannot cross-update.
- **F-Droid flavor:** the build flavor with proprietary push dependencies removed (a natural fit, since push is opt-in), submitted through a merge request to F-Droid's build-recipe repository on GitLab.
- **Store setup:** the Apple developer program and TestFlight for beta, and the Google Play account whose type (personal, which must clear the closed-testing gate, versus a verified organization, which is exempt) is settled at this point against the launch timeline. This account-type choice is the one store detail left open at decision time.
- **CI for release:** iOS build, sign, and TestFlight/App Store upload on GitHub Actions macOS runners, with a Flutter-focused CI service considered only if the included runners prove insufficient (the open CI detail from `docs/decisions/0005-hosting-platform.md`).
- **Hardening:** accessibility (touch targets, contrast, screen-reader labels), performance (long-list smoothness under Impeller, image decode-at-display-size, glass overlays within the spike's documented budget), and a security pass over token storage, the OAuth flow, and the fact that no test or build path ever touches a live instance.
- **Store listings:** screenshots, descriptions, and privacy declarations for each store, honest about the near-real-time (not instant) notification model.

**Exit criteria:**

- Signed release builds are produced for the Apple App Store, Google Play, and the F-Droid flavor, from CI, with signing material outside the repo and PR jobs.
- The app clears each store's submission requirements (Apple minimum-functionality, the Google account gate, F-Droid's FOSS-toolchain rules).
- Accessibility, performance, and security passes are complete with no open blockers, and the full fixtures-first suite is green.
- v1 is submitted to all three stores.

---

## First buildable slices

When development opens, phase zero is where it starts.
The tasks with no upstream code dependency (the scaffold, the CI skeleton, the fixtures harness, the design-token theme, the app shell, the `dio` client skeleton) plus the parallel liquid-glass spike are the first pickable work.
They are enumerated in `docs/plan/task-breakdown.md` under epics E0, E1, and E3, and they are staged rather than started until the maintainer opens phase three.
