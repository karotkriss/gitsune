---
name: gitsune-design
description: Use this skill to generate well-branded interfaces and assets for Gitsune (the open-source GitLab mobile client), either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.
If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here to become an expert in designing with this brand.
If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts _or_ production code, depending on the need.

Non-negotiables when designing for Gitsune: dark-mode-only liquid glass for v1 (glass chrome — capsule tab bar, sheets, toasts, heaviest on Drawer/Modal — over opaque content; no light theme in v1), brand orange `--gs-color-brand-*` (from the current GitLab tanuki) as the only interactive/brand color, status semantics untouched (green success, red failure/destructive only, blue info/progress, purple data-viz/illustrations only), GitLab Sans + GitLab Mono (mono for every git reference), GitLab's own SVG icons (never redraw), GitLab nouns (Merge Request, Pipeline, To-Do List, Project, Group), plain quiet copy, 44pt touch targets.
