# 4. App store launch scope: all three stores at v1

- Status: accepted
- Date: 2026-08-01

## Context

Three distribution channels are realistic for a Flutter mobile app: the Apple App Store, Google Play, and F-Droid.
Each has a different cost and a different fit with Gitsune's audience.

Apple charges a recurring $99/year developer program fee and requires building on a Mac (directly, via a hosted Mac CI runner, or via a Flutter-focused CI service with free macOS build minutes).
Google charges a one-time $25 registration fee; a newly created personal Play account must additionally clear a closed-testing period with a minimum number of opted-in testers before it can publish to production, while an organizational account is exempt from that gate but requires verified organization identity.
F-Droid is free to submit to and has no developer fee, but it enforces a fully free-and-open-source toolchain and forbids proprietary tracking or push services (specifically Google's Firebase Cloud Messaging) in the build it distributes, which requires shipping a distinct build flavor with those dependencies removed.

That F-Droid constraint is not a cost unique to F-Droid: Gitsune's notification architecture (`docs/decisions/0002-notification-architecture.md`) already avoids any project-operated push relay and treats any proprietary push service as opt-in rather than required, so an F-Droid-compatible build flavor is a natural fit rather than an added burden.
A comparable open-source Flutter app already ships successfully on F-Droid with exactly this kind of Firebase-free build flavor, which is direct evidence the approach works in practice.

## Decision

Gitsune launches on all three stores, the Apple App Store, Google Play, and F-Droid, at v1, rather than staggering the rollout.

## Consequences

This commits the project to the Apple developer program's recurring fee and to having a way to produce signed iOS builds (a Mac, a hosted Mac runner, or a CI service with macOS build minutes) from the start, rather than deferring that cost past initial launch.

It also means the build and release pipeline needs to support distinct signing identities and, for F-Droid, a distinct build flavor with proprietary push dependencies removed, from day one rather than as a later addition.

In exchange, Gitsune reaches its full intended audience, including the F-Droid and privacy-conscious self-hosted segment that a staggered, Android-first rollout would otherwise delay, from the first release rather than as a fast-follow.

See `docs/research/technology-assessment.md` for the underlying cost and mechanics detail behind each store, including signing, review process, and F-Droid's inclusion requirements.
