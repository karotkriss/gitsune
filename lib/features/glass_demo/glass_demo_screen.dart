import 'package:flutter/material.dart';

import '../../core/glass/glass_surface.dart';

/// Which glass surfaces the demo shows, so the perf benchmark can isolate
/// each intensity against a no-glass baseline.
enum GlassDemoMode { none, modest, heavy, both }

/// Spike demo: both glass intensities floating over a busy scrolling list,
/// the jank-prone case. Modest glass as a bottom capsule bar (tab-bar
/// stand-in), heavy glass as a large overlay panel (modal/sheet stand-in).
/// Not wired into app navigation; driven by `integration_test/`.
class GlassDemoScreen extends StatelessWidget {
  const GlassDemoScreen({
    super.key,
    this.mode = GlassDemoMode.both,
    this.controller,
  });

  final GlassDemoMode mode;

  /// Lets the perf test drive identical programmatic scrolls in every mode.
  final ScrollController? controller;

  static const _tileColors = [
    Color(0xFF8C3B00),
    Color(0xFF2B4D9B),
    Color(0xFF1F6E4A),
    Color(0xFF7A2E5A),
    Color(0xFF5A4A1F),
  ];

  @override
  Widget build(BuildContext context) {
    final showModest =
        mode == GlassDemoMode.modest || mode == GlassDemoMode.both;
    final showHeavy = mode == GlassDemoMode.heavy || mode == GlassDemoMode.both;

    return Scaffold(
      body: Stack(
        children: [
          // Busy opaque content so the blur has real work to do.
          ListView.builder(
            controller: controller,
            itemCount: 400,
            itemBuilder: (context, index) {
              final color = _tileColors[index % _tileColors.length];
              return Container(
                height: 72,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.white, 0.35)!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.commit),
                  title: Text('Row $index'),
                  subtitle: Text('gitsune/demo#$index'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
          if (showHeavy)
            Align(
              alignment: Alignment.center,
              child: GlassSurface(
                intensity: GlassIntensity.heavy,
                borderRadius: BorderRadius.circular(24),
                child: const SizedBox(
                  width: 320,
                  height: 360,
                  child: Center(child: Text('Heavy glass overlay')),
                ),
              ),
            ),
          if (showModest)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GlassSurface(
                  intensity: GlassIntensity.modest,
                  borderRadius: BorderRadius.circular(32),
                  child: const SizedBox(
                    width: 280,
                    height: 64,
                    child: Center(child: Text('Modest glass capsule')),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
