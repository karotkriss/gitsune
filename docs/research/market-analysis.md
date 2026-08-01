# Market analysis

This document summarizes the market research behind Gitsune's product direction: the functional bar set by GitHub's official mobile app, the existing field of GitLab mobile clients, the evidence for demand, and what GitLab's public API actually supports.
It backs `docs/decisions/0003-v1-scope.md` and `docs/decisions/0006-strategy-and-positioning.md`.

Claims below are sourced inline.
Claims that could not be verified against a primary source are marked `[inferred]`.

## The headline finding

GitLab has never shipped an official native mobile app.
Its public position, stated by GitLab's CEO on Hacker News in 2015 ("We have no plans for a mobile app at this point") and unchanged through years of inaction since, has been to invest in mobile web instead of a native client.
That is a materially different starting point than "GitLab discontinued its app": there is no incumbent to displace, only a fragmented field of third-party clients that have tried and mostly struggled to fill the gap.

GitLab's own canonical feature request for an official app, still open as of this research, carries a modest number of upvotes over several years, which is consistent with real but long-tail demand rather than a groundswell (see "Demand evidence" below).

## The functional bar: GitHub Mobile

GitHub Mobile is the clearest available reference for what a full-featured git-forge mobile client covers, since no equivalent official GitLab app exists to compare against directly.

| Area | Feature | Status |
| --- | --- | --- |
| Issues | View / create / comment, with assignees, labels, milestones | Supported |
| Pull requests | View / create / comment / merge / edit files in a PR | Supported |
| Code review | Diff view, approve, request changes, inline comments, suggested changes | Supported |
| Notifications | Unified inbox, mark done, unsubscribe, filters, saved shortcuts | Supported |
| Code browsing | Repo tree, file view, jump-to-symbol, in-repo search | Supported |
| | Syntax highlighting while editing a file | Not supported |
| | Blame view | Not supported |
| Search | Repos/users/orgs, global cross-repo code search | Supported |
| Releases | View, read notes, download assets | Supported (creation not supported) |
| Discussions | Browse / reply / create | Supported |
| CI (Actions) | Workflow runs, jobs, logs, re-run, cancel, trigger | Supported |
| Push notifications | Event-based, scheduled quiet hours, per-repo opt-in | Supported |
| Offline | Reading, caching, draft queue | Not supported |
| Platform/UX | Dark mode, biometric app lock, multiple accounts | Supported |
| Self-hosted (GitHub Enterprise Server) | Sign-in supported with an admin opt-in; VPN caveat | Supported with constraints |
| Gists | View/create | Not supported |

Sources: docs.github.com/en/get-started/using-github/github-mobile; docs.github.com/en/enterprise-server (GitHub Mobile pages); github.blog/changelog posts on code review, code search, Actions, releases, discussions, app lock, and push scheduling (2021-2026); github.com/orgs/community/discussions threads on offline support, editor syntax highlighting, gists, release creation, and issue/PR search (community-sourced, corroborating rather than primary).

The gaps in GitHub Mobile itself matter as much as its strengths: no offline mode, no gists, no release creation, no blame, and no syntax highlighting in its own in-app editor.
None of these are parity requirements for Gitsune just because they feel like "mobile app things"; offline support in particular is treated as an opportunity to exceed GitHub Mobile's bar rather than merely match it (see `docs/decisions/0003-v1-scope.md`, item 11).

## The existing landscape

No official first-party GitLab mobile client has ever existed.
(GitLab did open-source the Gitter chat apps in 2019 before divesting Gitter entirely in 2020, but that was a chat client, unrelated to issues, merge requests, or CI.)

