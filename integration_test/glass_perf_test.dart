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

  testWidgets('scroll under each glass mode', (tester) async {
    for (final mode in GlassDemoMode.values) {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: GlassDemoScreen(mode: mode)),
      );
      await tester.pumpAndSettle();

      final list = find.byType(ListView);
      await binding.traceAction(() async {
        for (var i = 0; i < 5; i++) {
          await tester.fling(list, const Offset(0, -600), 2500);
          await tester.pumpAndSettle();
        }
        for (var i = 0; i < 5; i++) {
          await tester.fling(list, const Offset(0, 600), 2500);
          await tester.pumpAndSettle();
        }
      }, reportKey: 'glass_${mode.name}');
    }
  });
}
