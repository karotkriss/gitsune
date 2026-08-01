# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- Gitsune is in its documentation phase: see `README.md` for what the project is, `docs/decisions/` for every settled ADR, `docs/research/` for the evidence behind them, and `docs/plan/phase-plan.md` for the docs -> design system -> development sequencing. No application code exists yet, and none should be added until `docs/plan/phase-plan.md`'s design-system phase has landed; that is deliberate sequencing, not a gap to fill.
- Prose files in this repo use a one-sentence-per-line convention (each full sentence on its own physical line; normal Markdown structure like lists and tables is unaffected). `.markdownlint.jsonc` disables MD013 (line length) specifically to match this style; do not re-enable it without also reformatting every prose file.
- The license is intentionally unset ("License: TBD" in `README.md`). Do not add a `LICENSE` file or pick a license without an explicit decision recorded as a new ADR in `docs/decisions/`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
