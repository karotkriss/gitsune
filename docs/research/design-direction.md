# Design direction

This document summarizes the design research behind Gitsune's visual and interaction language: GitLab's own Pajamas design system as the visual-language baseline, proven mobile interaction patterns from GitHub Mobile and other reference apps for surfaces Pajamas does not cover, and the specific places the two disagree.

Claims are sourced inline.
Claims not backed by a cited source are marked `[inferred]`.

## Part 1: the design-language baseline (Pajamas, translated to mobile)

GitLab's design system, Pajamas (design.gitlab.com), is the source of truth for how Gitsune should look, speak, and name things.
It has no mobile-specific guidance of its own, so this section translates its foundations into mobile terms.

### Color

Pajamas defines five semantic color ramps of eleven steps each: blue for current/active/progress, green for success/done/approved/resolved, orange for warning/pending/attention, red for critical/destructive/error/failed, and purple as GitLab's brand identity color, used sparingly for illustrations and announcements rather than as an interactive color.
Neutral steps run from near-white to near-black for surfaces, borders, and hierarchy, with the same ramp system serving both light and dark themes.
All colors meet WCAG AA contrast requirements.

For Gitsune, the semantic mapping is the identity to preserve exactly: a passed pipeline is green, a running one is blue, a failed one is red, and a pending one is orange, everywhere in the app, with no decorative reassignment.
Interactive color is blue, which happens to match GitHub Mobile's own interactive color, so the two design languages agree here without any translation needed.

Source: design.gitlab.com/product-foundations/color

### Typography

Pajamas specifies GitLab Sans (based on Inter) as the UI typeface and GitLab Mono (based on JetBrains Mono) for code blocks, branch names, commit IDs, and pipeline IDs.
Both are open source, which fits an open-source app well, and both were chosen for tall x-height and variable-font support.
Two weights carry the entire hierarchy: 400 for body text, 600 for headings and input labels.

Gitsune ships both typefaces and treats "monospace for every git reference" as a hard rule at the token level, matching GitHub Mobile's own convention of monospacing branch names and similar identifiers.

Source: design.gitlab.com/product-foundations/type-fundamentals

### Iconography

Pajamas' icon set is GitLab's own open-source SVG library, built on a 16px grid for UI icons and a 12px grid for status icons, with 1.5px strokes and rounded caps.
Icons inherit the surrounding text color by default.

Gitsune uses this icon set exclusively, including GitLab's distinctive circular pipeline-status badges that GitLab users already recognize from the web app.
The one deliberate deviation from Pajamas here is icon size: 16px falls below comfortable mobile touch-target legibility, so Gitsune renders icons at 20-24px inside 44pt touch targets while preserving the 1.5px-stroke look `[inferred]`.

Source: design.gitlab.com/product-foundations/iconography

### Component vocabulary

Pajamas has deliberate, specific names for its components: Alert, Toast, Badge, Label, Token, Card, Drawer, Modal, Tabs, Skeleton loader, and Avatar.
Notably, it does not use "chip" or "tag."
Gitsune's own component layer adopts these names so that contributors and designers can cross-reference GitLab's own documentation directly rather than maintaining a parallel vocabulary.

Source: design.gitlab.com/components/overview

### Voice and tone

Pajamas describes three brand voice traits: visionary, empathetic, and intentional, expressed as plain language, meeting readers at their level, and staying transparent about limitations without being pushy.
Gitsune's UX copy follows this: quiet, factual messaging ("Merge request merged," "Pipeline failed") rather than the more playful marketing tone found in some competing mobile apps.

Source: design.gitlab.com/brand-messaging/brand-voice/

### Terminology

GitLab's own nouns are part of its design language and Gitsune uses them throughout: Merge Request (never "pull request"), Pipeline (never "checks"), the To-Do List (GitLab's own triage inbox concept), Project and Group as the primary organizational nouns (not "repo" or "org"), and Approvals.

## Part 2: surface-by-surface direction

Pajamas has no mobile-specific interaction guidance, so for surfaces it does not cover, Gitsune draws on proven mobile patterns from reference apps, translated into GitLab's visual language and terminology.

### Sign-in, including self-hosted instance entry

Because instance-URL-first sign-in is a core requirement (`docs/decisions/0001-auth-posture.md`), the sign-in screen shows an instance field permanently and prominently, pre-filled with `gitlab.com` and visibly editable, followed by one continue action that opens the instance's OAuth flow in the operating system browser.
The primary screen shows no credential fields.
A Personal Access Token option appears only behind a secondary "having trouble signing in" affordance for instances where OAuth registration is unavailable.
An unreachable or non-GitLab URL produces a clear inline error rather than a silent hang.
This deliberately avoids two weaker patterns seen elsewhere: burying the instance-URL field behind a secondary link, or gating self-hosted entry behind a settings-menu "Enterprise account" afterthought.
Visuals stay neutral and quiet: a light surface, GitLab Sans, one blue confirm action, purple reserved for the logo or an illustration.

### Home and project navigation

The home screen adopts a shortcut-tile pattern (a grid of colored icon tiles mapped to Issues, Merge Requests, To-Do List, Pipelines, Projects, and Groups), editable and reorderable by the user, with tile colors drawn from the Pajamas ramps and glyphs from GitLab's own icon set.
Project detail follows the same shape: a counts list, an inline README, a "Browse code" entry point, and the current branch shown as a monospace chip.
The bottom tab bar carries four destinations: Home, To-Dos/Notifications, Explore/Search, and Profile.
When more than one instance is signed in, Home shows a compact instance indicator so that identical-looking UI across two different instances is never ambiguous `[inferred]`.

