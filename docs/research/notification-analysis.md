# Notification channel analysis

This document works through every near-real-time GitLab notification channel that does not require this project to operate a relay server, and explains why the layered architecture in `docs/decisions/0002-notification-architecture.md` looks the way it does.

Claims are sourced inline.
Claims not backed by a cited source are marked `[inferred]`.

## Two separate walls

Every channel below is really being tested against two independent constraints, and keeping them separate is what makes the analysis honest.

- **Wall A, the GitLab layer:** is there a per-user event source that can be subscribed to without running a server? The answer is yes, in several forms: notification email, IMAP IDLE against a mailbox, GraphQL subscriptions over GitLab's real-time channel, and Atom/RSS feeds.
- **Wall B, the mobile operating system layer:** can the app be woken while closed, without an app-owned Apple Push Notification service (APNs) or Firebase Cloud Messaging (FCM) relay? The answer is no on iOS for any approach that depends on holding a persistent background connection, and roughly a 15-minute best-effort floor on Android for background polling.

A channel can clear Wall A (real per-user push data exists) and still fail Wall B on iOS.
The only channels that clear Wall B on iOS without this project operating a relay are the ones where some other party already operates the push relay: a third-party notification service the user connects themselves, or, prospectively, GitLab's own emerging native push capability.

Sources: Apple developer documentation on background execution limits (`BGAppRefreshTask`, background fetch, Low Power Mode); Android developer documentation on `WorkManager`'s periodic-task floor and Doze-mode deferral.

## Option matrix

