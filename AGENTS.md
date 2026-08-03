# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- Gitsune has completed its documentation and design-system phases and development has opened: see `README.md` for what the project is, `docs/decisions/` for every settled ADR, `docs/research/` for the evidence behind them, `docs/plan/phase-plan.md` for the docs -> design system -> development sequencing, and `design/readme.md` for the design system itself (tokens, components, guidelines, the interactive `ui_kits/gitsune-app/` mock).
- The v1 build plan lives in `docs/plan/roadmap.md` (phased plan with per-phase exit criteria) and `docs/plan/task-breakdown.md` (pickable tasks per epic, with acceptance notes and dependencies); development implements against those.
- The app is a single Flutter package (`flutter create`-scaffolded, org `dev.gitsune`, Android and iOS only) laid out feature-first: `lib/core/` is shared infrastructure (networking, database, auth, theme) and `lib/features/` holds feature modules.
  Features may import `core`, never the reverse; `test/architecture_test.dart` enforces this for imports and exports, including relative and package URIs.
  State management is Riverpod (`flutter_riverpod` + `riverpod`), wired via a root `ProviderScope` in `lib/main.dart`.
- See the README's "Testing" section for the fixtures-first harness, the full-suite command and concurrent-reporter guidance, and golden-baseline maintenance.
- The theme layer lives in `lib/core/theme/`: `tokens.dart` is pure token data and the single re-branding swap point (see `test/theme/rebrand_test.dart`), and `GsTheme` in `app_theme.dart` is the `ThemeExtension` exposing accent/semantic/typography tokens (`Theme.of(context).extension<GsTheme>()!`).
  The bundled GitLab Sans/Mono ttf files are generated from the woff2 in `design/assets/fonts/`; regeneration and license rules are in `assets/fonts/README.md`.
- Routing is `go_router`: the four-tab shell (`StatefulShellRoute.indexedStack`) lives in `lib/features/shell/app_shell.dart` and each app instance builds its own router via `buildAppRouter()` so tests never share navigation state.
  Pajamas glyphs render through `GsIcon` in `lib/core/icons/gs_icons.dart`; add a glyph by copying its `<symbol>` path data verbatim from `design/assets/icons/gitlab-icons.svg` (the file header documents this), not by adding an icon dependency.
- `.tasks.toml` points the `tasks-axi` task tracker at this repo's own GitHub Issues; Phase 0 (E0, E1, E3) is seeded there with `e<epic>-<task>` ids and the doc's dependency edges wired via `blocked-by`, so `docs/plan/task-breakdown.md` stays the source of truth and the issues are its live projection.
- `docs/design/` holds screenshot reference material backing `docs/research/design-direction.md`; `docs/design/references/manifest.json` traces each image back to its source URL and is the provenance record, so keep any future addition to that folder paired with a manifest entry.
- `design/` vendors real files from GitLab's open-source `@gitlab/ui`, `@gitlab/fonts`, and `@gitlab/svgs` npm packages (tokens, fonts, icons, illustrations); each vendored file's license text ships alongside it, indexed in `design/readme.md`'s "Third-party licenses" section.
  Keep any future update to those vendored files paired with a matching license-text update if the upstream license changes.
