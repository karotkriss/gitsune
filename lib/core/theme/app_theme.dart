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
  final textTheme = _textTheme(tokens);
  final colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: tokens.brand.shade500,
    onPrimary: n.shade0,
    primaryContainer: tokens.brand.shade900,
    onPrimaryContainer: tokens.brand.shade200,
    primaryFixed: tokens.brand.shade100,
    primaryFixedDim: tokens.brand.shade300,
    onPrimaryFixed: tokens.brand.shade950,
    onPrimaryFixedVariant: tokens.brand.shade800,
    secondary: tokens.brand.shade300,
    onSecondary: n.shade950,
    secondaryContainer: tokens.brand.shade800,
    onSecondaryContainer: tokens.brand.shade100,
    secondaryFixed: tokens.brand.shade100,
    secondaryFixedDim: tokens.brand.shade300,
    onSecondaryFixed: tokens.brand.shade950,
    onSecondaryFixedVariant: tokens.brand.shade800,
    tertiary: tokens.brand.shade300,
    onTertiary: n.shade950,
    tertiaryContainer: tokens.brand.shade800,
    onTertiaryContainer: tokens.brand.shade100,
    tertiaryFixed: tokens.brand.shade100,
    tertiaryFixedDim: tokens.brand.shade300,
    onTertiaryFixed: tokens.brand.shade950,
    onTertiaryFixedVariant: tokens.brand.shade800,
    error: tokens.red.shade300,
    onError: n.shade950,
    errorContainer: tokens.red.shade900,
    onErrorContainer: tokens.red.shade200,
    surface: gs.surfaceApp,
    onSurface: gs.textDefault,
    surfaceDim: n.shade1000,
    surfaceBright: gs.surfaceStrong,
    surfaceContainerLowest: n.shade1000,
    surfaceContainerLow: gs.surfaceApp,
    surfaceContainer: gs.surfaceSubtle,
    surfaceContainerHigh: gs.surfaceStrong,
    surfaceContainerHighest: n.shade700,
    onSurfaceVariant: gs.textSubtle,
    outline: gs.borderDefault,
    outlineVariant: gs.borderSubtle,
    shadow: n.shade1000,
    scrim: gs.scrim,
    inverseSurface: n.shade50,
    onInverseSurface: n.shade950,
    inversePrimary: tokens.brand.shade700,
    surfaceTint: tokens.brand.shade500,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    applyElevationOverlayColor: false,
    colorScheme: colorScheme,
    canvasColor: gs.surfaceApp,
    cardColor: gs.surfaceCard,
    disabledColor: gs.textDisabled,
    scaffoldBackgroundColor: gs.surfaceApp,
    dividerColor: gs.borderDefault,
    focusColor: gs.pressOverlayStrong,
    highlightColor: gs.pressOverlay,
    hintColor: gs.textDisabled,
    hoverColor: gs.pressOverlay,
    primaryColor: tokens.brand.shade500,
    primaryColorDark: tokens.brand.shade700,
    primaryColorLight: tokens.brand.shade300,
    secondaryHeaderColor: gs.surfaceStrong,
    shadowColor: n.shade1000,
    splashColor: gs.pressOverlayStrong,
    unselectedWidgetColor: gs.textSubtle,
    fontFamily: tokens.fontUi,
    iconTheme: IconThemeData(color: gs.textDefault),
    primaryIconTheme: IconThemeData(color: gs.onAccent),
    buttonTheme: ButtonThemeData(
      buttonColor: gs.accent,
      disabledColor: gs.surfaceSubtle,
      focusColor: gs.pressOverlayStrong,
      hoverColor: gs.pressOverlay,
      highlightColor: gs.pressOverlayStrong,
      splashColor: gs.pressOverlayStrong,
      colorScheme: colorScheme,
    ),
    dialogTheme: DialogThemeData(backgroundColor: gs.surfaceSheet),
    primaryTextTheme: textTheme,
    textTheme: textTheme,
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
  displayLarge: _heading(t.fontUi, 28),
  displayMedium: _heading(t.fontUi, 28),
  displaySmall: _heading(t.fontUi, 28),
  headlineLarge: _heading(t.fontUi, 28),
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
  labelMedium: _body(t.fontUi, 13, 20),
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
