import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/core/theme/token_set.dart';
import 'package:gitsune/core/theme/tokens.dart';

/// Re-branding proof: the theme derives entirely from the token set in
/// `tokens.dart`, so swapping that one file (it only defines `gsTokens`)
/// re-brands the app with no other code change. Here the swap is simulated
/// by building the theme from an alternate token set.
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
      neutral: gsTokens.neutral,
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
