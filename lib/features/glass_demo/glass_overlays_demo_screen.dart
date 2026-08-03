import 'package:flutter/material.dart';

import '../../core/glass/glass_overlays.dart';
import '../../core/theme/app_theme.dart';

/// E1.5 demo: the three heavy-glass overlay primitives (modal, drawer,
/// bottom sheet) over a busy scrolling list, the jank-prone case from the
/// glass spike. Not wired into app navigation; exercised by widget and
/// golden tests.
class GlassOverlaysDemoScreen extends StatelessWidget {
  const GlassOverlaysDemoScreen({super.key});

  static const _tileColors = [
    Color(0xFF8C3B00),
    Color(0xFF2B4D9B),
    Color(0xFF1F6E4A),
    Color(0xFF7A2E5A),
    Color(0xFF5A4A1F),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GlassDrawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            for (var i = 0; i < 8; i++)
              ListTile(
                leading: const Icon(Icons.folder),
                title: Text('Item $i'),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Busy opaque content so the blur has real work to do.
          ListView.builder(
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
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Builder(
                builder: (context) => Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const GlassModal(child: _ModalBody()),
                      ),
                      child: const Text('Modal'),
                    ),
                    FilledButton(
                      onPressed: Scaffold.of(context).openDrawer,
                      child: const Text('Drawer'),
                    ),
                    FilledButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (_) =>
                            const GlassBottomSheet(child: _SheetBody()),
                      ),
                      child: const Text('Sheet'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalBody extends StatelessWidget {
  const _ModalBody();

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heavy glass modal',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
          ),
          const SizedBox(height: 12),
          const Text('Frosted over the scrim, dismissed by scrim tap or back.'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody();

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heavy glass sheet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++)
            ListTile(leading: const Icon(Icons.bolt), title: Text('Action $i')),
        ],
      ),
    );
  }
}
