import 'dart:ui';

import 'token_set.dart';

/// Gitsune's design tokens, translated verbatim from
/// `design/tokens/colors.css` (Pajamas ramps from `@gitlab/ui`, brand ramp
/// built around the tanuki oranges) and `design/tokens/typography.css`.
///
/// Re-branding: this file is pure data and is the only place raw brand
/// values live. Replacing it with another file that defines a `gsTokens`
/// [GsTokenSet] re-brands the whole app; no other code changes.
/// `test/theme/rebrand_test.dart` proves the derivation.
const GsTokenSet gsTokens = GsTokenSet(
  fontUi: 'GitLab Sans',
  fontMono: 'GitLab Mono',
  // Tanuki-orange brand ramp (ADR 0007), built around #fca326/#fc6d26/#e24329.
  brand: GsColorRamp(
    shade50: Color(0xFFFEF0E8),
    shade100: Color(0xFFFDD8C0),
    shade200: Color(0xFFFCB891),
    shade300: Color(0xFFFD9455),
    shade400: Color(0xFFFC7D38),
    shade500: Color(0xFFFC6D26),
    shade600: Color(0xFFE35D1D),
    shade700: Color(0xFFC74E17),
    shade800: Color(0xFF9C3D14),
    shade900: Color(0xFF6B2B10),
    shade950: Color(0xFF451D0C),
  ),
  blue: GsColorRamp(
    shade50: Color(0xFFE9F3FC),
    shade100: Color(0xFFCBE2F9),
    shade200: Color(0xFF9DC7F1),
    shade300: Color(0xFF63A6E9),
    shade400: Color(0xFF428FDC),
    shade500: Color(0xFF1F75CB),
    shade600: Color(0xFF2F68B4),
    shade700: Color(0xFF2F5CA0),
    shade800: Color(0xFF284779),
    shade900: Color(0xFF213454),
    shade950: Color(0xFF1D283E),
  ),
  green: GsColorRamp(
    shade50: Color(0xFFECF4EE),
    shade100: Color(0xFFC3E6CD),
    shade200: Color(0xFF91D4A8),
    shade300: Color(0xFF52B87A),
    shade400: Color(0xFF2DA160),
    shade500: Color(0xFF108548),
    shade600: Color(0xFF2F7549),
    shade700: Color(0xFF306440),
    shade800: Color(0xFF225131),
    shade900: Color(0xFF1E3E28),
    shade950: Color(0xFF17291C),
  ),
  orange: GsColorRamp(
    shade50: Color(0xFFFDF1DD),
    shade100: Color(0xFFF5D9A8),
    shade200: Color(0xFFE9BE74),
    shade300: Color(0xFFD99530),
    shade400: Color(0xFFC17D10),
    shade500: Color(0xFFAB6100),
    shade600: Color(0xFF995715),
    shade700: Color(0xFF894B16),
    shade800: Color(0xFF693C14),
    shade900: Color(0xFF532E16),
    shade950: Color(0xFF382315),
  ),
  red: GsColorRamp(
    shade50: Color(0xFFFCF1EF),
    shade100: Color(0xFFFDD4CD),
    shade200: Color(0xFFFCB5AA),
    shade300: Color(0xFFF6806D),
    shade400: Color(0xFFEC5941),
    shade500: Color(0xFFDD2B0E),
    shade600: Color(0xFFC02F12),
    shade700: Color(0xFFA32C12),
    shade800: Color(0xFF812713),
    shade900: Color(0xFF582014),
    shade950: Color(0xFF3E1A14),
  ),
  purple: GsColorRamp(
    shade50: Color(0xFFF4F0FF),
    shade100: Color(0xFFE1D8F9),
    shade200: Color(0xFFCBBBF2),
    shade300: Color(0xFFAC93E6),
    shade400: Color(0xFF9475DB),
    shade500: Color(0xFF7B58CF),
    shade600: Color(0xFF6A4FB4),
    shade700: Color(0xFF5C47A6),
    shade800: Color(0xFF493C83),
    shade900: Color(0xFF342D59),
    shade950: Color(0xFF27243E),
  ),
  neutral: GsNeutralRamp(
    shade0: Color(0xFFFFFFFF),
    shade10: Color(0xFFFBFAFD),
    shade50: Color(0xFFECECEF),
    shade100: Color(0xFFDCDCDE),
    shade200: Color(0xFFBFBFC3),
    shade300: Color(0xFFA4A3A8),
    shade400: Color(0xFF89888D),
    shade500: Color(0xFF737278),
    shade600: Color(0xFF626168),
    shade700: Color(0xFF4C4B51),
    shade800: Color(0xFF3A383F),
    shade900: Color(0xFF28272D),
    shade950: Color(0xFF18171D),
    shade1000: Color(0xFF050506),
  ),
);
