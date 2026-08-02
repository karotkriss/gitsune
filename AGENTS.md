# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- Gitsune has completed its documentation and design-system phases and development has opened: see `README.md` for what the project is, `docs/decisions/` for every settled ADR, `docs/research/` for the evidence behind them, `docs/plan/phase-plan.md` for the docs -> design system -> development sequencing, and `design/readme.md` for the design system itself (tokens, components, guidelines, the interactive `ui_kits/gitsune-app/` mock).
- The v1 build plan lives in `docs/plan/roadmap.md` (phased plan with per-phase exit criteria) and `docs/plan/task-breakdown.md` (pickable tasks per epic, with acceptance notes and dependencies); development implements against those.
- The app is a single Flutter package (`flutter create`-scaffolded, org `dev.gitsune`, Android and iOS only) laid out feature-first: `lib/core/` is shared infrastructure (networking, database, auth, theme) and `lib/features/` holds feature modules.
  Features may import `core`, never the reverse; `test/architecture_test.dart` enforces this for imports and exports, including relative and package URIs.
  State management is Riverpod (`flutter_riverpod` + `riverpod`), wired via a root `ProviderScope` in `lib/main.dart`.
- `.tasks.toml` points the `tasks-axi` task tracker at this repo's own GitHub Issues; Phase 0 (E0, E1, E3) is seeded there with `e<epic>-<task>` ids and the doc's dependency edges wired via `blocked-by`, so `docs/plan/task-breakdown.md` stays the source of truth and the issues are its live projection.
- `docs/design/` holds screenshot reference material backing `docs/research/design-direction.md`; `docs/design/references/manifest.json` traces each image back to its source URL and is the provenance record, so keep any future addition to that folder paired with a manifest entry.
- `design/` vendors real files from GitLab's open-source `@gitlab/ui`, `@gitlab/fonts`, and `@gitlab/svgs` npm packages (tokens, fonts, icons, illustrations); each vendored file's license text ships alongside it, indexed in `design/readme.md`'s "Third-party licenses" section.
  Keep any future update to those vendored files paired with a matching license-text update if the upstream license changes.
- Design decisions that amend or supersede an earlier ADR are recorded as their own new, numbered ADR rather than by editing the original (see `docs/decisions/0007-interactive-color-orange-over-blue.md` amending `docs/research/design-direction.md`'s original color guidance); follow this pattern for future design or scope changes too.
- Prose files in this repo use a one-sentence-per-line convention (each full sentence on its own physical line; normal Markdown structure like lists and tables is unaffected).
  `.markdownlint.jsonc` disables MD013 (line length) specifically to match this style; do not re-enable it without also reformatting every prose file.
- The license is intentionally unset ("License: TBD" in `README.md`).
  Do not add a `LICENSE` file or pick a license without an explicit decision recorded as a new ADR in `docs/decisions/`.
  This is distinct from the vendored third-party licenses in `design/`, which govern only the files they accompany regardless of what license this repository eventually adopts.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