### Issue view

Issue detail follows a thread anatomy: a colored state badge, a project/issue-number breadcrumb, the markdown body, state-change events shown inline in the thread, and a comment entry pinned at the bottom, with less-common metadata (assignees, labels, milestone) tucked behind a bottom sheet.
One improvement over a plain thread view: key metadata (status, labels, project) surfaces as a pill row directly under the title rather than being hidden entirely.
GitLab's scoped labels (for example `workflow::in review`) render as their own distinctive two-tone pill style `[inferred, based on GitLab's web rendering of scoped labels]`.
State badge colors follow Pajamas exactly: open is green, closed is neutral or blue, and red is reserved strictly for critical/error states rather than used generically for "closed."

### Merge request view and diff review

This is the highest-leverage screen in the app, per the v1 priority order in `docs/decisions/0003-v1-scope.md`.
The anatomy: a state badge, monospace source-to-target branch chips, a changed-files summary, a collapsible Pipelines section (GitLab's equivalent of "Checks"), a collapsible Approvals section showing required-approval counts, and a merge box combining pipeline status, approval status, and mergeability into one clear action area.
Diff review keeps a hunk-per-file layout with a jump-to-file control and line-level comment entry, rendered in GitLab Mono.
Two deliberate departures from more common mobile patterns, both driven by Pajamas: the merge action button is blue, not green, because Pajamas reserves green for an achieved success state and blue for an in-progress action; and the unresolved-discussion count surfaces directly in the merge box, since GitLab blocks merges on unresolved threads by default `[inferred, based on GitLab's product behavior]`.

### Code browser

The code browser uses a drill-down file list, one directory level per screen with a breadcrumb back, rather than a persistent side tree that phone-width screens cannot comfortably support.
File-type icons from GitLab's own icon collection aid scanning and read as GitLab, matching GitLab's own web repository view.
File view itself uses GitLab Mono, full syntax highlighting, line numbers, and a wrap toggle.

### Notifications and inbox triage

GitLab's To-Do List is already a triage inbox with a "mark as done" verb built in, which maps naturally onto swipe-based triage patterns common in mobile inbox apps: full swipe right marks an item done, swipe left snoozes it, and every destructive swipe shows an undo affordance.
Rows use GitLab's own entity icons colored per Pajamas state, a filter sheet by to-do reason (assigned, mentioned, review requested, pipeline failed), and a designed empty state using a purple illustration as a deliberate brand moment.

### Settings, accounts, and instance switching

Because self-hosted users routinely run more than one account and instance, every account row always shows the account's avatar, username, and host, since host visibility is a genuine safety feature for anyone juggling multiple instances.
Account switching lives in a quick-access sheet reachable from the profile tab, with a separate full settings screen handling add/remove/reorder.
Adding a new account reuses the sign-in screen from the first surface, unchanged, instance field first.

## Part 3: where GitHub Mobile and Pajamas disagree, and which wins

| Conflict | GitHub Mobile's pattern | Pajamas' guidance | Resolution |
| --- | --- | --- | --- |
| Nouns and copy tone | "Pull request," "Checks," occasionally playful copy | "Merge request," "Pipeline," plain and intentional voice | Pajamas wins: the nouns are the product, and GitLab's brand voice guidance is explicit about plain, non-pushy copy. |
| Merge action color | Green button | Blue = in-progress action; green = an achieved success state | Pajamas wins: the merge button is blue, with green reserved for merged/passed states. |
| "Closed" state color | Red used for closed/unplanned items | Red is reserved strictly for critical/error/destructive states | Pajamas wins: closed reads as neutral or blue; red is reserved for failed pipelines and destructive actions. |
| Icon style | Filled, colorful tiles on the home screen; filled glyphs elsewhere | Thin-stroke, monochrome, color-inheriting glyphs | Hybrid: keep the colored-tile pattern for home-screen wayfinding, since it is a proven pattern, but the glyph inside each tile and everywhere else is GitLab's own icon set. |
| Typeface | System font | GitLab Sans / GitLab Mono | Pajamas wins: both faces are open source and are the brand. |
| Instance entry | Tucked into settings as an "Enterprise account" afterthought | No mobile-specific guidance | Neither: an always-visible instance field on the primary sign-in screen wins, driven by Gitsune's own core requirement. |
| Navigation shell, list layout, swipe triage, diff layout, merge-box anatomy | Proven, well-tested patterns | No mobile-specific guidance | GitHub Mobile's interaction shapes win, since Pajamas governs look, language, and semantics rather than mobile interaction design. |

The one-line summary: GitHub Mobile decides how the app moves; Pajamas decides how it looks, speaks, and what things are called.

## Starting kit

1. Pull Pajamas' color ramps, both typefaces, and the icon set (UI, status, pipeline, and file-type collections) as design tokens; all are public and open source and can live directly in this repository once a design system exists.
2. The seven surfaces to design first, in order: sign-in, home, the to-do inbox, merge request view, diff review, issue view, and the account switcher.
   Sign-in and the switcher are where Gitsune differentiates most; the rest deliberately track GitHub Mobile's proven anatomy.
3. Design light and dark themes together from the start; Pajamas' color system is explicitly built for both.
4. Auth mechanics, the offline/error model, and the cross-platform framework's effect on font and system-component fidelity are all design-affecting but owned by separate decisions; see `docs/decisions/0001-auth-posture.md` and `docs/research/technology-assessment.md`.
