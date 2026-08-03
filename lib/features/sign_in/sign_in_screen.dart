import 'package:flutter/material.dart';

import '../../core/auth/gitlab_instance.dart';
import '../../core/auth/gitlab_oauth.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/theme/app_theme.dart';
import 'pat_sign_in_screen.dart';
import 'self_hosted_wizard_screen.dart';

/// The sign-in surface specified by `docs/research/design-direction.md` and
/// `docs/decisions/0001-auth-posture.md`.
///
/// A reachable self-hosted instance opens the E2.3 registration wizard
/// ([SelfHostedWizardScreen]) unless a test injects [signInSelfHosted].
class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    this.signIn,
    this.probeInstance,
    this.signInSelfHosted,
    this.signInWithToken,
  });

  /// Starts the gitlab.com OAuth sign-in (E2.1). Injectable so tests never
  /// reach a real browser; defaults to [GitLabOAuth.gitlabCom].
  final Future<void> Function()? signIn;

  /// Checks that a self-hosted URL answers as a GitLab instance. Injectable
  /// so tests never touch the network; defaults to [isGitLabInstance].
  final Future<bool> Function(Uri base)? probeInstance;

  /// Starts self-hosted OAuth sign-in (E2.2) for a confirmed-reachable
  /// instance [base]. Injectable so tests never navigate; null (production)
  /// opens the E2.3 registration wizard, which supplies and validates the
  /// instance's Application ID, then runs [GitLabOAuth.selfHosted].
  final Future<void> Function(Uri base)? signInSelfHosted;

  /// Personal Access Token sign-in (E2.4), forwarded to [PatSignInScreen]
  /// behind the secondary "Having trouble signing in?" affordance. Injectable
  /// so tests never touch the network; null keeps that screen's default.
  final Future<void> Function(Uri base, String token)? signInWithToken;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _instanceController = TextEditingController(text: 'gitlab.com');
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _instanceController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_busy) return;
    final base = parseInstanceUrl(_instanceController.text);
    if (base == null) {
      setState(() => _error = 'Enter a valid instance URL, like gitlab.com.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    String? error;
    try {
      if (base.host == 'gitlab.com') {
        await (widget.signIn ?? () => GitLabOAuth.gitlabCom().signIn())();
      } else {
        final reachable = await (widget.probeInstance ?? isGitLabInstance)(
          base,
        );
        if (!reachable) {
          error =
              '${base.host} does not answer as a GitLab instance. '
              'Check the address and try again.';
        } else if (widget.signInSelfHosted case final selfHosted?) {
          await selfHosted(base);
        } else if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SelfHostedWizardScreen(
                base: base,
                signInWithToken: widget.signInWithToken,
              ),
            ),
          );
        }
      }
    } catch (_) {
      error = 'Sign-in was not completed. Try again.';
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 48, bottom: 40),
                      child: Column(
                        children: [
                          Text(
                            'Gitsune',
                            style: gs.screenTitle.copyWith(
                              fontSize: 40,
                              letterSpacing: -0.4,
                              color: gs.statusBrand,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'GitLab in your pocket',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: gs.textSubtle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'GitLab instance',
                      style: theme.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontVariations: const [FontVariation('wght', 600)],
                        color: gs.textHeading,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _instanceController,
                      enabled: !_busy,
                      style: gs.mono.copyWith(fontSize: 15),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      textInputAction: TextInputAction.go,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: _busy ? null : (_) => _continue(),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: GsIcon(
                            GsIconGlyph.earth,
                            size: 18,
                            color: gs.textSubtle,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: GsIcon(
                            GsIconGlyph.pencil,
                            size: 16,
                            color: gs.textSubtle,
                          ),
                        ),
                        helperText:
                            'gitlab.com sign-in opens in your browser. '
                            'Self-hosted instances take a quick one-time '
                            'setup.',
                        helperMaxLines: 2,
                        errorText: _error,
                        errorMaxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _continue,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                    const SizedBox(height: 12),
                    // The Personal Access Token fallback (E2.4) lives only
                    // behind this secondary affordance; the primary screen
                    // stays OAuth-only with no credential fields.
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PatSignInScreen(
                                  initialInstance: _instanceController.text,
                                  signIn: widget.signInWithToken,
                                ),
                              ),
                            ),
                      child: const Text('Having trouble signing in?'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Open source · No project-operated servers, ever',
                textAlign: TextAlign.center,
                style: gs.caption.copyWith(color: gs.textSubtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
