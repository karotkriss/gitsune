import 'dart:async';

import 'package:flutter/widgets.dart';

/// Binds a live-update subscription to the app's foreground lifetime: active
/// while the app is visible, cancelled on hide, resubscribed on show.
///
/// The owning screen creates one when it has something to watch and calls
/// [dispose] when it closes, so teardown is deterministic on both E12.3
/// paths (app backgrounds, screen closes) and no socket outlives the screen.
///
/// Errors go to [onError] when given and are otherwise dropped: live updates
/// are a foreground enhancement layered over polling (ADR 0002), so a failed
/// socket must never take the screen down.
// ponytail: no auto-reconnect on socket failure; the next show or screen
// visit resubscribes. Add backoff reconnect if drops prove common.
class ForegroundSubscription<T> {
  ForegroundSubscription({
    required this._subscribe,
    required this._onEvent,
    this._onError,
  }) {
    _lifecycle = AppLifecycleListener(onShow: _start, onHide: _stop);
    // A null lifecycle state means the embedder has not reported one yet,
    // which only happens while the app is in the foreground starting up.
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null ||
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      _start();
    }
  }

  final Stream<T> Function() _subscribe;
  final void Function(T event) _onEvent;
  final void Function(Object error, StackTrace stackTrace)? _onError;
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<T>? _subscription;
  bool _disposed = false;

  void _start() {
    if (_disposed || _subscription != null) return;
    _subscription = _subscribe().listen(
      _onEvent,
      onError: _onError ?? (Object error, StackTrace stackTrace) {},
    );
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    _disposed = true;
    _lifecycle.dispose();
    _stop();
  }
}
