# Technology assessment

This document summarizes the technology research behind Gitsune's stack: why Flutter, how it fits this specific app, the package choices for rendering, state management, and offline caching, the testing strategy, and the CI/CD and distribution plan.
It backs the technology-facing parts of `docs/decisions/0004-app-store-launch-scope.md` and `docs/decisions/0005-hosting-platform.md`, and provides context for `docs/plan/v1-scope.md`.

Claims are sourced inline where a source exists.
Package versions, license, and adoption figures were read directly from pub.dev at research time and will drift; treat them as a snapshot, not a live reference.

## Framework choice

Flutter is a sound choice for this app.
Impeller is now the default and only rendering engine on modern Android and iOS, which removes a historical source of first-scroll jank that would otherwise hurt fast-scrolling issue, merge request, and commit lists.
Flutter's own 2026 roadmap is framed around consolidating and finishing existing work rather than a major pivot, which signals stability.

No mature Flutter GitLab client exists to build on.
The most complete existing GitLab client (LabCoat) is native Android, not Flutter; the one notable prior Flutter attempt at a GitLab client is a small, stale proof-of-concept with no OAuth support.
This is a from-scratch build, not a port, and the app owns its whole stack rather than inheriting an existing codebase's constraints.

Source: docs.flutter.dev/perf/impeller; flutter.dev/blog (2026 roadmap).

## Design-language fidelity and liquid-glass implementation

Apple's newest iOS visual language ("Liquid Glass," introduced with iOS 26) is not implemented by Flutter's official Cupertino widget library, and the Flutter team has explicitly paused adopting it while it restructures how Material and Cupertino styling are packaged, with no committed timeline.
The community packages that attempt to simulate or interop with it are pre-1.0, effectively single-maintainer, and self-described as experimental or proof-of-concept.

Gitsune's visual direction remains its own token-driven interpretation of Pajamas rather than an adoption of Apple's platform design language.
The design system now specifies liquid-glass floating chrome, with heavier treatment app-wide and the heaviest treatment on Drawer and Modal overlays, as recorded in `docs/decisions/0009-liquid-glass-direction.md`.
That decision defines the visual hierarchy but deliberately leaves the cross-platform implementation mechanism open until development can evaluate rendering support, fidelity, accessibility, and performance on target devices.
Apple's native Liquid Glass implementation is therefore neither a cross-platform dependency nor a v1 contract.

## Rendering and content

**Long lists** (issues, merge requests, commits) are a solved problem: lazy list builders combined with Impeller's rendering improvements handle this well with standard Flutter practice.

**Diff rendering has no mature off-the-shelf package.**
No pub.dev package renders a multi-file git-style diff view; the closest options are diff *algorithms*, not diff *UI*.
Gitsune builds its own diff view: GitLab's API already returns per-file unified-diff hunks, so the work is parsing hunks and rendering them as a colored, line-by-line list with optional per-line syntax highlighting.

**Markdown rendering uses `flutter_markdown_plus`.**
Flutter's own official markdown package was discontinued with no named successor; `flutter_markdown_plus` is the strongest maintained fork, covering GitHub-flavored markdown tables, task lists, and fenced code, but not math or diagrams.
GitLab-flavored markdown extensions that no general package handles, references like `#123`, `!456`, `@user`, and `~label`, along with math and Mermaid diagrams, are built on top as custom extensions.

**Syntax highlighting uses `re_highlight`,** the freshest broad-language option available, with the caveat that it is effectively single-maintainer and carries real staleness risk.
Diffs and repository files use the same native per-line highlighter through the `200 * 1024` character threshold (roughly 200 KB for typical ASCII source).
Above that threshold, the repository file view offers to open GitLab's blob page in the system browser because the offline WebView highlighter cannot preserve the file view's line-number gutter and wrap toggle.
The reusable source-view primitive retains the offline WebView highlighter for consumers that do not need those controls.

**Avatar and image-heavy lists** use `cached_network_image`, decoding images at display size rather than full resolution to avoid memory pressure.

The overall content-rendering picture: list rendering and image caching are solved by standard practice, but diff rendering, GitLab-flavored markdown extensions, and (to a lesser extent) syntax highlighting are areas Gitsune has to own directly rather than depend on a mature package, and the ecosystem here leans heavily on single-maintainer packages that should be budgeted for occasional forking or vendoring.

