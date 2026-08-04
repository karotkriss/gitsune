import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/gs_icons.dart';
import '../../core/theme/app_theme.dart';

/// Profile tab. Placeholder until E13 builds account management; opens the
/// E2.7 sign-in screen. [onQuietHoursTap] surfaces the E12.2 quiet-hours
/// settings once the composition root wires a store; null hides the entry.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onQuietHoursTap});

  final VoidCallback? onQuietHoursTap;

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
              if (onQuietHoursTap != null) ...[
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Quiet hours'),
                  trailing: const GsIcon(GsIconGlyph.chevronRight, size: 20),
                  onTap: onQuietHoursTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
