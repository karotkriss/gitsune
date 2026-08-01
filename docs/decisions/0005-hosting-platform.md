# 5. Hosting platform: GitHub

- Status: accepted
- Date: 2026-08-01

## Context

A GitLab client could reasonably live on either GitHub or GitLab, and each choice carries real tradeoffs that are about optics and delivery mechanics rather than raw technical capability; both platforms are production-grade for open-source CI/CD in 2026.

Hosting on GitLab would be the on-brand, dogfooding choice: a GitLab client living on GitLab, exercising the same REST and GraphQL surface it targets, and it would keep the F-Droid submission workflow (which itself lives on GitLab, regardless of where the app's own source lives) on a single forge.
Its cost is that GitLab's free CI tier does not include macOS runners, so building and signing the iOS leg would need a separate service such as Codemagic, or a self-hosted Mac runner.

Hosting on GitHub trades that dogfooding story away, but GitHub Actions includes macOS runners in its standard tier, which removes the extra moving part for iOS builds, and GitHub carries the largest open-source contributor pool and the best general discoverability for an OSS project trying to attract contributors.

## Decision

Gitsune is hosted on GitHub, as `karotkriss/gitsune`, public from the start.

## Consequences

The project gives up the dogfooding story of a GitLab client living on GitLab, and F-Droid submission still routes through a merge request on GitLab regardless of where Gitsune's own source lives, so that part of the workflow spans two forges.

In exchange, iOS CI has a lower-friction default path, since GitHub Actions' included macOS runners cover it without an additional third-party CI service.

**Open detail, not yet settled:** the exact CI implementation on GitHub, specifically whether GitHub Actions' included macOS runners are sufficient on their own for the full iOS build, sign, and TestFlight/App Store upload pipeline, or whether a Flutter-focused CI service is still worth adding for its build-time economics or tooling, is left for development time rather than decided here.
