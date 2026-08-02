import 'package:flutter/material.dart';

import 'token_set.dart';
import 'tokens.dart';

/// Builds the app theme (dark only, ADR 0008) from a token set.
///
/// Everything here derives from [tokens]; the default is the Gitsune set in
/// `tokens.dart`, and passing (or swapping in) another set re-brands the app.
ThemeData buildAppTheme([GsTokenSet tokens = gsTokens]) {
  final gs = GsTheme(tokens);
  final n = tokens.neutral;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: tokens.brand.shade500,
      onPrimary: n.shade0,
      secondary: tokens.brand.shade300,
      onSecondary: n.shade950,
      surface: n.shade950,
      onSurface: n.shade50,
      surfaceContainer: n.shade900,
      error: tokens.red.shade300,
      onError: n.shade950,
      outline: n.shade700,
    ),
    scaffoldBackgroundColor: gs.surfaceApp,
    dividerColor: gs.borderDefault,
    fontFamily: tokens.fontUi,
    textTheme: _textTheme(tokens),
    extensions: [gs],
  );
}

/// Gitsune's semantic design tokens, exposed on [ThemeData.extensions].
///
/// Access via `Theme.of(context).extension<GsTheme>()!`. Each field is the
/// dark-theme mapping from `design/tokens/semantic.css`, derived from the raw
/// ramps in `tokens.dart`.
class GsTheme extends ThemeExtension<GsTheme> {
  GsTheme(GsTokenSet t)
    : accent = t.brand.shade500,
      accentHover = t.brand.shade400,
      accentActive = t.brand.shade300,
      onAccent = t.neutral.shade0,
      accentSelectedBg = t.brand.shade500.withValues(alpha: 0.16),
      accentSelectedText = t.brand.shade200,
      link = t.brand.shade300,
      linkHover = t.brand.shade200,
      textDefault = t.neutral.shade50,
      textSubtle = t.neutral.shade200,
      textDisabled = t.neutral.shade400,
      textHeading = t.neutral.shade0,
      textDanger = t.red.shade300,
      textSuccess = t.green.shade300,
      surfaceApp = t.neutral.shade950,
      surfaceSubtle = t.neutral.shade900,
      surfaceStrong = t.neutral.shade800,
      surfaceCard = t.neutral.shade900,
      surfaceSheet = t.neutral.shade900,
      surfaceInset = t.neutral.shade900,
      borderDefault = t.neutral.shade700,
      borderSubtle = t.neutral.shade800,
      borderStrong = t.neutral.shade600,
      statusInfo = t.blue.shade300,
      statusSuccess = t.green.shade300,
      statusWarning = t.orange.shade300,
      statusDanger = t.red.shade300,
      statusNeutral = t.neutral.shade300,
      statusBrand = t.brand.shade500,
      feedbackInfoBg = t.blue.shade950,
      feedbackSuccessBg = t.green.shade900,
      feedbackWarningBg = t.orange.shade900,
      feedbackDangerBg = t.red.shade900,
      feedbackInfoText = t.blue.shade200,
      feedbackSuccessText = t.green.shade200,
      feedbackWarningText = t.orange.shade200,
      feedbackDangerText = t.red.shade200,
      scrim = t.neutral.shade1000.withValues(alpha: 0.6),
      pressOverlay = t.neutral.shade0.withValues(alpha: 0.08),
      pressOverlayStrong = t.neutral.shade0.withValues(alpha: 0.16),
      tileIssues = t.green.shade500,
      tileMrs = t.blue.shade500,
      tileTodos = t.orange.shade500,
      tilePipelines = t.purple.shade500,
      tileProjects = t.neutral.shade600,
      tileGroups = t.blue.shade800,
      diffAddBg = t.green.shade950,
      diffAddStrong = t.green.shade900,
      diffDelBg = t.red.shade950,
      diffDelStrong = t.red.shade900,
      codeBg = t.neutral.shade900,
      codeKeyword = t.purple.shade300,
      codeString = t.green.shade300,
      codeComment = t.neutral.shade400,
      codeFunction = t.blue.shade300,
      codeNumber = t.orange.shade300,
      screenTitle = _heading(t.fontUi, 28),
      caption = _body(t.fontUi, 12, 16),
      mono = _body(t.fontMono, 13, 20);

