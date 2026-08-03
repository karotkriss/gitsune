import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_surface.dart';

/// Reusable heavy-glass overlay primitives (E1.5): [GlassModal],
/// [GlassDrawer], and [GlassBottomSheet], each composing [GlassSurface] at
/// [GlassIntensity.heavy], the heaviest glass treatment in the app per
/// ADR 0009, ruled with the `--gs-glass-edge` ring and drop shadow.
///
/// All three ride Material's own modal routes, so their dismiss affordances
/// (scrim tap, system back button, the sheet's drag-to-dismiss) come from the
/// framework: show a [GlassModal] with `showDialog`, a [GlassBottomSheet]
/// with `showModalBottomSheet`, and hang a [GlassDrawer] on a `Scaffold`'s
/// `drawer` slot. The scrim (`--gs-scrim`) is wired once in `buildAppTheme`
/// (dialog barrier, drawer scrim, sheet barrier), so call sites pass no
/// colors. Because these are all modal, at most one heavy overlay - one
/// backdrop-blur region - is live at a time, which is exactly the budget
/// guidance in `docs/research/glass-spike.md`; none of them changes the
/// spike's blur sigma.

/// `--gl-modal-border-radius` / `--gl-drawer-border-radius`: 1rem.
const double _overlayRadius = 16;

/// The sheet's top corners; larger than modal/drawer so the sheet reads as
/// docked to the screen's bottom edge.
const double _sheetRadius = 28;

/// Heavy-glass modal dialog panel.
///
/// Show with `showDialog(context: ..., builder: (_) => GlassModal(child: ...))`;
/// the dialog route supplies the scrim, tap-scrim dismiss, and back-button
/// dismiss.
class GlassModal extends StatelessWidget {
  const GlassModal({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(_overlayRadius));
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: _GlassEdge(
        borderRadius: radius,
        child: GlassSurface(
          intensity: GlassIntensity.heavy,
          borderRadius: radius,
          child: child,
        ),
      ),
    );
  }
}

/// Heavy-glass side drawer for a `Scaffold`'s `drawer` slot, which supplies
/// the scrim, tap-scrim dismiss, edge drag, and back-button dismiss.
///
/// Rounds its trailing corners, so use it as the start-side drawer.
class GlassDrawer extends StatelessWidget {
  const GlassDrawer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = const BorderRadiusDirectional.horizontal(
      end: Radius.circular(_overlayRadius),
    ).resolve(Directionality.of(context));
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: _GlassEdge(
        borderRadius: radius,
        child: GlassSurface(
          intensity: GlassIntensity.heavy,
          borderRadius: radius,
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}

/// Heavy-glass bottom sheet body with the grabber that signals
/// drag-to-dismiss.
///
/// Show with `showModalBottomSheet(context: ..., builder: (_) =>
/// GlassBottomSheet(child: ...))`; the sheet route supplies the scrim and
/// the tap-scrim, drag-down, and back-button dismissals. The caller sizes
/// the sheet (e.g. a `SizedBox` around this widget).
class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    const radius = BorderRadius.vertical(top: Radius.circular(_sheetRadius));
    return _GlassEdge(
      borderRadius: radius,
      child: GlassSurface(
        intensity: GlassIntensity.heavy,
        borderRadius: radius,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: gs.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// `--gs-glass-edge` (dark): the 1px alpha ring and soft drop shadow that
/// rule the overlay's silhouette. The token's third part, the inset top
/// highlight, is already drawn by [GlassSurface]'s border.
class _GlassEdge extends StatelessWidget {
  const _GlassEdge({required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  /// `0 0 0 1px rgba(255,255,255,.1)`.
  static const _ring = BoxShadow(color: Color(0x1AFFFFFF), spreadRadius: 1);

  /// `0 12px 32px rgba(5,5,6,.5)`.
  static const _drop = BoxShadow(
    color: Color(0x80050506),
    offset: Offset(0, 12),
    blurRadius: 32,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [_drop, _ring],
      ),
      child: child,
    );
  }
}
