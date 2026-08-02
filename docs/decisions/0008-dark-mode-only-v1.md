# 8. Dark mode only for v1

- Status: accepted
- Date: 2026-08-01

## Context

`docs/research/design-direction.md`'s starting kit called for designing light and dark themes together from the start, on the reasoning that Pajamas' color ramps are explicitly built for both and that GitHub Mobile itself supports both.
That was the right instinct for research, before any concrete design system existed: it kept the door open rather than foreclosing a theme prematurely.

Now that a full design system has been built out surface by surface (`design/`), the maintainer's review set a narrower scope for v1: ship dark mode only, and defer light mode to a later feature release.
Building and maintaining two themes to production quality, across every surface and every component, is real ongoing design and QA work, and splitting that work across both themes before either has shipped to a single real user delays getting the app in front of anyone.
Dark mode was chosen as the v1 theme because it is the theme the design system's "2026 look" (liquid glass, brand orange) was designed and reviewed against first.

## Decision

Gitsune v1 ships dark mode only.
The app shell defaults to `data-theme="dark"` and offers no theme switch in v1.
Light mode is deferred to a future feature release, not dropped: the light-theme color ramps already defined in `design/tokens/colors.css` remain in the token set as a foundation for that later work, rather than being removed.

## Consequences

Every v1 surface is designed, built, and tested against dark mode only; light-theme fidelity is not a v1 acceptance bar.
The design system's interactive prototype (`design/ui_kits/gitsune-app/`) still includes a light/dark/auto appearance toggle for exercising the mock against both token sets during design work; that toggle is a design-system reference tool, not a v1 product commitment, and should not be read as light mode already being available to v1 users.
When light mode is scoped for a future release, that work starts from the existing light ramps rather than designing them from scratch, but still needs its own review pass across every surface, since "the ramps exist" is not the same as "every surface has been checked against them."
