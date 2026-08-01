# 3. v1 scope: the eleven-item feature list

- Status: accepted
- Date: 2026-08-01

## Context

GitHub Mobile is the clearest available functional bar for what a serious, general-purpose git-forge mobile client covers: issues, pull request review with approval, a triaged notifications inbox, code browsing, search, CI/CD status and logs, releases, biometric lock, and multi-account support.
It notably does not offer offline support, release creation, blame, or syntax-highlighted in-app editing, which means those are not parity requirements for Gitsune either.

No existing GitLab mobile client clears that bar.
The most feature-complete one has a closed-source iOS build; the most-installed open-source one is thin (no CI/CD surface, no notifications inbox) and has had self-hosted sign-in break on modern token formats; several others have died or been delisted outright.
Cross-referencing GitHub Mobile's bar against what GitLab's API actually supports, and against where the existing field is weakest, produces a clear priority order: some capabilities (merge request review and approval, CI/CD status) are both heavily requested and thin across the field, which makes them the highest-leverage places to invest first.

Two capabilities are also identified as places Gitsune can exceed GitHub Mobile's own bar rather than merely match it: syntax-highlighted code browsing (GitHub Mobile's own in-app editor lacks syntax highlighting on at least one platform), and a bounded offline read cache (GitHub Mobile has no offline mode at all, and flaky-network resilience is a repeatedly requested capability from self-hosted users specifically).

## Decision

The v1 feature list, in priority order, is:

1. **Instance-URL-first authentication.** OAuth with PKCE for gitlab.com, guided OAuth registration or PAT fallback for self-hosted, per `docs/decisions/0001-auth-posture.md`.
2. **Notifications inbox with triage.** List, filter, mark-done, and open the underlying item, built on GitLab's Todos API.
3. **Merge request review and approval.** List, view diffs, comment inline, resolve threads, approve or unapprove, and merge, with a graceful fallback to viewing on the web for oversized diffs.
4. **CI/CD pipeline and job visibility.** Pipeline and job status, job logs, and the ability to retry, cancel, or run manual jobs.
5. **Issues.** View, create, comment, label, assign, and triage.
6. **Code browsing with syntax highlighting.** Read-only repository tree and file view, deliberately exceeding GitHub Mobile's own editor, which lacks syntax highlighting.
7. **Search.** Projects, issues, and merge requests everywhere; code search where the instance's license tier supports it, with an honest fallback to the web where it does not.
8. **Releases.** View and download release assets; creation is deferred past v1.
9. **Poll-based notifications with local delivery.** The baseline layer described in `docs/decisions/0002-notification-architecture.md`, including scheduled quiet hours.
10. **Security and platform table stakes.** Biometric app lock, dark mode, and multi-instance/multi-account support, all standard expectations for a security-conscious, self-hosted-capable audience.
11. **Bounded offline read cache.** Recently viewed issues, merge requests, and pipelines remain readable without a connection, and comment drafts queue for send when connectivity returns; deliberately exceeding GitHub Mobile, which has no offline mode.

Deliberately out of scope for v1: discussions as a first-class surface, snippets, release creation, epics (which require GraphQL rather than the simpler REST surface most of v1 is built on), gists (GitLab has none, and GitHub Mobile lacks them too), blame, and any AI/agent-assistant surface.
These are candidates for a later release, not commitments.

## Consequences

This scope is deliberately broader than any single existing GitLab mobile client, which is the entire point: no existing client covers this combination, and partial coverage is exactly why the field has stayed fragmented.

Items 1 through 5 are the core that most directly differentiates Gitsune from the existing field and should be treated as the backbone of any v1 build sequencing; items 6 through 11 round out parity and the two intentional points of exceeding GitHub Mobile's own bar.

See `docs/plan/v1-scope.md` for the full gap-analysis matrix this list was derived from, and `docs/research/market-analysis.md` for the underlying evidence.
