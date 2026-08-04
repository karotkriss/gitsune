import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/gs_icons.dart';
import '../../core/lock/app_lock.dart';
import '../../core/theme/app_theme.dart';

/// Profile tab. Placeholder until E13.2 builds account management; opens the
/// E2.7 sign-in screen and hosts the E13.1 biometric app lock toggle.
/// [onQuietHoursTap] surfaces the E12.2 quiet-hours settings once the
/// composition root wires a store; null hides the entry.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.appLockController,
    this.onQuietHoursTap,
  });

  final AppLockController? appLockController;
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
              if (appLockController != null) ...[
                const SizedBox(height: 24),
                _AppLockTile(controller: appLockController!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The E13.1 settings toggle. Enabling runs one authentication first (see
/// [AppLockController.setEnabled]); when that fails the switch stays off and
/// a snackbar explains the degradation path instead of arming a dead lock.
class _AppLockTile extends StatelessWidget {
  const _AppLockTile({required this.controller});

  final AppLockController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Biometric app lock'),
        subtitle: const Text(
          'Require a biometric or device credential check to open Gitsune',
        ),
        value: controller.enabled,
        onChanged: (value) async {
          final changed = await controller.setEnabled(value);
          if (value && !changed && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not verify. Set up a device screen lock or '
                  'biometrics and try again.',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
