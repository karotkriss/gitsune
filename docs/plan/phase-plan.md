# Phase plan

Gitsune is being built in three deliberate phases: documentation, then design system, then development.
This sequencing is intentional, not incidental, and each phase is expected to complete before the next one starts in earnest.

## Phase 1: documentation (complete)

Phase one produced the market research, design direction, technology assessment, and every settled decision behind the product, recorded as the project's own architecture decision records and supporting research.

No application code exists yet, and none is expected during this phase.
A cold-start contributor should be able to read the README, then `docs/decisions/`, then `docs/plan/`, and come away knowing exactly what Gitsune is, what has been decided, and why.

## Phase 2: design system (complete)

Phase two translated the design direction recorded in `docs/research/design-direction.md`, GitLab's own Pajamas design system as the visual-language baseline, GitHub Mobile's proven interaction patterns for surfaces Pajamas does not cover, and the specific resolutions where the two disagree, into the concrete design system in `design/`.

This phase completed before development begins, deliberately.
Building screens against an unsettled design language produces rework; settling the design system first means development can implement against a stable target from day one.

## Phase 3: development (active)

Internal project development is under way, with the completed design system from phase two in place as its implementation target.
The authoritative engineering sequence for this phase is `docs/plan/roadmap.md`, with the pickable-task companion in `docs/plan/task-breakdown.md`.
That sequence builds on the decisions in `docs/decisions/` and the technology choices in `docs/research/technology-assessment.md`.

This repository is not yet open to outside code contributions.
This plan will record when outside contribution opens.

## Why this order

Each phase deliberately depends on the one before it: a design system built without settled product decisions would need to be reworked as those decisions landed, and development built without a settled design system would need to be reworked as design decisions landed.
Sequencing documentation, then design, then development keeps each phase's output stable once the next phase starts, rather than treating any of them as work to revisit mid-stream.