| Channel | Delivers | Latency | Scope | Setup burden | Works on closed-app iOS? | Works self-hosted? | Who operates the relay |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Email, watched over IMAP IDLE | Rich, structured headers per event | Push, but not on iOS | Per-user | High (mailbox credentials) | No | Yes | Nobody (impossible without a relay) |
| Email via a third-party relay service | Same, as phone push | Near-instant | Per-user | Medium | Yes | Yes | The relay service, not this project |
| Atom/RSS feeds | Activity stream, deep links | Real-time on read, but pull only | Per-user or per-project | Low (one token in a URL) | Pull only | Yes | Nobody (it's a pull, not push) |
| Conditional-request polling of the Todos API | Structured unread/todo model | Seconds in foreground; ~15 min Android background; best-effort iOS background | Per-user | Medium | Pull only | Yes | Nobody (it's a pull, not push) |
| GraphQL subscriptions over GitLab's real-time channel | Granular per-object push | Sub-second, foreground only | Mostly per-object, one genuinely per-user subscription | Low (just a token) | No | Yes | Nobody (foreground-only, no relay needed) |
| User-owned webhook into a self-chosen push service (ntfy, Pushover) | Selected events as phone push | Near-instant | Per-project, owner-configured | High | Yes | Yes | The push service the user chose |
| Built-in chat integrations (Telegram, Discord, and others) | Selected events into a chat app | Near-instant | Per-project, owner-configured | Medium | Yes | Yes | The chat provider |
| GitLab's own emerging native push capability | Server push on to-do creation | Near-instant | Per-user | Unresolved (requires app-bound APNs credentials) | Yes, once available | Only with an undesigned credential-sharing arrangement | The cooperating GitLab instance sends; APNs delivers |

Only the last three rows deliver real closed-app iOS push without this project operating a relay.
The email-and-IMAP and GraphQL-subscription rows are genuine per-user push, but they die on iOS's background wall; the feed and polling rows are honest, cheap pulls.

## Notification email as a data source

GitLab's notification emails carry a documented, largely machine-parseable header set: a notification-reason header explaining why the user received the mail (assigned, mentioned, review requested, subscribed, and similar values), project and group identifiers, per-object headers combining the object's class, ID, and state, a discussion identifier for threaded comments, and, in current GitLab source, pipeline status headers that are not yet part of GitLab's own published documentation.
Instance, project path, object type, and reason are reconstructable from headers alone, enough to deep-link directly into the relevant item without an extra API call.

The catch is delivery, not data.
A third-party app cannot hold a persistent background IMAP connection on iOS; Apple's own Mail app does not do this either; iOS-native "push" mail only exists where a mail server itself pushes to Apple's push service, which again requires a relay holding Apple push credentials.
A foreground service can hold this connection on Android, at a real battery and persistent-notification cost.
Storing a user's mailbox credentials is also a real security liability worth avoiding.

**Conclusion:** email is a genuinely rich data source, and a real product could be built by running a relay that ingests it (this is exactly how at least one existing third-party GitLab notification bridge works), but "watch the mailbox directly from the phone, no relay" does not work on iOS.

## Atom/RSS feeds

GitLab exposes personal and per-project Atom feeds, gated by a dedicated, narrowly-scoped feed token that only grants feed access, nothing else, which makes it meaningfully safer to store than a general API token.
Feed content is an activity stream (deep links, human-readable titles, timestamps) rather than a structured unread/todo model, and reading a feed is a pull, not a push, subject to the same background-scheduling limits as any other polling approach.

**Conclusion:** feeds are a good low-privilege way to render an activity timeline, but they are not a push mechanism.

Source: GitLab's own documentation on feed tokens (narrowly scoped, feed access only).

## Conditional-request polling, done properly

Polling the Todos API with conditional requests (sending a stored ETag and receiving a lightweight "not modified" response when nothing has changed) is cheap: a reasonable polling interval consumes a small fraction of GitLab's per-user API rate limit, even on self-managed instances with rate limiting enabled.
The real constraint is not request cost but operating-system scheduling: Android's background task scheduler enforces a roughly 15-minute floor on periodic work, deferred further under battery-saving modes, and iOS background execution is opportunistic, can be granted no time at all, and is unavailable when the user has disabled background refresh or enabled a low-power mode.

**Conclusion:** polling the Todos API with conditional requests is the correct, honest baseline: it works on every instance and platform, it is cheap, and it should be presented to users as near-real-time rather than instant.
This is also, effectively, the floor every serious existing GitLab mobile client has already landed on.

## GraphQL subscriptions over GitLab's real-time channel

GitLab's real-time GraphQL subscription channel authenticates with a bearer token (an OAuth access token or Personal Access Token), not only a browser session, which means a mobile app can open an authenticated connection directly.
Its subscription surface covers CI job and pipeline status, issue and merge-request update events, and, notably, one genuinely user-scoped subscription that fires whenever any merge request a user is assigned to or reviewing changes, not just a single object.

The catch: this channel is undocumented as a public contract (GitLab's published API docs cover queries and mutations, not subscriptions), most of its fields are marked experimental, and, like any WebSocket-based channel, it only stays connected while the app is in the foreground; iOS drops it entirely in the background.

**Conclusion:** genuinely useful for live-updating an open screen, and worth using for exactly that, but not something to build the notification story on, since it offers no closed-app delivery on iOS and its contract may change without notice.

## User-owned webhooks and chat integrations

GitLab webhooks fire on a wide range of project and group events, configured by a project or group owner (Maintainer role or above), and GitLab now supports a customizable webhook payload template with custom headers, which means a webhook can be configured to post directly, in the exact format a push service like ntfy or Pushover expects, with no translation layer required.
The user's chosen push service (not this project) then delivers real background push to iOS and Android using its own infrastructure and its own push credentials.
GitLab's built-in chat integrations (Telegram, Discord, Slack, Mattermost, and others) work the same way: the chat provider, not this project, delivers the phone push.

The honest limitation on both: they are per-project, owner-configured, and broadcast every event on that project rather than a personalized "just my notifications" stream.
A user cannot route their own personal notification preferences to their own chat account unless they own the project being watched.

**Conclusion:** these are the two channels that deliver real closed-app iOS push with zero relay operated by this project, precisely because a third party (the push service or chat provider the user chose) already operates that relay.
They work best as an opt-in "advanced" setup, with the app generating the correct webhook configuration for the user, rather than as the primary personal-notification mechanism, given their per-project rather than per-user nature.

Source: GitLab's own documentation on webhooks, webhook custom payload templates, and its shipped chat/integration list.

## GitLab's own emerging native push capability

The most significant finding of this analysis: GitLab is actively building exactly the kind of tap-in mechanism described above, inside its own product, though it has not shipped.
Work observed directly in GitLab's own public source repository adds a device push-subscription registry, a REST API to register and deregister a device (`POST /api/v4/user/push_subscriptions`), and server-initiated push delivery to Apple's push service triggered on to-do creation.
It is gated behind default-off feature flags, is scoped to a single event type (to-do creation, which covers assignments, mentions, and review requests), and is Apple-push-only with nothing for Android as of this research.

The registration call is a standard REST call that an app could make once the capability is enabled, but registration alone does not make the architecture usable by a third-party app.
APNs credentials and device tokens are bound to Gitsune's developer team and app identity, so a self-hosted instance cannot deliver to Gitsune with credentials of its own.
Using this capability would require a future credential-sharing arrangement between the project and cooperating instance administrators.
That arrangement has not been designed, and its security and operational model remains an open question.
On GitLab's own SaaS (gitlab.com), this capability is expected to serve GitLab's own official app rather than being usable by third parties, since it is bound to a single set of push credentials per instance.

**Conclusion:** this is not yet available and cannot be promised as a working Gitsune path until credential ownership is resolved.
Gitsune's notification architecture keeps a device-registration seam so the project can evaluate the capability later without inventing a distribution mechanism now.

Sources: first-hand review of the relevant merge requests and feature-flag issues in GitLab's own public source repository, gitlab.com/gitlab-org/gitlab, dated 2026-07-31.

## What does not exist, for anyone

No mobile GitLab client, including a hypothetical official one, can offer a truly per-user, cross-platform, zero-relay background push firehose today; that combination is not physically possible on iOS under Apple's current platform rules.
Reference apps for other forges that do offer instant push (GitHub Mobile among them) do so because the forge itself operates the relay: sender and server are the same party.
GitLab has no equivalent today, and no public work toward a general "web push" style capability (of the kind some browsers support) is shipped or actively committed, though a related feature request exists in GitLab's own backlog.

## The resulting architecture

See `docs/decisions/0002-notification-architecture.md` for the decision this analysis supports: a layered system built on conditional-request polling as the universal baseline, GraphQL subscriptions for foreground live updates, opt-in Android and iOS paths that route through services the user chooses and controls, and a device-registration interface that preserves the option to evaluate GitLab's native push capability if its credential-ownership question is resolved.
An app-operated relay is excluded permanently, not held in reserve as a fallback.
