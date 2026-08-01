# v1 scope

This document is the detailed feature list and gap analysis behind `docs/decisions/0003-v1-scope.md`.
See that decision record for the accepted list and its rationale; this document provides the full supporting matrix.

## Gap matrix

For each capability: whether GitHub Mobile supports it (the functional bar, see `docs/research/market-analysis.md`), whether GitLab's API supports it, how well the existing field of GitLab mobile clients covers it, and Gitsune's v1 call.

| Capability | GitHub Mobile | GitLab API support | Existing field coverage | v1 call |
| --- | --- | --- | --- | --- |
| Instance-URL-first sign-in | Self-hosted supported | PKCE yes; no cross-instance application | A few clients use OAuth; most use a Personal Access Token | v1 core: OAuth with PKCE for gitlab.com, guided OAuth registration or PAT fallback for self-hosted |
| Notifications inbox with triage | Yes, rich | Yes (Todos API) | Weakly covered; most clients lack it entirely | v1 core - a clear differentiator against the field |
| Merge request review and approval | Yes | Yes | Covered by only the strongest clients | v1 core - the single most-requested capability |
| MR diff, inline comments, thread resolution | Yes | Yes, with size limits on very large diffs | Partial | v1 core, with a view-on-web fallback for oversized diffs |
| CI/CD status, logs, retry/cancel/run manual jobs | Yes | Yes, complete | Covered by only the strongest clients | v1 core |
| Issues: view/create/comment/triage | Yes | Yes | Broadly covered | v1 core |
| Code browsing with syntax highlighting | Browsing yes; in-editor highlighting no | Yes | Partial | v1, read-only, deliberately exceeding GitHub Mobile's own editor |
| Search (projects/issues/MRs) | Yes | Yes, basic | Varies | v1 core |
| Code search (cross-repository) | Yes | Restricted to higher GitLab license tiers | Rare | v1 where the instance's tier supports it, honest fallback to web otherwise |
| Releases (view + download assets) | Yes (view only) | Yes | Rare | v1 (view/download); creation deferred |
| Push notifications | Yes, scheduled | No push API | Claimed by only a few clients | v1: layered polling + opt-in channels, per `docs/decisions/0002-notification-architecture.md` |
| Offline read cache | No | Not applicable (client-side) | Rare | v1 differentiator, deliberately exceeding GitHub Mobile |
| Biometric app lock | Yes | Not applicable | Rare | v1, table stakes for a security-conscious audience |
| Dark mode | Yes | Not applicable | Common, but not universal | v1, platform table stakes |
| Multi-instance / multi-account | Yes | Not applicable | A few clients | v1, since self-hosted users routinely run more than one instance |
| Discussions as a first-class surface | Yes | Yes | Partial | Deferred past v1 |
| AI/agent assistant surface | Yes (Copilot) | Not researched | No | Out of scope, per `docs/decisions/0006-strategy-and-positioning.md` |
| Gists / snippets | No (gists) | Snippets API exists | Some clients | Out of v1 scope (GitHub Mobile lacks gists too) |
| Blame | No | Yes | No | Out of v1 scope |
| Epics | Not applicable | GraphQL-only, REST deprecated | No | Out of v1 scope; would require the app to stop being REST-only |

## The v1 feature list, in priority order

1. Instance-URL-first authentication (`docs/decisions/0001-auth-posture.md`)
2. Notifications inbox with triage
3. Merge request review and approval
4. CI/CD pipeline and job status, logs, retry/cancel/run manual jobs
5. Issues: view, create, comment, label, assign, triage
6. Code browsing with syntax highlighting
7. Search across projects, issues, and merge requests, with code search where available
8. Releases: view and download assets
9. Poll-based notifications with local delivery, scheduled quiet hours (`docs/decisions/0002-notification-architecture.md`)
10. Security and platform table stakes: biometric app lock, dark mode, multi-instance/multi-account
11. Bounded offline read cache

## Explicitly deferred, not committed

Discussions as a dedicated surface, snippets, release creation, epics (a GraphQL-only dependency), and richer saved-filter shortcuts are reasonable v1.x candidates once the core list above has shipped, but none of them are commitments.

## Explicitly out of scope

Gists (GitLab has none, and neither does GitHub Mobile), blame, and any AI/agent-assistant surface are out of scope, per the positioning decision in `docs/decisions/0006-strategy-and-positioning.md`.
