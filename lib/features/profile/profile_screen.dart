import 'package:flutter/material.dart';

import '../../core/auth/gitlab_oauth.dart';
import '../../core/theme/app_theme.dart';

/// Profile tab. Placeholder until E13 builds account management; carries a
/// bare gitlab.com sign-in trigger until E2.7 builds the real sign-in screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.signIn});

  /// Starts sign-in; defaults to gitlab.com OAuth in the system browser.
  /// Injectable so widget tests never reach a real browser.
  final Future<void> Function()? signIn;

  Future<void> _handleSignIn(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await (signIn ?? () => GitLabOAuth.gitlabCom().signIn())();
      messenger.showSnackBar(
        const SnackBar(content: Text('Signed in to GitLab.com')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
    }
  }

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
                onPressed: () => _handleSignIn(context),
                child: const Text('Sign in to GitLab.com'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