| Client | Platform | Status | License | Self-hosted sign-in | Coverage |
| --- | --- | --- | --- | --- | --- |
| LabCoat | Android | Active, slow-moving | Open source | PAT-based; broke on modern token format | Low-medium: no CI, no notifications |
| GitTouch | Android/iOS/desktop | Active | Open source | Yes, custom domain | Medium: code, issues, MRs, notifications; no CI |
| GitAlchemy | Android/iOS/desktop | Active | Mixed (iOS build appears closed) | Yes | High: issues, MR review/approve, CI/CD monitoring; no releases |
| LabNex | Android | Active, newest | Open source | Yes, including self-signed certs | Medium: issues, MRs, release creation; no CI |
| GitFox | Android/iOS/web | Dead since 2021 | Open source | Yes, OAuth | Medium, frozen |
| GitLab Control | iOS | Active | Proprietary | Yes | Medium: no MR approvals, no dark mode |
| Tanuki for GitLab | iOS/watchOS/macOS | Active | Proprietary | Yes, multi-instance | Low-medium: no CI |
| NativeLab | iOS/macOS | Active, new | Proprietary, free | Yes, OAuth | Medium |
| GitBlur | iOS/macOS | Delisted | Proprietary, subscription | Yes | Was high coverage, now unavailable |
| Git+ for GitLab | Android/iOS | Dead, broken | Open source | Broken in practice | Near-zero, login reportedly broken |

Sources: F-Droid and app store listings for each client; each project's own issue tracker (cited for specific claims such as LabCoat's self-hosted sign-in regression, gitlab.com/Commit451/LabCoat/-/issues/477 and /516); gitalchemy.app/blog/top-gitlab-android-clients.

**What the field's weaknesses have in common:** the market is fragmented across roughly a dozen mostly solo-maintained projects, with a recurring failure pattern of a solo maintainer losing momentum, authentication breaking on a GitLab API or token-format change, and the app slowly rotting.
The two most feature-complete efforts are each compromised in a different way: the highest-coverage client has a closed-source iOS build, and the other high-coverage client was subscription-gated and has since been delisted entirely.
Even the most-installed open-source client is thin (no CI/CD surface, no notifications inbox) and has had self-hosted sign-in regress on the modern token format, which is precisely the failure mode Gitsune's authentication approach is designed to avoid (`docs/decisions/0001-auth-posture.md`).

The open, cross-platform, CI-and-notifications-complete, OAuth-first, self-hosted-first slot is empty.
That is the gap Gitsune targets.

## Demand evidence

The most-cited want across issue trackers, forums, and third-party app marketing is reviewing and approving merge requests on the go; it is the headline feature of the field's strongest existing client and the sole purpose of at least one single-feature app.
Push notifications for CI failures, approvals, and mentions rank second, closely followed by triaging issues and todos on the go, CI/CD pipeline status monitoring, and working reliably on flaky connections.

Self-hosted GitLab is a repeated, explicit differentiator across demand signals: independent evidence points to self-hosted users specifically describing themselves as poorly served by existing mobile options, and third-party clients that do well in this space consistently advertise self-hosted or custom-instance support as a named feature.
This validates instance-URL-first authentication as a core requirement rather than a nice-to-have, which is why it is item one in Gitsune's v1 scope (`docs/decisions/0003-v1-scope.md`).

