import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/glass_demo/glass_demo_screen.dart';
import 'package:integration_test/integration_test.dart';

/// Frame-time benchmark for the glass spike (E1.2).
///
/// Run in profile mode against a device or emulator:
///   flutter drive --profile \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/glass_perf_test.dart
///
/// Writes one timeline summary per demo mode to `build/`.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  // One mode per run (--dart-define=GLASS_MODE=none|modest|heavy|both) keeps
  // the reported timeline payload small; no define runs all four.
  const modeName = String.fromEnvironment('GLASS_MODE');
  final modes = modeName.isEmpty
      ? GlassDemoMode.values
      : [GlassDemoMode.values.byName(modeName)];

  testWidgets('scroll under each glass mode', (tester) async {
    for (final mode in modes) {
      // Controller-driven scrolling so every mode does identical work; a
      // fling gesture would land on the glass overlay, not the list.
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: GlassDemoScreen(mode: mode, controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await binding.traceAction(() async {
        final down = controller.animateTo(
          6000,
          duration: const Duration(seconds: 3),
          curve: Curves.linear,
        );
        await tester.pumpAndSettle();
        await down;
        final up = controller.animateTo(
          0,
          duration: const Duration(seconds: 3),
          curve: Curves.linear,
        );
        await tester.pumpAndSettle();
        await up;
      }, reportKey: 'glass_${mode.name}');
      controller.dispose();
    }
  });
}
