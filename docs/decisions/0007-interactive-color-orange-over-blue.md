# 7. Interactive color: brand orange supersedes blue

- Status: accepted
- Date: 2026-08-01
- Amends: `docs/research/design-direction.md` (Part 1, Color; Part 3, "Merge action color")

## Context

`docs/research/design-direction.md` originally set Gitsune's interactive color to blue, reasoning that Pajamas reserves blue for current/active/progress and treats it as an in-progress action color, and that this happened to match GitHub Mobile's own interactive color, so no translation was needed between the two design languages.
That reasoning held through the documentation phase, before a concrete design system existed to design against.

Once the design system was built out surface by surface, the maintainer's review of that system set a different direction: brand orange, drawn from the current GitLab tanuki accent colors (`#fca326`/`#fc6d26`/`#e24329`), as Gitsune's interactive and brand color instead.
Orange reads as more distinctly Gitsune's own than blue, which is also GitHub Mobile's interactive color and Pajamas' generic progress color; using it for every button, link, active state, and focus ring gives the app a color identity that is not borrowed from either reference.
The alternative of leaving blue as the interactive color, or adopting gitlab-ui's own neutral default buttons, was considered and rejected for the same reason: neither produces a color identity distinct from the two systems Gitsune already draws from.

## Decision

Brand orange (`--gs-color-brand-*`) is Gitsune's interactive and brand color: buttons, links, active states, focus rings, and badges.
This supersedes the blue-interactive rule in `docs/research/design-direction.md` and gitlab-ui's own neutral default buttons.
Blue is retained, unchanged, as the info/progress *status* color: running pipelines, MR-merged badges, and similar state indicators that are not user-initiated actions.
Green, red, and purple keep their existing Pajamas semantics (success/done, critical/destructive only, data-viz/illustrations) exactly as `docs/research/design-direction.md` already recorded them.

## Consequences

Every interactive surface in the design system (`design/`) uses brand orange rather than blue: the confirm button variant, including the merge request Merge action, is orange rather than the blue that `docs/research/design-direction.md`'s Part 3 table originally called for.
Status semantics are unaffected: a running pipeline badge or an MR-merged status indicator stays blue, since that is status color, not interactive color, and the two are no longer the same color as they were under the original rule.
`docs/research/design-direction.md` is not rewritten, since it remains an accurate record of the phase-one research it documents; it is treated as amended by this ADR on the specific point of interactive color.
