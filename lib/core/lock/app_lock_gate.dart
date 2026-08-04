import 'package:flutter/material.dart';

import '../icons/gs_icons.dart';
import '../theme/app_theme.dart';
import 'app_lock.dart';

/// Wraps the routed UI (via `MaterialApp.router`'s `builder`) and covers it
/// with an opaque lock screen while [AppLockController.locked] holds, keeping
/// the covered subtree alive so unlocking never loses navigation state.
///
/// Re-arms the lock when the app leaves the foreground (so the app-switcher
/// snapshot shows the lock screen, not content) and prompts again on resume.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.controller, required this.child});

  final AppLockController controller;
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _wasLocked = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onControllerChanged);
    _wasLocked = widget.controller.locked;
    if (_wasLocked) _prompt();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden) {
      _foreground = false;
      widget.controller.lock();
    } else if (state == AppLifecycleState.resumed) {
      _foreground = true;
      if (widget.controller.locked) _prompt();
    }
  }

  void _onControllerChanged() {
    final locked = widget.controller.locked;
    // Prompt when the gate first closes in the foreground (cold launch);
    // while backgrounded the resume handler prompts instead, so the platform
    // dialog is never requested against a hidden app.
    if (locked && !_wasLocked && _foreground) _prompt();
    _wasLocked = locked;
    setState(() {});
  }

  void _prompt() {
    // Post-frame so the lock screen is on screen behind the platform dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.locked) widget.controller.unlock();
    });
  }

  @override
  Widget build(BuildContext context) {
    final covered = !widget.controller.loaded || widget.controller.locked;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: covered,
          child: IgnorePointer(ignoring: covered, child: widget.child),
        ),
        if (!widget.controller.loaded)
          const _LoadingScreen()
        else if (widget.controller.locked)
          _LockScreen(onUnlock: widget.controller.unlock),
      ],
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// The opaque cover shown while the app is locked; the button retries the
/// platform check after a failed or dismissed attempt.
class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GsIcon(GsIconGlyph.lock, size: 48, color: gs.textSubtle),
              const SizedBox(height: 16),
              Text('Gitsune is locked', style: gs.screenTitle),
              const SizedBox(height: 24),
              FilledButton(onPressed: onUnlock, child: const Text('Unlock')),
            ],
          ),
        ),
      ),
    );
  }
}
