import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/auth/gitlab_oauth.dart';
import '../../core/auth/oauth_config.dart';
import '../../core/auth/self_hosted_setup.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/theme/app_theme.dart';
import 'pat_sign_in_screen.dart';

/// The guided self-hosted OAuth registration wizard (E2.3), following the
/// wizard section of `docs/research/auth-blueprint.md`.
///
/// Walks the user through registering a *public* (PKCE, non-confidential)
/// OAuth application on their own instance, showing every value they must
/// enter, and accepts only the resulting Application ID back - never the
/// secret. Each named registration failure surfaces specific guidance, and
/// the one structurally impossible case (registration disabled by policy)
/// routes to the Personal Access Token fallback (E2.4).
class SelfHostedWizardScreen extends StatefulWidget {
  const SelfHostedWizardScreen({
    super.key,
    required this.base,
    this.signIn,
    this.signInWithToken,
  });

  /// The confirmed-reachable instance base URL, as parsed by the sign-in
  /// screen.
  final Uri base;

  /// Runs the E2.2 self-hosted OAuth sign-in with the validated Application
  /// ID. Injectable so tests never reach a browser or the network; defaults
  /// to [GitLabOAuth.selfHosted]. Storage is account-scoped by that flow.
  final Future<void> Function(Uri base, String applicationId)? signIn;

  /// Personal Access Token sign-in (E2.4), forwarded to [PatSignInScreen]
  /// on the impossible-to-register path. Injectable so tests never touch
  /// the network; null keeps that screen's default.
  final Future<void> Function(Uri base, String token)? signInWithToken;

  @override
  State<SelfHostedWizardScreen> createState() => _SelfHostedWizardScreenState();
}

class _SelfHostedWizardScreenState extends State<SelfHostedWizardScreen> {
  final _idController = TextEditingController();
  String? _error;
  bool _busy = false;

  String get _host => widget.base.host;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy) return;
    final String id;
    try {
      id = normalizeApplicationId(_idController.text);
    } on ApplicationIdException catch (error) {
      setState(
        () => _error = switch (error.rejection) {
          ApplicationIdRejection.empty =>
            'Paste the Application ID from the application you just created.',
          ApplicationIdRejection.secretPasted =>
            'That looks like the application secret. Gitsune never needs '
                'the secret - paste the Application ID instead.',
          ApplicationIdRejection.malformed =>
            'That does not look like an Application ID. '
                'Paste only the Application ID value.',
        },
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await (widget.signIn ??
          (base, id) => GitLabOAuth.selfHosted(
            baseUrl: base,
            applicationId: id,
          ).signIn())(widget.base, id);
      if (mounted) Navigator.of(context).pop();
      return;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (classifySelfHostedOAuthFailure(error)) {
          SelfHostedOAuthFailure.pkceUnsupported =>
            '$_host runs a GitLab version too old for secure app sign-in '
                '(PKCE), so OAuth cannot work there. Sign in with a personal '
                'access token below instead.',
          SelfHostedOAuthFailure.scopeMismatch =>
            '$_host rejected the requested scopes. Edit the application, '
                'select the "api" and "read_user" scopes, and try again.',
          SelfHostedOAuthFailure.redirectMismatch =>
            '$_host rejected the redirect URI. Edit the application, set '
                'Redirect URI to exactly $oauthRedirectUri, and try again.',
          SelfHostedOAuthFailure.confidentialClient =>
            '$_host expected a client secret, which Gitsune never sends. '
                'Edit the application, uncheck "Confidential", and check the '
                'Application ID was copied exactly, then try again.',
          SelfHostedOAuthFailure.unknown =>
            'Sign-in was not completed. Try again.',
        };
      });
    }
  }

  void _openPatFallback() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PatSignInScreen(
        initialInstance: widget.base.toString(),
        signIn: widget.signInWithToken,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final stepStyle = theme.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w600,
      fontVariations: const [FontVariation('wght', 600)],
      color: gs.textHeading,
    );
    final bodyStyle = theme.textTheme.bodyMedium!.copyWith(
      color: gs.textSubtle,
    );
    return Scaffold(
      appBar: AppBar(title: Text('Connect $_host')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Text(
                  'Gitsune signs in to $_host through an OAuth application '
                  'registered on your instance. Creating one takes a minute '
                  'and needs no administrator rights.',
                  style: bodyStyle,
                ),
              ),
              Text('1. Open the applications page', style: stepStyle),
              const SizedBox(height: 6),
              Text(
                'On $_host, go to your profile\'s Applications settings:',
                style: bodyStyle,
              ),
              const SizedBox(height: 8),
              _CopyableValue(
                widget.base
                    .replace(path: '/-/user_settings/applications')
                    .toString(),
              ),
              const SizedBox(height: 24),
              Text('2. Create the application', style: stepStyle),
              const SizedBox(height: 6),
              Text(
                'Use "Gitsune" (or any name you will recognize) as the '
                'name, and set the Redirect URI to exactly this value - '
                'extra whitespace breaks it:',
                style: bodyStyle,
              ),
              const SizedBox(height: 8),
              const _CopyableValue(oauthRedirectUri),
              const SizedBox(height: 8),
              Text(
                'Uncheck "Confidential": Gitsune is a public app (PKCE) and '
                'never uses a client secret. Select the "api" and '
                '"read_user" scopes, and leave "Expire access tokens" '
                'checked.',
                style: bodyStyle,
              ),
              const SizedBox(height: 24),
              Text('3. Paste the Application ID', style: stepStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                enabled: !_busy,
                style: gs.mono.copyWith(fontSize: 15),
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.go,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: _busy ? null : (_) => _signIn(),
                decoration: InputDecoration(
                  hintText: 'Application ID',
                  helperText:
                      'Only the Application ID - Gitsune never asks for '
                      'the secret.',
                  helperMaxLines: 2,
                  errorText: _error,
                  errorMaxLines: 4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _signIn,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
              const SizedBox(height: 24),
              Text(
                'Cannot create an application? If the Applications page is '
                'missing, your administrator has disabled OAuth application '
                'registration, so it is not possible on this instance.',
                style: bodyStyle,
              ),
              TextButton(
                onPressed: _busy ? null : _openPatFallback,
                child: const Text('Sign in with a personal access token'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A read-only value the user must transcribe exactly, with a copy button.
class _CopyableValue extends StatelessWidget {
  const _CopyableValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: gs.mono.copyWith(fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Copied')));
            },
            icon: GsIcon(
              GsIconGlyph.copyToClipboard,
              size: 16,
              color: gs.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
