import 'dart:ui';

/// The shape of a Gitsune token set: six color ramps plus the two font
/// families.
///
/// The values live in `tokens.dart`; everything else in the theme layer
/// derives from a [GsTokenSet], so a different token set re-brands the app.
class GsTokenSet {
  const GsTokenSet({
    required this.brand,
    required this.blue,
    required this.green,
    required this.orange,
    required this.red,
    required this.purple,
    required this.neutral,
    required this.fontUi,
    required this.fontMono,
  });

  /// The interactive and brand accent ramp (ADR 0007: tanuki orange).
  final GsColorRamp brand;

  /// Pajamas status ramps: blue=info/progress, green=success, orange=warning,
  /// red=danger/destructive, purple=data-viz/illustrations only.
  final GsColorRamp blue;
  final GsColorRamp green;
  final GsColorRamp orange;
  final GsColorRamp red;
  final GsColorRamp purple;
  final GsNeutralRamp neutral;

  /// UI font family (headings and body).
  final String fontUi;

  /// Mono font family for every git reference: branch names, commit IDs,
  /// pipeline IDs, code.
  final String fontMono;
}

/// An eleven-step Pajamas color ramp (50 lightest to 950 darkest).
class GsColorRamp {
  const GsColorRamp({
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
    required this.shade950,
  });

  final Color shade50;
  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;
  final Color shade950;
}

/// The neutral ramp, which adds white (0), near-white (10), and
/// near-black (1000) ends to the standard eleven steps.
class GsNeutralRamp {
  const GsNeutralRamp({
    required this.shade0,
    required this.shade10,
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
    required this.shade950,
    required this.shade1000,
  });

  final Color shade0;
  final Color shade10;
  final Color shade50;
  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;
  final Color shade950;
  final Color shade1000;
}
