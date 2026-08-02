# Gitsune

Gitsune is a planned open-source, cross-platform GitLab client for phones and tablets.
It targets both gitlab.com and self-hosted GitLab instances, with self-hosted treated as a first-class target rather than an afterthought.

## Why this project exists

GitLab has never shipped an official native mobile app.
Since 2015, GitLab's public position has been to invest in mobile web instead of a native client, and that position has held for over a decade.
The result is a decade-long gap that roughly a dozen third-party clients have tried to fill, with mixed success: several have died or been delisted, the most-installed open-source client is thin on features and has had self-hosted sign-in break on modern token formats, and the most feature-complete client has a closed-source iOS build.
No existing client combines full feature breadth, an open-source license, cross-platform support, and reliable self-hosted sign-in.
That combination is the gap Gitsune fills.

The demand signal is real but long-tail rather than a groundswell: GitLab's own feature request for an official app has sat open for years with a modest number of votes, but indirect evidence (a persistent supply of third-party clients, high-traffic forum threads asking where the app is, and repeated self-hosted-specific complaints) points to a real, underserved need.
Merge request review on the go, push notifications, CI/CD status, and reliable self-hosted access are the most consistently requested capabilities, and they anchor Gitsune's v1 scope.

Worth stating plainly: GitLab is also known to be prototyping push-notification infrastructure that looks like early work toward an official mobile app of its own.
Nothing has shipped or been announced publicly, and what has surfaced looks narrow in scope (iOS-only, notification-focused).
Gitsune's differentiators, cross-platform coverage, self-hosted-first design, a commitment to an open-source license, and full feature breadth, remain distinct from that narrower framing regardless of how it develops.
See `docs/decisions/0006-strategy-and-positioning.md` for how this shapes positioning.

## What Gitsune is

- **Cross-platform.** One Flutter codebase targets Android and iOS.
- **Self-hosted-first.** Instance-URL-first sign-in, with gitlab.com and any self-hosted instance treated as equally valid destinations.
- **OAuth-first authentication.** OAuth2 with PKCE is the primary sign-in method on both gitlab.com and self-hosted instances, with a guided setup flow for self-hosted registration and a minimal Personal Access Token fallback for instances where OAuth app registration is unavailable.
- **Full feature breadth.** The v1 scope targets parity with GitHub Mobile's functional bar: merge request review and approval, CI/CD pipeline status and logs, issue triage, a notifications inbox, code browsing with syntax highlighting, search, releases, and an offline read cache.
- **No project-operated servers, ever.** Notifications are delivered through polling, GitLab's own real-time channels, and optional user-owned services the person chooses to connect, never through infrastructure this project runs and that would see anyone's GitLab activity.
- **Designed in GitLab's own visual language.** The interface follows GitLab's Pajamas design system for color, type, iconography, and terminology, borrowing proven mobile interaction patterns where GitLab's design system does not yet cover mobile-specific needs.
- **License: TBD.** A license has not been chosen yet; this is a deliberate, open decision rather than an oversight.

## Current status

Gitsune is in its documentation phase.
No application code has been written, and no scaffolding exists yet.
A design system is being built next, before development begins.
See `docs/plan/phase-plan.md` for the full sequencing.

## How the docs are organized

- **`docs/decisions/`** - architecture decision records (ADRs) for every settled ruling: authentication posture, notification architecture, v1 scope, app store launch scope, hosting platform, and strategic positioning.
- **`docs/research/`** - the research behind those decisions, edited for a public audience: market analysis, design direction, technology assessment, notification analysis, and the authentication implementation blueprint.
- **`docs/design/`** - the screenshot reference material behind the design direction: `design-references.md`, with sourcing back to each original screen.
- **`docs/plan/`** - the v1 feature list with its supporting gap analysis, the phase plan from documentation through design and into development, and the v1 build plan: `roadmap.md` (phased plan with exit criteria) and `task-breakdown.md` (pickable tasks per epic).

A good reading order for a new contributor is README, then `docs/decisions/`, then `docs/plan/`.
The research docs are there to back up the decisions with evidence, not to be read cover to cover.

## Contributing

Gitsune is not yet open for code contributions; development has not started.
`docs/plan/phase-plan.md` describes what happens next and when contribution will open up.
