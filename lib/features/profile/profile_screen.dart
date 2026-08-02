import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Profile tab. Placeholder until E13 builds account management.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text('Profile', style: gs.screenTitle),
          ),
        ),
      ),
    );
  }
}
