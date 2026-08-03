# Gitsune Design System

Gitsune is a cross-platform Flutter GitLab client for phones and tablets.
Self-hosted instances are first-class, authentication is OAuth-first, the planned feature breadth includes MR review, CI/CD, issues, to-dos, and code browsing, and the project operates **no servers, ever**.
GitLab has never shipped an official mobile app; Gitsune fills that gap.

**The one-line rule: GitHub Mobile decides how the app moves; Pajamas (GitLab's design system) decides how it speaks and what things are called. The 2026 look is dark-mode-only "liquid glass" for v1: GitLab-orange accent, glass chrome floating over opaque content, heaviest on overlays.**

## Sources

- Repo: <https://github.com/karotkriss/gitsune>.
  Read `docs/research/design-direction.md` and `docs/design/design-references.md` (surface-by-surface reference screenshots with Mobbin links) to design against this product.
  `docs/plan/v1-scope.md` lists every v1 capability.
- Pajamas: <https://design.gitlab.com> (color, type-fundamentals, iconography, components, brand-voice)
- Token values vendored verbatim from npm `@gitlab/ui@135.1.1` (`vendor/gitlab-tokens.css`, `.dark.css` — reference only, not imported); fonts from `@gitlab/fonts@1.3.1`; icons/illustrations from `@gitlab/svgs@3.163.0`. All open source.
- One deliberate divergence: the maintainer's direction sets **brand orange** (from the current GitLab tanuki: #fca326/#fc6d26/#e24329) as the interactive & brand color — superseding both the repo's original blue-confirm rule and gitlab-ui's neutral buttons (`docs/decisions/0007-interactive-color-orange-over-blue.md`). Blue remains the info/progress *status* color (running pipelines, MR-merged badges); purple is retired to data-viz and the upstream illustration set.

## Third-party licenses

This design system redistributes design tokens, fonts, and icons/illustrations from GitLab's own open-source packages, verbatim.
Each package's license text ships alongside the files it covers:

- `vendor/gitlab-tokens.css`, `vendor/gitlab-tokens.dark.css` — from npm `@gitlab/ui@135.1.1`, MIT license, text at `vendor/LICENSE-gitlab-ui.txt`.
- `assets/icons/gitlab-icons.svg`, `assets/icons/gitlab-file-icons.svg`, `assets/illustrations/*.svg` — from npm `@gitlab/svgs@3.163.0`, MIT license, text at `assets/LICENSE-gitlab-svgs.txt`. The file-type icon set additionally carries third-party trademarks (language and tool logos), which remain the property of their respective owners; see `assets/icons/NOTICE-file-icons.md`.
- `assets/fonts/GitLabSans.woff2`, `assets/fonts/GitLabSans-Italic.woff2` — from npm `@gitlab/fonts@1.3.1`, SIL Open Font License 1.1 (GitLab Sans is derived from Inter), text at `assets/fonts/LICENSE-gitlab-sans.txt`.
- `assets/fonts/GitLabMono.woff2`, `assets/fonts/GitLabMono-Italic.woff2` — from npm `@gitlab/fonts@1.3.1`, SIL Open Font License 1.1 (GitLab Mono is derived from JetBrains Mono), text at `assets/fonts/LICENSE-gitlab-mono.txt`.

This repository's own license is not yet decided (see `README.md`); the licenses above govern only the vendored files they accompany, regardless of what license this repository eventually adopts.

## Content fundamentals

- **Voice**: plain, quiet, factual. "Merge request merged." "Pipeline failed." Never celebratory ("Woohoo! 🎉"), never vague ("Oops!"). Transparent about limits: notifications are "near-real-time, honestly not instant".
- **Casing**: sentence case for everything — titles, buttons, labels. No title case, no ALL CAPS.
- **Terminology is design** (GitLab nouns, never GitHub's): Merge Request (!142) not PR; Pipeline not Checks; To-Do List not notifications; Project/Group not repo/org; Approvals not reviews; component names are Pajamas' — Alert, Toast, Badge, Label, Token (never "chip"/"tag"), Card, Drawer, Modal, Tabs, Skeleton, Avatar.
- **References**: issues `#123`, MRs `!123`, pipelines `#88123` — always in GitLab Mono.
- **Emoji**: never in UI copy. Reactions (user content) are the only emoji surface.
- **Person**: address the user as "you"; the app speaks as itself without "we".
- Errors name the thing and the next step: "Unable to reach gitlab.example.com. Check the URL or your connection, then try again."

## Visual foundations

- **Color**: five 11-step data ramps + 14 neutrals (`tokens/colors.css`) plus the Gitsune brand ramp (`--gs-color-brand-*`, built on the tanuki oranges). Semantics: **orange = interactive + brand** (buttons, links, active states, focus, badges); blue = info/progress status; green = success/done/approved; orange-500 data ramp = warning/pending; red = critical/failed/destructive ONLY (closed items are neutral, never red); purple = data-viz & illustrations only. Home tiles keep fixed data colors: Issues green, MRs blue, To-Dos orange, Pipelines purple.
- **Type**: GitLab Sans (UI) + GitLab Mono (every git reference — hard rule). Two weights: 400 body, 600 headings/input labels (500 only for tab-bar/tile labels). Fixed mobile scale 12/13/14/16/18/21/24/28; screen titles 28/600; line-height 1.25 headings, 20px body.
- **Spacing**: 8px grid. Screen padding 16, list rows 10–12/16, card gap 12, section gap 24. Touch targets ≥44pt with 20–24px glyphs.
- **Radii**: 10 controls (buttons/inputs, `--gs-radius-control`) · 4 tokens/tags · 8 tiles/alerts/code · 12 cards · 16 drawers/modals · 28 bottom sheets · full capsules for glass chrome, badges, labels. Users are circles; projects/groups rounded squares.
- **Backgrounds**: flat solid surfaces only — no gradients, no textures, no background imagery. Screens sit on `--gs-surface-subtle` with white/near-black cards; sign-in on plain `--gs-surface-app`.
- **Borders**: hairline (1px) `--gl-border-color-subtle/default`; dividers inset to content. Cards = border + barely-there 2%-alpha shadow.
- **Liquid glass** (`--gs-glass-*`): the floating chrome layer — capsule tab bar, bottom sheets, modals, toasts — is translucent (55–85% surface) with `blur(24px) saturate(1.8)`, a 1px inner top highlight, a hairline alpha ring, and a soft drop shadow. The maintainer's direction leans this glass heavier app-wide than a typical translucent chrome layer, and weights it further by surface: the tab bar and toasts use the lighter `--gs-glass-bg`, while overlays — Drawer and Modal — use the heavier `--gs-glass-bg-strong`, making overlays the heaviest glass treatment in the app. Content (cards, lists, headers) stays opaque; glass never stacks on glass. Scrims 40% black (60% dark).
- **Elevation**: beyond glass chrome, rare — flat surfaces + hairline borders; `--gl-shadow-sm/md/lg` reserved for the odd floating element.
- **Hover** (pointer contexts): darken one ramp step; neutral surfaces tint with `--gs-press-overlay`. **Press**: darken two steps or stronger overlay; tab items dim to 70% opacity. No shrink/scale effects.
- **Focus**: 2px brand-orange ring with 1px surface keyline (`--gs-focus-ring`).
- **Motion**: quick and quiet — 100ms color transitions, 200ms fades, 250ms sheet slide-up `cubic-bezier(.2,.7,.3,1)`, 1.8s skeleton shimmer. No bounces, no springs.
- **Transparency/blur**: glass chrome only (see Liquid glass above) — never on content.
- **Imagery**: none. Brand illustration SVGs (purple, from GitLab's open-source set) appear only in empty states; avatars are user content with tinted-initial fallbacks.
- **Dark mode only for v1**: dark is the only theme v1 ships (`data-theme="dark"`; the app shell defaults to it and offers no theme switch). Status colors brighten to the 300 step in dark. The light-theme ramps still defined in `tokens/colors.css` are a foundation for a future release, not a v1 surface — see `docs/decisions/0008-dark-mode-only-v1.md`.

## Iconography

- **Single glyph source**: GitLab's own SVG library, vendored verbatim — `assets/icons/gitlab-icons.svg` (UI sprite, 500+ symbols) and `assets/icons/gitlab-file-icons.svg` (file types). 130 curated glyphs are extracted into `components/core/iconPaths.js` for the `Icon`/`CiIcon` components (regenerate from the sprites, never redraw). 16px grid, 1.5px strokes, rounded caps, `currentColor`-inheriting; render 20–24px inside 44pt targets.
- **Pipeline status set** (`status_success`, `status_running`, …) is the recognizable circular set — use `CiIcon` so the status→color mapping stays fixed.
- No icon font, no PNG icons, no emoji-as-icons. Unicode glyphs only for text-level marks (·, ×, −).
- **Illustrations**: `assets/illustrations/` — GitLab's upstream empty-state set, which is purple-toned; kept verbatim (official assets, never redraw). Flag: they predate the orange rebrand — replace when Gitsune gets its own set.
- **Logo: none exists.** Gitsune has no drawn mark yet; render the name "Gitsune" in GitLab Sans 600 — white on brand orange, or orange on dark (see `guidelines/brand-wordmark.card.html`). Do not use GitLab's tanuki as Gitsune's brand.

## Index

- `styles.css` → imports `tokens/` (fonts, colors, semantic, typography, spacing, elevation, base)
- `assets/`: fonts (GitLab Sans/Mono variable woff2), icon sprites, illustrations, the versioned social-preview images (`gitsune-social-preview.png` flat, `gitsune-social-preview-product.png` product-forward), and the third-party license texts covering them (see "Third-party licenses" above)
- `components/` — `core/` Icon, CiIcon · `actions/` Button · `display/` Avatar, Badge, Label, Token, Skeleton · `feedback/` Alert, Toast · `containers/` Card, Tabs · `overlays/` Drawer, Modal · `navigation/` TabBar, ListRow, Tile. Each has `.d.ts` + `.prompt.md` + a specimen card.
- `ui_kits/gitsune-app/` — the seven documented surfaces as an interactive phone mock (`index.html`, all logic in `GitsuneApp.jsx`): SignIn, Home, TodoInbox, MergeRequest (+DiffView), IssueView, Explore, Profile (switcher), CodeBrowser
- `templates/app-screen/` — "Gitsune app screen" template for consuming projects (tweakable surface + theme)
- `guidelines/` — foundation specimen cards (type, colors, spacing, brand)
- `vendor/` — upstream gitlab-ui token CSS for cross-reference, plus its license text
- `github.md` — source-repo sync record · `SKILL.md` — agent skill entry

### Intentional additions (not in Pajamas' mobile-less spec)

`Icon`/`CiIcon` (glyph wrappers), `TabBar`, `ListRow`, `Tile`, `PhoneShell`/`NavHeader`/`LargeTitle` (mobile shell) — interaction shapes borrowed from GitHub Mobile per the design direction; everything else follows Pajamas names.

### Building new screens

Compose from tokens + components; never hardcode hex. Dark is the only v1 theme — the light ramps (`:root`) exist in the token set for a future release but are not a v1 target. Glass belongs to floating chrome only, heaviest on overlays. Keep GitLab's nouns and the quiet voice. When a surface has no precedent here, follow GitHub Mobile's interaction shape and re-skin it with these tokens.
