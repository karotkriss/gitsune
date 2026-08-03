import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// Profile tab. Placeholder until E13 builds account management; opens the
/// E2.7 sign-in screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: gs.screenTitle),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/signin'),
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
