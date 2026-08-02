import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/core/theme/tokens.dart';

/// Token-swatch golden: every raw ramp and every semantic color the theme
/// exposes, rendered as one grid. Fails on any unintended token change.
void main() {
  testWidgets('token swatches match golden', (tester) async {
    final theme = buildAppTheme();
    final gs = theme.extension<GsTheme>()!;

    final rows = <List<Color>>[
      for (final ramp in [
        gsTokens.brand,
        gsTokens.blue,
        gsTokens.green,
        gsTokens.orange,
        gsTokens.red,
        gsTokens.purple,
      ])
        [
          ramp.shade50,
          ramp.shade100,
          ramp.shade200,
          ramp.shade300,
          ramp.shade400,
          ramp.shade500,
          ramp.shade600,
          ramp.shade700,
          ramp.shade800,
          ramp.shade900,
          ramp.shade950,
        ],
      [
        gsTokens.neutral.shade0,
        gsTokens.neutral.shade10,
        gsTokens.neutral.shade50,
        gsTokens.neutral.shade100,
        gsTokens.neutral.shade200,
        gsTokens.neutral.shade300,
        gsTokens.neutral.shade400,
        gsTokens.neutral.shade500,
        gsTokens.neutral.shade600,
        gsTokens.neutral.shade700,
        gsTokens.neutral.shade800,
        gsTokens.neutral.shade900,
        gsTokens.neutral.shade950,
        gsTokens.neutral.shade1000,
      ],
      [
        gs.accent,
        gs.accentHover,
        gs.accentActive,
        gs.onAccent,
        gs.accentSelectedBg,
        gs.accentSelectedText,
        gs.link,
        gs.linkHover,
      ],
      [
        gs.textDefault,
        gs.textSubtle,
        gs.textDisabled,
        gs.textHeading,
        gs.textDanger,
        gs.textSuccess,
      ],
      [
        gs.surfaceApp,
        gs.surfaceSubtle,
        gs.surfaceStrong,
        gs.surfaceCard,
        gs.surfaceSheet,
        gs.surfaceInset,
      ],
      [gs.borderDefault, gs.borderSubtle, gs.borderStrong],
      [
        gs.statusInfo,
        gs.statusSuccess,
        gs.statusWarning,
        gs.statusDanger,
        gs.statusNeutral,
        gs.statusBrand,
      ],
      [
        gs.feedbackInfoBg,
        gs.feedbackSuccessBg,
        gs.feedbackWarningBg,
        gs.feedbackDangerBg,
        gs.feedbackInfoText,
        gs.feedbackSuccessText,
        gs.feedbackWarningText,
        gs.feedbackDangerText,
      ],
      [gs.scrim, gs.pressOverlay, gs.pressOverlayStrong],
      [
        gs.tileIssues,
        gs.tileMrs,
        gs.tileTodos,
        gs.tilePipelines,
        gs.tileProjects,
        gs.tileGroups,
      ],
      [gs.diffAddBg, gs.diffAddStrong, gs.diffDelBg, gs.diffDelStrong],
      [
        gs.codeBg,
        gs.codeKeyword,
        gs.codeString,
        gs.codeComment,
        gs.codeFunction,
        gs.codeNumber,
      ],
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final row in rows)
                Row(
                  children: [
                    for (final color in row)
                      Container(width: 24, height: 24, color: color),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/token_swatches.png'),
    );
  });
}
