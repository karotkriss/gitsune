import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// The two glass weights ruled by ADR 0009: [modest] for app-wide floating
/// chrome (capsule tab bar, toasts), [heavy] for overlays (drawer, modal,
/// sheet), which carry the heaviest glass treatment in the app.
enum GlassIntensity { modest, heavy }

/// Frosted-glass surface: the app's single liquid-glass primitive.
///
/// This widget is the isolation seam for the glass effect: callers depend
/// only on `GlassSurface(intensity: ..., child: ...)` and never on how the
/// frost is produced. The current implementation is a native
/// [BackdropFilter] (Gaussian blur + saturation boost, translated from the
/// design system's `--gs-glass-*` dark tokens); a future refractive
/// implementation can replace [build] without touching any call site.
///
/// Per the brand-glass guideline, glass never sits on glass and content
/// surfaces stay opaque: place this only over flat, opaque content.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.intensity,
    this.borderRadius = BorderRadius.zero,
    required this.child,
  });

  final GlassIntensity intensity;
  final BorderRadius borderRadius;
  final Widget child;

  /// `--gs-glass-bg`: rgba(24,23,29,.55) (dark theme).
  static const Color modestBackground = Color(0x8C18171D);

  /// `--gs-glass-bg-strong`: rgba(30,29,36,.85) (dark theme).
  static const Color heavyBackground = Color(0xD91E1D24);

  /// `--gs-glass-border`: rgba(255,255,255,.12) (dark theme).
  static const Color borderColor = Color(0x1FFFFFFF);

  /// `--gs-glass-blur: blur(24px)`. A CSS blur radius of R is a Gaussian
  /// with standard deviation R/2, so 24px maps to sigma 12. This is the
  /// main performance knob: cost scales with sigma and covered area.
  static const double blurSigma = 12.0;

  /// `--gs-glass-blur: saturate(1.8)` as a color-matrix filter.
  static final ui.ColorFilter _saturate = ui.ColorFilter.matrix(
    _saturationMatrix(1.8),
  );

  static final ui.ImageFilter _frost = ui.ImageFilter.compose(
    outer: _saturate,
    inner: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: _frost,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: switch (intensity) {
              GlassIntensity.modest => modestBackground,
              GlassIntensity.heavy => heavyBackground,
            },
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

List<double> _saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final sr = (1 - s) * lr, sg = (1 - s) * lg, sb = (1 - s) * lb;
  return [
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}
