# F-Droid anti-features declaration

Proposed declaration for the fdroiddata metadata: **no anti-features**.

Reasoning against the [anti-feature list](https://f-droid.org/docs/Anti-Features/), for the `fdroid` build flavor (`android/app/build.gradle.kts` owns the FOSS-only dependency boundary):

- **Ads / Tracking:** none; no analytics, advertising, or crash-reporting SDK exists in the dependency tree.
- **NonFreeNet:** does not apply; the app is a client for whatever GitLab instance the user chooses, works fully against self-hosted GitLab CE (free software), and promotes no particular service.
- **NonFreeDep / NonFreeAdd:** the `fdroid` flavor contains free software only; push is UnifiedPush (no Google Play services, no FCM), and any future proprietary dependency is confined to the `play` flavor by the build script.
- **UpstreamNonFree:** the upstream app is the same codebase being submitted.

Note: F-Droid inclusion requires a declared free-software license, and this repository's license is deliberately still TBD (see `README.md`).
The license decision (its own ADR) must land before an F-Droid submission can happen; that is owned by the submission task, not this content.