Raw demand signals (upvote counts on GitLab's own feature request) are modest in absolute terms, on the order of single digits to a few dozen over several years.
The stronger evidence is indirect: the persistent supply of third-party clients trying to fill this gap, and high-traffic forum threads asking where an official app is.

Sources: gitlab.com/gitlab-org/gitlab feature requests and issues on an official app and related mobile-review UX; forum.gitlab.com threads on GitLab mobile clients and mobile merge-request review; news.ycombinator.com discussion of GitLab's 2015 statement on mobile strategy.

## The API reality

GitLab's public API mostly supports a GitHub-Mobile-equivalent client, with two constraints that meaningfully shape the product.

**Authentication.** OAuth2 Authorization Code with PKCE is fully supported and is GitLab's own recommended flow for public mobile clients, but OAuth application identity is instance-local: there is no shared or cross-instance application a third party can register once and use everywhere.
GitLab is building dynamic client registration (RFC 7591), but as of this research that capability is fenced to a specific protocol integration rather than available to general third-party apps.
This is the direct basis for `docs/decisions/0001-auth-posture.md`; see `docs/research/auth-blueprint.md` for the full implementation detail.

**Push notifications.** GitLab has no user-level push notification API of any kind.
Webhooks are project-owner-configured server callbacks, not per-user subscriptions a phone can register for.
This is the direct basis for `docs/decisions/0002-notification-architecture.md`; see `docs/research/notification-analysis.md` for the full channel-by-channel analysis.

**Other API characteristics relevant to v1 scoping:**

| Capability | GitLab API support | Note |
| --- | --- | --- |
| Issues | Full REST and GraphQL | - |
| MR approve/unapprove/merge | Full REST | - |
| MR diffs | Full REST | Server-side size limits on very large diffs; needs a progressive-fetch or view-on-web fallback |
| Todos/notifications inbox | Full REST and GraphQL | The closest equivalent to GitHub's inbox model; well-supported |
| CI/CD pipelines and jobs | Full REST, including retry/cancel/run-manual-job and job logs | Maps cleanly to a mobile CI/CD surface |
| Repository file browsing | Full REST | Rate-limited for large blobs |
| Code search | Restricted to higher GitLab license tiers | Most free-tier and self-hosted Community Edition instances cannot code-search via the API at all; degrade gracefully |
| Releases | Full REST | - |

Sources: docs.gitlab.com/api/oauth2/; docs.gitlab.com/integration/oauth_provider/; docs.gitlab.com/api/merge_requests/; docs.gitlab.com/api/todos/; docs.gitlab.com/api/pipelines/; docs.gitlab.com/api/search/; docs.gitlab.com/api/releases/; docs.gitlab.com/user/gitlab_com/ (rate limits).

## Competitive landscape update: GitLab's own emerging mobile work

Later research surfaced first-hand evidence, read directly from GitLab's own public source repository, that GitLab is actively developing infrastructure for a mobile app of its own.
A four-part contribution to GitLab's codebase adds a device push-subscription registry, a REST API for registering a device, and server-initiated push delivery on to-do creation, authored by a senior GitLab product staff member.
The contribution's own description states an explicit product vision: the app is framed as a "Command Center" for monitoring GitLab's AI-assistant ("Duo") workflows, with push notifications as its first concrete feature.

As of this research, none of this work has shipped or been publicly announced.
It is gated behind default-off feature flags, scoped to a single notification type (to-do creation), and built for one mobile platform only (iOS, via Apple's push service; nothing for Android).
No public repository, announcement, or product-direction page for a GitLab-branded mobile app exists.

This is a real, credible signal and it changes the competitive framing, but it does not close the gap Gitsune targets.
If GitLab ships an official app along the lines this work suggests, it would plausibly cover gitlab.com iOS notifications for Duo-centric workflows, a narrower and more assistant-focused surface than Gitsune's planned full-breadth, cross-platform, self-hosted-first, open-source scope.
See `docs/decisions/0006-strategy-and-positioning.md` for how this shapes Gitsune's positioning, and `docs/decisions/0002-notification-architecture.md` for the seam that lets Gitsune evaluate GitLab's own push infrastructure without an architectural redesign.
Enabling the infrastructure on a self-hosted instance does not make it usable by Gitsune because native push requires APNs credentials bound to Gitsune's app identity.
Adoption remains conditional on an unresolved future credential-sharing arrangement between the project and cooperating instance administrators.

A newer third-party competitor was also identified during this update: a native iOS client in beta testing with a unified inbox, merge request review and merge, issue support, and CI/CD pipeline status.
Its existence is further evidence that the iOS GitLab-client field is actively growing rather than static, which reinforces cross-platform coverage, not iOS alone, as a durable differentiator for Gitsune.

Sources: first-hand review of the relevant merge requests and feature-flag issues in GitLab's own public source repository, gitlab.com/gitlab-org/gitlab, dated 2026-07-31; GitLab's official handbook and press pages (no mobile-app announcement found as of this research); public app store beta listings.
