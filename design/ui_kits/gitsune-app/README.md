# Gitsune app UI kit

The seven documented surfaces (docs/design/design-references.md in the source repo) as one interactive phone mock.

- `index.html` — full click-through (all logic in `GitsuneApp.jsx`): starts signed in on Home; Profile → avatar row opens the account switcher; Appearance cycles light/dark/auto (a reference toggle for exercising the mock against both token sets — v1 itself ships dark mode only, see `docs/decisions/0008-dark-mode-only-v1.md`); sign out returns to the sign-in surface. Tiles push MR/Issue/Code screens; To-Dos support done-with-undo and the filter sheet.
- Screens: `SignIn` (instance-URL-first), `Home` (My Work tiles), `TodoInbox`, `MergeRequest` (Overview/Changes/Pipelines + orange merge box), `DiffView`, `IssueView`, `Explore`, `Profile` (+switcher, settings), `CodeBrowser`. Shell pieces: `PhoneShell`, `NavHeader`, `LargeTitle`; sample content in `data.js`.
- Starting template for consumers: `templates/app-screen/` (tweakable surface + theme).

Deliberately not mocked (out of v1 scope or no design yet): Groups drill-down, commit list, merge options gear, snoozing gestures (quick-action button + toast stands in for swipe), blame view.
