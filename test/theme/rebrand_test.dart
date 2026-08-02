import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/core/theme/token_set.dart';
import 'package:gitsune/core/theme/tokens.dart';

/// Re-branding proof: swapping `tokens.dart` re-brands the app's colors and
/// font family names with no other code change. A rebrand fork also registers
/// its own font assets in `pubspec.yaml`; that is an asset addition, not a code
/// change. Here the token-file swap is simulated with an alternate token set.
void main() {
  test('default theme derives from the token file', () {
    final theme = buildAppTheme();
    final gs = theme.extension<GsTheme>()!;

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, gsTokens.brand.shade500);
    expect(gs.accent, gsTokens.brand.shade500);
    expect(gs.link, gsTokens.brand.shade300);
    expect(gs.surfaceApp, gsTokens.neutral.shade950);
    expect(theme.scaffoldBackgroundColor, gsTokens.neutral.shade950);
    expect(theme.textTheme.bodyMedium!.fontFamily, gsTokens.fontUi);
    expect(gs.mono.fontFamily, gsTokens.fontMono);
    expect(gs.screenTitle.fontFamily, gsTokens.fontUi);
  });

  test('an alternate token set re-brands accent, ramps, and fonts', () {
    // A hypothetical purple-brand fork with its own fonts; only the token
    // set changes, never the theme code.
    final fork = GsTokenSet(
      fontUi: 'Fork Sans',
      fontMono: 'Fork Mono',
      brand: gsTokens.purple,
      blue: gsTokens.blue,
      green: gsTokens.green,
      orange: gsTokens.orange,
      red: gsTokens.red,
      purple: gsTokens.brand,
      neutral: GsNeutralRamp(
        shade0: gsTokens.neutral.shade10,
        shade10: gsTokens.neutral.shade0,
        shade50: gsTokens.neutral.shade100,
        shade100: gsTokens.neutral.shade50,
        shade200: gsTokens.neutral.shade300,
        shade300: gsTokens.neutral.shade200,
        shade400: gsTokens.neutral.shade500,
        shade500: gsTokens.neutral.shade400,
        shade600: gsTokens.neutral.shade700,
        shade700: gsTokens.neutral.shade600,
        shade800: gsTokens.neutral.shade900,
        shade900: gsTokens.neutral.shade800,
        shade950: gsTokens.neutral.shade1000,
        shade1000: gsTokens.neutral.shade950,
      ),
    );

    final theme = buildAppTheme(fork);
    final gs = theme.extension<GsTheme>()!;

    expect(theme.colorScheme.primary, fork.brand.shade500);
    expect(gs.accent, fork.brand.shade500);
    expect(gs.accentHover, fork.brand.shade400);
    expect(gs.accentActive, fork.brand.shade300);
    expect(gs.accentSelectedText, fork.brand.shade200);
    expect(gs.link, fork.brand.shade300);
    expect(gs.linkHover, fork.brand.shade200);
    expect(gs.statusBrand, fork.brand.shade500);
    expect(theme.textTheme.bodyMedium!.fontFamily, 'Fork Sans');
    expect(gs.mono.fontFamily, 'Fork Mono');

    final scheme = theme.colorScheme;
    expect(scheme.primaryContainer, fork.brand.shade900);
    expect(scheme.onPrimaryContainer, fork.brand.shade200);
    expect(scheme.primaryFixed, fork.brand.shade100);
    expect(scheme.primaryFixedDim, fork.brand.shade300);
    expect(scheme.onPrimaryFixed, fork.brand.shade950);
    expect(scheme.onPrimaryFixedVariant, fork.brand.shade800);
    expect(scheme.secondary, fork.brand.shade300);
    expect(scheme.onSecondary, fork.neutral.shade950);
    expect(scheme.secondaryContainer, fork.brand.shade800);
    expect(scheme.onSecondaryContainer, fork.brand.shade100);
    expect(scheme.secondaryFixed, fork.brand.shade100);
    expect(scheme.secondaryFixedDim, fork.brand.shade300);
    expect(scheme.onSecondaryFixed, fork.brand.shade950);
    expect(scheme.onSecondaryFixedVariant, fork.brand.shade800);
    expect(scheme.tertiary, fork.brand.shade300);
    expect(scheme.onTertiary, fork.neutral.shade950);
    expect(scheme.tertiaryContainer, fork.brand.shade800);
    expect(scheme.onTertiaryContainer, fork.brand.shade100);
    expect(scheme.tertiaryFixed, fork.brand.shade100);
    expect(scheme.tertiaryFixedDim, fork.brand.shade300);
    expect(scheme.onTertiaryFixed, fork.brand.shade950);
    expect(scheme.onTertiaryFixedVariant, fork.brand.shade800);
    expect(scheme.error, fork.red.shade300);
    expect(scheme.onError, fork.neutral.shade950);
    expect(scheme.errorContainer, fork.red.shade900);
    expect(scheme.onErrorContainer, fork.red.shade200);
    expect(scheme.surface, gs.surfaceApp);
    expect(scheme.onSurface, gs.textDefault);
    expect(scheme.surfaceDim, fork.neutral.shade1000);
    expect(scheme.surfaceBright, gs.surfaceStrong);
    expect(scheme.surfaceContainerLowest, fork.neutral.shade1000);
    expect(scheme.surfaceContainerLow, gs.surfaceApp);
    expect(scheme.surfaceContainer, gs.surfaceSubtle);
    expect(scheme.surfaceContainerHigh, gs.surfaceStrong);
    expect(scheme.surfaceContainerHighest, fork.neutral.shade700);
    expect(scheme.onSurfaceVariant, gs.textSubtle);
    expect(scheme.outline, gs.borderDefault);
    expect(scheme.outlineVariant, gs.borderSubtle);
    expect(scheme.shadow, fork.neutral.shade1000);
    expect(scheme.scrim, gs.scrim);
    expect(scheme.inverseSurface, fork.neutral.shade50);
    expect(scheme.onInverseSurface, fork.neutral.shade950);
    expect(scheme.inversePrimary, fork.brand.shade700);
    expect(scheme.surfaceTint, fork.brand.shade500);

    expect(theme.canvasColor, gs.surfaceApp);
    expect(theme.cardColor, gs.surfaceCard);
    expect(theme.disabledColor, gs.textDisabled);
    expect(theme.dividerColor, gs.borderDefault);
    expect(theme.focusColor, gs.pressOverlayStrong);
    expect(theme.highlightColor, gs.pressOverlay);
    expect(theme.hintColor, gs.textDisabled);
    expect(theme.hoverColor, gs.pressOverlay);
    expect(theme.primaryColor, fork.brand.shade500);
    expect(theme.primaryColorDark, fork.brand.shade700);
    expect(theme.primaryColorLight, fork.brand.shade300);
    expect(theme.scaffoldBackgroundColor, gs.surfaceApp);
    expect(theme.secondaryHeaderColor, gs.surfaceStrong);
    expect(theme.shadowColor, fork.neutral.shade1000);
    expect(theme.splashColor, gs.pressOverlayStrong);
    expect(theme.unselectedWidgetColor, gs.textSubtle);
    expect(theme.dialogTheme.backgroundColor, gs.surfaceSheet);
    expect(theme.iconTheme.color, gs.textDefault);
    expect(theme.primaryIconTheme.color, gs.onAccent);
    expect(theme.buttonTheme.colorScheme, scheme);
    expect(
      theme.buttonTheme.getFillColor(_PrimaryMaterialButton(onPressed: () {})),
      gs.accent,
    );
    expect(
      theme.buttonTheme.getDisabledFillColor(
        const _PrimaryMaterialButton(onPressed: null),
      ),
      gs.surfaceSubtle,
    );

    for (final textTheme in [theme.textTheme, theme.primaryTextTheme]) {
      for (final style in <TextStyle?>[
        textTheme.displayLarge,
        textTheme.displayMedium,
        textTheme.displaySmall,
        textTheme.headlineLarge,
        textTheme.headlineMedium,
        textTheme.headlineSmall,
        textTheme.titleLarge,
        textTheme.titleMedium,
        textTheme.titleSmall,
        textTheme.bodyLarge,
        textTheme.bodyMedium,
        textTheme.bodySmall,
        textTheme.labelLarge,
        textTheme.labelMedium,
        textTheme.labelSmall,
      ]) {
        expect(style!.fontFamily, fork.fontUi);
        expect(style.fontVariations, isNotEmpty);
        expect(style.fontVariations!.single.axis, 'wght');
        expect(
          style.fontVariations!.single.value,
          style.fontWeight == FontWeight.w600 ? 600 : 400,
        );
      }
    }

    // Nothing accent-colored is left on the old brand.
    for (final color in [
      theme.colorScheme.primary,
      gs.accent,
      gs.accentHover,
      gs.accentActive,
      gs.link,
      gs.linkHover,
      gs.statusBrand,
    ]) {
      expect(
        color,
        isNot(
          isIn([
            gsTokens.brand.shade200,
            gsTokens.brand.shade300,
            gsTokens.brand.shade400,
            gsTokens.brand.shade500,
          ]),
        ),
      );
    }
  });
}

class _PrimaryMaterialButton extends MaterialButton {
  const _PrimaryMaterialButton({required super.onPressed})
    : super(textTheme: ButtonTextTheme.primary);
}
