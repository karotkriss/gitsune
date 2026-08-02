# GitHub source

repo: karotkriss/gitsune
branch: main

## Last sync

date: 2026-08-02T02:05:00Z

### Updated in this project

- Rebranded to dark-first liquid glass with GitLab-orange accent (maintainer direction — supersedes the repo's blue-confirm rule)
- Built the full design system from the repo's documentation phase (docs/design + docs/research)
- Vendored Pajamas tokens, GitLab Sans/Mono fonts, and GitLab SVG icon sprites from public npm packages

## Screen map

| Project file | Built from |
| --- | --- |
| tokens/*.css | docs/research/design-direction.md, docs/design/design-references.md (Pajamas foundation kit) |
| components/** | docs/design/design-references.md (Pajamas component vocabulary) |
| ui_kits/gitsune-app/SignIn.jsx | docs/design/design-references.md Surface 1, docs/research/auth-blueprint.md |
| ui_kits/gitsune-app/Home.jsx | docs/design/design-references.md Surface 2 |
| ui_kits/gitsune-app/IssueView.jsx | docs/design/design-references.md Surface 3 |
| ui_kits/gitsune-app/MergeRequest.jsx, DiffView.jsx | docs/design/design-references.md Surface 4 |
| ui_kits/gitsune-app/TodoInbox.jsx | docs/design/design-references.md Surface 6 |
| ui_kits/gitsune-app/Profile.jsx | docs/design/design-references.md Surface 7 |
| readme.md voice/terminology | docs/research/design-direction.md, README.md, docs/decisions/0006 |
