import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Explore/Search tab. Placeholder until E10 builds search and explore.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text('Explore', style: gs.screenTitle),
          ),
        ),
      ),
    );
  }
}