## Push notifications and authentication

Push notification architecture and authentication are large enough decisions to warrant their own documents: see `docs/decisions/0002-notification-architecture.md` and `docs/research/notification-analysis.md` for notifications, and `docs/decisions/0001-auth-posture.md` and `docs/research/auth-blueprint.md` for authentication.
The packages that implement those decisions: `flutter_appauth` (OAuth2 with PKCE, using the system browser rather than an embedded web view, so instance SSO and multi-factor authentication behave exactly as they do on the web) and `flutter_secure_storage` (tokens in the platform's Keychain or Keystore-backed secure storage) for authentication; `flutter_local_notifications` for local notification display, with `workmanager` handling background polling within the operating system's real scheduling limits, and an opt-in UnifiedPush integration for Android fed by a user-owned GitLab webhook-to-ntfy bridge.

## API layer and offline caching

**REST v4 is the primary transport, not GraphQL.**
GitLab's REST API is stable, complete for CRUD-heavy work (issues, merge requests, CI, todos, files), and is not being deprecated.
GitLab's own newer investment goes into GraphQL, but a self-hosted client faces a real complication REST does not have: a self-hosted instance's GraphQL schema reflects whatever GitLab version it runs, so a query written against gitlab.com's current schema can fail against an older self-managed instance.
REST's frozen contract is far more stable across the version spread Gitsune will actually encounter.
GraphQL is used selectively, as a per-screen optimization where it clearly reduces round-trips or reaches data only available that way (see the epics note below), never as the foundation.

**`dio`** is the HTTP client, chosen specifically for its interceptor support (token injection, 401-triggered refresh-and-retry, logging) and for setting a per-instance base URL, which is exactly Gitsune's per-instance need.

**`drift` (SQLite)** is the offline cache, with every cached row scoped by instance and account, using a stale-while-revalidate pattern: cached rows render instantly while a background refresh updates them.

**Pagination** prefers keyset/cursor-based pagination over simple offset pagination for large collections, since GitLab's own total-count headers are omitted above a certain collection size; the resume token, not a page number, is what gets persisted alongside a cached list.

**One forward-looking gap:** GitLab's epics feature is being migrated off REST entirely onto GraphQL-only endpoints.
If epics are ever added to Gitsune's scope (they are explicitly out of scope for v1, see `docs/decisions/0003-v1-scope.md`), the app cannot stay REST-only to support them.

Sources: docs.gitlab.com/api/rest/deprecations/; docs.gitlab.com/api/graphql/; docs.gitlab.com/development/api_graphql_styleguide; docs.gitlab.com/api/epics/.

## State management and app architecture

**Riverpod, not Bloc, is the recommendation**, chosen specifically for fit with this app's shape rather than because Bloc is unhealthy; both are mature, actively maintained, MIT-licensed packages.
Gitsune's defining architectural traits, multiple instances, multiple accounts, one API client per account, and offline-first stale-while-revalidate lists, map closely onto Riverpod's scoped-provider model: a distinct, cached API client per account is a first-class pattern, account switching cleanly tears down the previous account's state with no manual wiring, and background refresh needs no widget in scope to read or write state.

The honest case for the alternative: Bloc's more prescriptive event-to-state discipline gives exactly one obvious way to add a feature, which can lower review variance for an open-source project with many occasional contributors, and its testing and observability tooling are genuinely excellent.
If uniform structure for many casual contributors is weighted above fit to this app's specific multi-account shape, Bloc remains a reasonable choice and does not require rethinking the rest of the architecture below, since the repository layer beneath either choice is identical.

**Module structure** is feature-first within a single package (not a multi-package monorepo, which is unnecessary complexity at this stage): a `core` layer owns networking, the database, authentication, shared models, and the Pajamas design-token theme; feature modules (todos, issues, merge requests, diff review, project browsing, search) depend on `core` but never the reverse, and the design-token theme layer imports nothing from the rest of the app, which keeps the brand layer independently swappable and testable.

**Account scoping** collapses to a single key type, combining an instance host and an account identifier, used as the scoping argument for the network client, the database access layer, and every per-account provider.
Switching accounts is a single state change; the previous account's network client and in-flight state are torn down automatically, and per-account tokens live in the platform's secure storage, namespaced so that gitlab.com and any number of self-hosted instances, or multiple accounts on the same instance, never collide.

**The repository layer is the seam that makes offline-first work:** it is the only layer that talks to both the local database and the network client.
The UI reads a reactive database stream for instant, cached rendering; a background refresh call updates the database, and the UI updates automatically when the database changes.
This layering does not depend on the Riverpod-versus-Bloc choice above.

## Testing strategy

The testing approach is biased toward being fast, deterministic, and low-friction for outside contributors: a contributor should be able to run the whole test suite with one command and see it pass without network access or extra tooling.

- **Unit and widget tests** cover repositories, the diff-hunk parser, GitLab-flavored-markdown reference resolution, and authentication/session/refresh logic, using a mocking library that needs no code generation step, to keep the contributor loop simple.
- **Golden (visual regression) tests** cover the Pajamas theme components and key screens in v1's dark theme, rendered in a CI mode that avoids cross-machine font-rendering flakiness; light-theme coverage begins when that theme enters scope under `docs/decisions/0008-dark-mode-only-v1.md`.
- **A small number of full-app integration tests** run on an emulator against a fake local server, covering the handful of flows that depend on real HTTP behavior: pagination headers, and the token-refresh-and-retry round trip.
- **A GitLab instance is faked, never real, in automated tests:** the bulk of tests replay recorded, scrubbed JSON fixtures captured from real API responses; a small in-process fake HTTP server handles the few flows that need real HTTP semantics.
  No automated test ever talks to a live GitLab instance, which keeps tests hermetic and fast.
- Every job that runs on every change (formatting, linting, the test suite, and a build sanity check) needs no secrets, which is what allows those checks to run safely on contributions from outside the project.

## CI/CD and distribution

Gitsune is hosted on GitHub (`docs/decisions/0005-hosting-platform.md`) and ships on the App Store, Google Play, and F-Droid at v1 (`docs/decisions/0004-app-store-launch-scope.md`).
This section covers the mechanics behind that.

**iOS/macOS builds require a Mac.**
GitHub Actions includes macOS runners in its standard tier, which is the default path; a Flutter-focused CI service with free macOS build minutes remains a fallback option if needed, per the open detail noted in `docs/decisions/0005-hosting-platform.md`.

**Google Play** charges a one-time $25 registration fee.
A newly created personal account must clear a closed-testing period with a minimum number of opted-in testers over a minimum number of days before it can publish to production; an organizational account is exempt from that gate but requires verified organization identity.
Which account type to use is an open implementation detail, not yet decided, and should be weighed against the project's launch timeline: a personal account is simpler to set up, an organizational account removes the testing-gate delay.

**The App Store** requires a $99/year Apple Developer Program membership, the one recurring cost in the whole distribution plan, and requires a Mac (directly or via CI) to build and sign.
TestFlight provides free beta distribution ahead of a public release.
Typical review time is measured in days; nothing about a general-purpose GitLab client is expected to raise policy concerns, though the app needs enough functionality on first launch to clear Apple's minimum-functionality guideline comfortably.

**F-Droid** requires a fully free-and-open-source toolchain, forbids proprietary tracking or push services (specifically Google's Firebase Cloud Messaging) in the build it distributes, and is otherwise free to submit to.
Because Gitsune's notification architecture (`docs/decisions/0002-notification-architecture.md`) already treats any proprietary push service as opt-in rather than required, an F-Droid-compatible build flavor, with those proprietary dependencies removed entirely, is a natural fit rather than an added burden.
A comparable open-source Flutter chat app already ships successfully on F-Droid with exactly this kind of build-flavor split, which is direct evidence the approach works.
Submission itself happens as a merge request to F-Droid's own build-recipe repository, which lives on GitLab regardless of where Gitsune's own source is hosted.

**Signing** uses three separate identities that never live in the repository: an Android upload key paired with Google Play's own app-signing, an Apple distribution certificate and provisioning profile managed through a dedicated signing-automation tool, and F-Droid's own build signature (F-Droid builds and signs from source itself, meaning the F-Droid build and the store builds carry different signatures and cannot cross-update between each other, which is worth documenting for users).
All signing secrets are scoped so that contributions from outside the project never have access to them.

Sources: developer.apple.com (Apple Developer Program fee, TestFlight, App Store Review Guidelines); support.google.com/googleplay/android-developer (Play registration fee and closed-testing requirements); f-droid.org/en/docs/Inclusion_Policy/ and /Reproducible_Builds/.
