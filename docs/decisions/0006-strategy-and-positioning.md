# 6. Strategy and positioning: cross-platform, self-hosted-first, full breadth

- Status: accepted
- Date: 2026-08-01

## Context

The original case for building Gitsune rested on a specific framing: no official GitLab mobile app has ever existed, so there is no incumbent to unseat, only a fragmented field of partial third-party clients.

That framing needs an update.
There is credible, first-hand evidence that GitLab is actively developing infrastructure for a mobile app of its own: a multi-part contribution to GitLab's own codebase adds device push registration and server-initiated notification delivery, authored by a senior GitLab product staff member, describing an explicit product vision for a mobile app framed around GitLab's AI-assistant ("Duo") workflows.
As of this writing, nothing has been announced publicly, no app has shipped, and the work observed is narrow: it is gated behind feature flags, scoped to a single notification type, and built only for one mobile platform.
It is nonetheless a stronger signal than the earlier "settled field, no incumbent coming" framing assumed, and it should be treated as a credible, in-progress effort rather than dismissed.

Weighed against that signal, Gitsune's structural differentiators are unaffected by it: a single codebase covering both major mobile platforms rather than one, a self-hosted instance treated as a first-class target from the start rather than a SaaS-only or admin-configured extension, an open-source license with no proprietary tie-in, and a full-breadth feature set (merge request review, CI/CD, code browsing, issues, and notifications together) rather than a narrower assistant-monitoring surface.
Gitsune's notification architecture (`docs/decisions/0002-notification-architecture.md`) preserves a seam for evaluating GitLab's own emerging push infrastructure without requiring an architectural redesign.
Availability on a self-hosted instance is not sufficient for adoption because native push requires APNs credentials bound to Gitsune's app identity.
Using that infrastructure remains conditional on a future credential-sharing arrangement between the project and cooperating instance administrators, and that arrangement has not been designed.

## Decision

Gitsune's strategy is to compete on breadth and reach rather than on any single narrow surface: cross-platform coverage of both major mobile operating systems, self-hosted GitLab treated as a first-class target rather than a secondary one, an open-source license, and full feature breadth across merge requests, CI/CD, issues, code browsing, and notifications together.

Gitsune does not attempt to compete on being the fastest or deepest surface for monitoring AI-assistant activity, and does not position itself as a Duo-centric tool.

## Consequences

This keeps Gitsune's roadmap focused on breadth and reliability rather than chasing a narrower feature it would be poorly positioned to win regardless of what any other party ships.

It also means Gitsune should track, rather than ignore, any public developments toward an official GitLab mobile app, since a shipped official client would validate demand for the category while leaving Gitsune's specific differentiators (the other mobile platform, self-hosted-first design, and an open license) intact.

See `docs/research/market-analysis.md` for the full competitive evidence, including the finding on GitLab's own in-progress work, behind this decision.
