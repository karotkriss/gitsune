# Phase plan

Gitsune is being built in three deliberate phases: documentation, then design system, then development.
This sequencing is intentional, not incidental, and each phase is expected to complete before the next one starts in earnest.

## Phase 1: documentation (current phase)

This repository, in its current state, is the output of phase one: the market research, design direction, technology assessment, and every settled decision behind the product, recorded as the project's own architecture decision records and supporting research.

No application code exists yet, and none is expected during this phase.
A cold-start contributor should be able to read the README, then `docs/decisions/`, then `docs/plan/`, and come away knowing exactly what Gitsune is, what has been decided, and why.

## Phase 2: design system

The next phase translates the design direction recorded in `docs/research/design-direction.md`, GitLab's own Pajamas design system as the visual-language baseline, GitHub Mobile's proven interaction patterns for surfaces Pajamas does not cover, and the specific resolutions where the two disagree, into a concrete, implementable design system: design tokens, component specifications, and screen-level designs for the surfaces identified as the starting kit in that document.

This phase happens before development begins, deliberately.
Building screens against an unsettled design language produces rework; settling the design system first means development can implement against a stable target from day one.

## Phase 3: development

Development begins once the design system from phase two is in place.
It is expected to build directly on the decisions already recorded in `docs/decisions/`, the technology choices in `docs/research/technology-assessment.md`, and the v1 scope in `docs/plan/v1-scope.md`, in roughly the priority order that document lays out.

This repository will open to code contributions at the start of this phase; it is not open to code contributions before then.

## Why this order

Each phase deliberately depends on the one before it: a design system built without settled product decisions would need to be reworked as those decisions landed, and development built without a settled design system would need to be reworked as design decisions landed.
Sequencing documentation, then design, then development keeps each phase's output stable once the next phase starts, rather than treating any of them as work to revisit mid-stream.
