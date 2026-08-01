# 2. Notification architecture: layered, no project-operated servers

- Status: accepted
- Date: 2026-08-01

## Context

GitLab has no user-level push notification API of any kind.
Webhooks are server-to-server callbacks that a project owner configures, not a subscription an individual user's phone can register for, and GitLab's real-time GraphQL subscriptions are built for GitLab's own web frontend rather than published as a stable third-party contract.

Both of the two mobile push networks, Apple's APNs and Google's FCM, only deliver to a token bound to a specific app identity, and only whoever holds that app's credentials can send through it.
That means any GitLab instance that wants to wake a closed app on a phone has to go through infrastructure that holds those credentials.
The only way to offer instant push notifications from an arbitrary GitLab instance the app has never seen before is for some party to operate a relay: a server that receives events from GitLab (by polling on the user's behalf or receiving a webhook) and forwards them to APNs or FCM.

If this project operated that relay itself, the project's own servers would see every notification generated for every user who opted in, on every instance, including self-hosted and internal ones.
For an audience that specifically chose self-hosted GitLab, that is a serious trust and privacy cost, and for some self-hosted deployments (air-gapped or network-policy-locked instances) a project-operated relay is simply unreachable regardless of trust.
Running that infrastructure would also commit the project to funding and operating a server indefinitely.

At the same time, GitLab is not standing still on this problem.
Recent work inside GitLab adds a device-registration API and server-initiated push dispatch for to-do notifications, gated behind feature flags and not yet generally available.
GitLab's native push requires APNs credentials bound to Gitsune's own app identity.
Using it on a self-hosted instance therefore requires a future credential-sharing arrangement between the project and cooperating instance administrators.
That arrangement has not been designed and remains an open question.
Separately, GitLab's notification emails already carry a rich, largely machine-readable header set (notification reason, project, object type and ID, and in some cases pipeline status), and GitLab exposes both a documented Todos API well-suited to polling with conditional requests, and a real-time GraphQL subscription channel that authenticates with a bearer token and stays live only while the app is in the foreground.

## Decision

Gitsune's notification system is layered, and the project operates no notification servers of any kind, at any layer, ever.

1. **Baseline, on by default, works on every instance:** conditional-request polling of the Todos API, using stored ETags to keep it cheap, surfaced as local notifications on the device.
   This sets the honest expectation of near-real-time delivery rather than instant push, and it requires no server-side cooperation from any instance.
2. **Foreground:** GraphQL subscriptions over GitLab's real-time channel, authenticated with the user's own token, drive live updates while a screen is open.
   This channel is not available while the app is backgrounded or closed, so it supplements the baseline rather than replacing it.
3. **Android, opt-in:** either a foreground service that polls from the device, or a user-owned webhook-to-gateway bridge with ntfy acting as the UnifiedPush distributor.
   The bridge is the event source for UnifiedPush: a project or group owner configures GitLab to send selected events to the user's ntfy gateway, which then delivers them to Gitsune.
   This path is for users who want closer-to-instant delivery and accept its setup and authorization requirements; only the foreground-service option carries the battery and persistent-notification tradeoffs.
4. **iOS, opt-in:** a guided wizard that helps the user connect their own account on a push-relay service they choose and control, such as ntfy or Pushover, by generating the correct GitLab webhook configuration for them to add.
   The relay in this path is operated by that third-party service, chosen and authorized by the user, never by this project.
5. **Native-push seam:** the device-registration layer is built around a single `registerDevice()` interface so that Gitsune can evaluate GitLab's native per-user push capability without architectural rework if it becomes available.
   Adoption for a self-hosted instance remains conditional on resolving the open question of how cooperating instance administrators can use APNs credentials bound to Gitsune's app identity.

An app-operated relay is explicitly and permanently out of scope.
It is not a fallback held in reserve; it is excluded by this decision.

## Consequences

Gitsune does not offer instant push out of the box on every instance, and that is a deliberate tradeoff rather than a gap to be closed later.
Users who want closer-to-instant delivery have real, working options through the Android opt-in path and the iOS relay-of-your-choice wizard, but neither requires trusting this project with a server role.
GitLab's native push remains a prospective option whose credential-sharing requirement is unresolved.

This decision also means the project carries no notification infrastructure cost or operational burden, which matters for a project with no committed funding model.

Because the architecture is explicitly seamed around GitLab's own emerging native push capability, evaluating it later is a scoped integration rather than a redesign.

See `docs/research/notification-analysis.md` for the full channel-by-channel analysis behind this decision.
