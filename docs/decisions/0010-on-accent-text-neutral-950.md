# 10. Text on the accent color: neutral-950 supersedes neutral-0

- Status: accepted
- Date: 2026-08-08
- Amends: `docs/decisions/0007-interactive-color-orange-over-blue.md` (the on-accent content pairing only)

## Context

ADR 0007 made brand orange (`--gs-color-brand-500`, `#fc6d26`) the interactive color for every button, link, active state, and focus ring.
The design system paired it with `--gs-action-text-on: neutral-0` (white), inherited unchanged into the dark theme block.
The E16.1 accessibility pass measured that pairing: white on brand-500 is a 2.9:1 contrast ratio, failing WCAG AA for text (4.5:1) and even the 3:1 large-text/graphical bar.
Flutter's own `textContrastGuideline` matcher flags every filled-button label rendered with it, so the failure is enforced by test, not just observed.

Two compliant directions exist inside the existing ramps.
Darkening the filled-button fill to brand-700 keeps white text (4.6:1) but dims the brand accent on exactly the surfaces ADR 0007 wanted it loudest.
Keeping the brand-500 fill and flipping the text to neutral-950 yields 7.1:1, the same dark-on-saturated-orange pairing platform conventions use for this hue, and leaves the accent itself untouched.

## Decision

Content rendered on the accent fill uses `neutral-950`, not `neutral-0`: the dark theme's `--gs-action-text-on` is now `neutral-950`, and the app's `GsTheme.onAccent` plus `ColorScheme.onPrimary` follow it.
The accent fill itself stays brand-500 exactly as ADR 0007 set it.
This applies to any saturated action fill a control colors itself with (for example the danger-filled destructive button, where neutral-950 on red-300 is 7.0:1 and white is 2.6:1).
The light theme block is out of scope: v1 is dark-only (ADR 0008), and a future light theme must re-derive its own compliant pairing rather than inherit this one.

## Consequences

Filled buttons render dark text on the tanuki orange; goldens covering them move accordingly.
Glyphs sitting on non-accent ramp fills (the home shortcut tiles) are not "on accent" and keep their white treatment via an explicit text token rather than `onAccent`.
`test/accessibility/a11y_guidelines_test.dart` holds the contrast floor for the key screens, so a future regression of this pairing fails CI rather than shipping.
