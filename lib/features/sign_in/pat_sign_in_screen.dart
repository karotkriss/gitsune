import 'package:flutter/material.dart';

import '../../core/auth/gitlab_instance.dart';
import '../../core/auth/pat_auth.dart';
import '../../core/auth/token_store.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/theme/app_theme.dart';

/// Personal Access Token sign-in (E2.4), reachable only from the sign-in
/// screen's secondary "Having trouble signing in?" affordance, never as a
/// credential field on the primary screen (`docs/research/auth-blueprint.md`).
///
/// A failed validation stays here with an inline error so the user re-enters
/// the token; it is never a dead end.
class PatSignInScreen extends StatefulWidget {
  const PatSignInScreen({super.key, this.initialInstance = '', this.signIn});

  /// Pre-fills the instance field with what the user already typed on the
  /// primary sign-in screen.
  final String initialInstance;

  /// Validates and stores the token for the instance (E2.4). Injectable so
  /// tests never touch the network; defaults to [signInWithPat] with the
  /// platform secure token store.
  final Future<void> Function(Uri base, String token)? signIn;

  @override
  State<PatSignInScreen> createState() => _PatSignInScreenState();
}

class _PatSignInScreenState extends State<PatSignInScreen> {
  late final _instanceController = TextEditingController(
    text: widget.initialInstance,
  );
  final _tokenController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _instanceController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy) return;
    final base = parseInstanceUrl(_instanceController.text);
    if (base == null) {
      setState(() => _error = 'Enter a valid instance URL, like gitlab.com.');
      return;
    }
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Paste your personal access token.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await (widget.signIn ??
          (base, token) => signInWithPat(
            baseUrl: base,
            token: token,
            tokenStore: SecureTokenStore(),
          ))(base, token);
      if (mounted) Navigator.of(context).pop();
      return;
    } catch (_) {
      // A rejected token routes back to re-entering it, never a dead end.
      if (mounted) {
        setState(() {
          _busy = false;
          _error =
              '${base.host} did not accept that token. '
              'Check it and enter it again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final labelStyle = theme.textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w600,
      fontVariations: const [FontVariation('wght', 600)],
      color: gs.textHeading,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with a token')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Text(
                  'If your instance does not allow OAuth applications, '
                  'create a personal access token with the "api" scope '
                  'and paste it here.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: gs.textSubtle,
                  ),
                ),
              ),
              Text('GitLab instance', style: labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _instanceController,
                enabled: !_busy,
                style: gs.mono.copyWith(fontSize: 15),
                keyboardType: TextInputType.url,
                autocorrect: false,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GsIcon(
                      GsIconGlyph.earth,
                      size: 18,
                      color: gs.textSubtle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Personal access token', style: labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _tokenController,
                enabled: !_busy,
                style: gs.mono.copyWith(fontSize: 15),
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.go,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: _busy ? null : (_) => _signIn(),
                decoration: InputDecoration(
                  helperText: 'Checked against your instance, then stored '
                      'only in your device\'s secure storage.',
                  helperMaxLines: 2,
                  errorText: _error,
                  errorMaxLines: 3,
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
            ],
          ),
        ),
      ),
    );
  }
}
