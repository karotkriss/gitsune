# 9. Liquid glass direction: heavier app-wide, heaviest on overlays

- Status: accepted
- Date: 2026-08-01

## Context

The design system's "2026 look" is a liquid-glass floating chrome layer: translucent, blurred surfaces for the capsule tab bar, bottom sheets, modals, and toasts, sitting over opaque content that never itself goes translucent.
The design system as built already gives overlays (Drawer, Modal) a heavier glass treatment than the tab bar and toasts, via separate tokens (`--gs-glass-bg` for the lighter chrome, `--gs-glass-bg-strong` for overlays).
The maintainer's review confirmed and strengthened this direction: glass should lean heavier app-wide than a typical translucent chrome layer, and overlays specifically should carry the heaviest glass treatment of any surface in the app, more pronounced than the existing tab-bar/toast weight already implied.

This decision is about visual direction and weighting, not about how the effect gets built.
Liquid glass (background blur, saturation, translucency) is real-time compositing work, and its cost and even its availability vary a great deal by rendering surface: a Flutter app's backdrop-blur support differs across platforms and widget stacks, differs again between a native OS chrome element and a custom-rendered one, and carries a real performance cost that has not yet been evaluated against Gitsune's actual target devices.
The initial Flutter scaffold deliberately leaves that engineering to the liquid-glass implementation spike; this decision record is intentionally silent on it.

## Decision

Liquid glass leans heavier app-wide than a typical translucent chrome layer, and overlays, Drawer and Modal specifically, carry the heaviest glass treatment of any surface in the app: heavier than the capsule tab bar and toasts, which stay lighter so they read as chrome floating over content rather than as their own opaque layer.
Content surfaces, cards, lists, and headers, stay fully opaque; glass never stacks on glass.

## Consequences

The design system's existing token split (`--gs-glass-bg` for tab bar/toasts, `--gs-glass-bg-strong` for Drawer/Modal) already expresses this weighting and needs no token changes to match this decision.
**Open engineering question, explicitly not decided here:** the implementation mechanism for liquid glass on Gitsune's actual cross-platform target (real-time backdrop blur, a pre-rendered/approximated blur, or some other technique per platform) is left for development time.
Whatever mechanism development lands on, it is expected to preserve this document's weighting: overlays read as the heaviest glass surface in the app, and content never goes translucent.