- Design decisions that amend or supersede an earlier ADR are recorded as their own new, numbered ADR rather than by editing the original (see `docs/decisions/0007-interactive-color-orange-over-blue.md` amending `docs/research/design-direction.md`'s original color guidance); follow this pattern for future design or scope changes too.
- Prose files in this repo use a one-sentence-per-line convention (each full sentence on its own physical line; normal Markdown structure like lists and tables is unaffected).
  `.markdownlint.jsonc` disables MD013 (line length) specifically to match this style; do not re-enable it without also reformatting every prose file.
- The local database is `drift` (SQLite) under `lib/core/database/`: `account_scope.dart` defines the `AccountScoped` mixin (`instanceHost` + `accountId` columns) that every table inherits per the composite-key operating principle; `app_database.dart` is the `@DriftDatabase` and its generated `app_database.g.dart` is committed.
  Regenerate after touching any table with `dart run build_runner build` (PATH needs `$HOME/flutter/bin`).
  `sqlite3_flutter_libs` is EOL as of sqlite3 3.x, which bundles native libraries itself via Dart hooks; use `drift_flutter`'s `driftDatabase()` helper instead, and construct `AppDatabase.forTesting(NativeDatabase.memory())` for tests.
- `docs/plan/roadmap.md` owns the offline-first repository operating principle; use `lib/core/repository/offline_first_repository.dart` as the seam and `lib/core/repository/current_user_repository.dart` as its single-row exemplar, or `lib/core/repository/todos_repository.dart` as the list exemplar (it follows every pagination link on each `refresh`, then replaces the account's cached rows in one transaction rather than diffing).
- CI is defined in `.github/workflows/ci.yml`; keep golden tests confined to its Ubuntu checks job to avoid cross-platform pixel drift, and keep PR jobs secret-free until signing work is scoped under E15.
- Pure-Dart, Flutter-free logic (no widgets, no `dart:ui`) belongs in its own `lib/core/<area>/` module so it stays plainly unit-testable; see `lib/core/diff/diff_hunk_parser.dart` for the pattern.
  Text fixtures for such tests live under `test/fixtures/<area>/` and are read directly with `File(...).readAsStringSync()` at test time; they do not need a `pubspec.yaml` asset entry since they are never bundled into the app.
  Author fixtures containing trailing-whitespace-only lines (e.g. unified-diff blank context lines) with a script (Python/`printf`), not the file-write tool, which silently strips trailing whitespace.
- Extend `lib/core/markdown/gs_markdown.dart` with custom syntax tags rather than registering `MarkdownElementBuilder`s for built-in tags such as `pre`, `code`, or `p`.
  `flutter_markdown_plus` intercepts every use of a registered built-in tag, even when its builder returns `null`, so this can blank ordinary content; `test/core/markdown/mermaid/gs_mermaid_test.dart` protects ordinary fenced code blocks from that regression.
- Liquid glass: `GlassSurface` (`lib/core/glass/glass_surface.dart`) is the single glass primitive and isolation seam; compose it rather than using `BackdropFilter` directly.
  See `docs/research/glass-spike.md` for the benchmark procedure, measured cost model, and open real-device validation.
- GitLab CI states and the fixed Pajamas circular badge mapping live in `lib/core/ci/`; reuse `CiStatusBadge` anywhere pipeline or job state appears so glyphs, colors, and semantics stay consistent.
- The job-log viewer (E8.2) parses raw traces with `lib/core/ansi/ansi_log_parser.dart` (pure Dart; SGR codes become styled spans, and `\r`-overwrite semantics are what hide `section_start`/`section_end` markers and stale progress states rather than any marker-specific code).
  `JobLogScreen` renders the parsed lines in a virtualized mono list over `codeBg` with a fixed 16-color ANSI palette (fixed for the same reason as the CI badge mapping); it is reached via `PipelineDetailScreen.onJobTap` -> `/projects/:projectId/jobs/:jobId/log`, with the tapped `PipelineJob` passed as router `extra` and the pipeline ref as a query param, falling back to a bare job-id header on a deep link without `extra`.
- The pipeline job actions (`lib/features/pipelines/data/pipelines_repository.dart`'s `retryJob`/`cancelJob`/`playJob`) are this app's first write (POST) endpoints; they establish the pattern for future mutating actions: the repository method posts and decodes the updated resource from the response body, and the calling screen folds that resource back into its local state (see `PipelineDetails.withUpdatedJob` for the retry-creates-a-new-job-id-vs-cancel/play-updates-in-place merge logic) rather than refetching.
- The license is intentionally unset ("License: TBD" in `README.md`).
  Do not add a `LICENSE` file or pick a license without an explicit decision recorded as a new ADR in `docs/decisions/`.
  This is distinct from the vendored third-party licenses in `design/`, which govern only the files they accompany regardless of what license this repository eventually adopts.
- Android flavor commands are documented in `README.md`; `android/app/build.gradle.kts` owns the proprietary-dependency boundary, and `docs/decisions/0004-app-store-launch-scope.md` owns its rationale.
- Search (`lib/features/search/`) reads GitLab's `GET /search?scope=projects|issues|merge_requests&search=<term>`, one network-only repository method pair (`loadFirst*`/`loadNext*`) per scope, each backed by its own `KeysetPaginator`.
  `KeysetPaginator` just follows the response's `Link: rel="next"` header, so it works unchanged here even though search pagination is offset-based rather than the keyset-flagged style `IssuesRepository` requests.
  The issues scope reuses `Issue`/`IssueAuthor`/`IssueLabel` from `lib/features/issues/data/issue_models.dart`; the merge-requests scope has no canonical model to reuse yet (E7.1 not landed), so `search_models.dart` defines a minimal `SearchMergeRequest` reusing `IssueAuthor`/`IssueLabel` for its author/label shape.
  Fold this into the canonical MR model once E7.1 lands rather than keeping both.
  `buildAppRouter`'s optional `searchRepository` param swaps the Explore tab's placeholder for `SearchScreen`, the same null-until-composition-root-wiring convention as `issuesRepository`/`pipelinesRepository`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