  // Interactive accent (ADR 0007: tanuki orange). Hover/active step one and
  // two ramp steps toward the light end, the dark-theme reading of the
  // Pajamas interactive-state rule.
  final Color accent;
  final Color accentHover;
  final Color accentActive;
  final Color onAccent;
  final Color accentSelectedBg;
  final Color accentSelectedText;
  final Color link;
  final Color linkHover;

  // Text.
  final Color textDefault;
  final Color textSubtle;
  final Color textDisabled;
  final Color textHeading;
  final Color textDanger;
  final Color textSuccess;

  // Surfaces.
  final Color surfaceApp;
  final Color surfaceSubtle;
  final Color surfaceStrong;
  final Color surfaceCard;
  final Color surfaceSheet;
  final Color surfaceInset;

  // Borders.
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderStrong;

  // Status: fixed product-wide semantics (blue=info/progress, green=success,
  // orange=warning, red=danger, never the interactive color).
  final Color statusInfo;
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusDanger;
  final Color statusNeutral;
  final Color statusBrand;

  // Feedback (alert/banner) fills and text.
  final Color feedbackInfoBg;
  final Color feedbackSuccessBg;
  final Color feedbackWarningBg;
  final Color feedbackDangerBg;
  final Color feedbackInfoText;
  final Color feedbackSuccessText;
  final Color feedbackWarningText;
  final Color feedbackDangerText;

  // Overlays.
  final Color scrim;
  final Color pressOverlay;
  final Color pressOverlayStrong;

  // Home shortcut tiles (E1.4).
  final Color tileIssues;
  final Color tileMrs;
  final Color tileTodos;
  final Color tilePipelines;
  final Color tileProjects;
  final Color tileGroups;

  // Diff and code (E4).
  final Color diffAddBg;
  final Color diffAddStrong;
  final Color diffDelBg;
  final Color diffDelStrong;
  final Color codeBg;
  final Color codeKeyword;
  final Color codeString;
  final Color codeComment;
  final Color codeFunction;
  final Color codeNumber;

  // Typography beyond the Material TextTheme: the 28px screen title, the
  // 12/16 caption, and the mono style required for every git reference
  // (branch names, commit IDs, pipeline IDs, code).
  final TextStyle screenTitle;
  final TextStyle caption;
  final TextStyle mono;

  // ponytail: dark-only v1 (ADR 0008) has a single GsTheme instance, so
  // nothing ever copies or lerps it; give both real bodies when a second
  // theme exists.
  @override
  GsTheme copyWith() => this;

  @override
  GsTheme lerp(GsTheme? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// The fixed (non-fluid) Pajamas mobile type scale from
/// `design/tokens/typography.css`: 400 body, 600 headings, headings at 1.25
/// line height with -0.01em tracking.
TextTheme _textTheme(GsTokenSet t) => TextTheme(
  headlineMedium: _heading(t.fontUi, 28),
  headlineSmall: _heading(t.fontUi, 24),
  titleLarge: _heading(t.fontUi, 21),
  titleMedium: _heading(t.fontUi, 18),
  titleSmall: _heading(t.fontUi, 16),
  bodyLarge: _body(t.fontUi, 16, 24),
  bodyMedium: _body(t.fontUi, 14, 20),
  bodySmall: _body(t.fontUi, 13, 20),
  labelLarge: _body(t.fontUi, 14, 20).copyWith(
    fontWeight: FontWeight.w600,
    fontVariations: const [FontVariation('wght', 600)],
  ),
  labelSmall: _body(t.fontUi, 12, 16),
);

// GitLab Sans/Mono are variable fonts, so weight is set through the `wght`
// axis as well as fontWeight (which alone only selects the default instance).
TextStyle _body(String family, double size, double lineHeight) => TextStyle(
  fontFamily: family,
  fontSize: size,
  height: lineHeight / size,
  fontWeight: FontWeight.w400,
  fontVariations: const [FontVariation('wght', 400)],
);

TextStyle _heading(String family, double size) => TextStyle(
  fontFamily: family,
  fontSize: size,
  height: 1.25,
  fontWeight: FontWeight.w600,
  fontVariations: const [FontVariation('wght', 600)],
  letterSpacing: size * -0.01,
);
