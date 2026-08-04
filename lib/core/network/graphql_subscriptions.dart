import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'account_key.dart';
import 'gitlab_client.dart';

/// Resolves the ActionCable WebSocket endpoint for an account's own instance.
///
/// Fake-server tests point [GraphQlSubscriptions]'s `cableUri` directly at the
/// server instead, since the fake runs over plain `ws` rather than `wss`.
Uri resolveCableUri(AccountKey account) =>
    Uri.https(account.instanceHost, '/-/cable').replace(scheme: 'wss');

/// GitLab GraphQL subscriptions over the instance's ActionCable WebSocket
/// (`/-/cable`), bearer-token authenticated.
///
/// This is the core transport seam for foreground live updates (E12.3):
/// features call [subscribe] with a GraphQL subscription document and receive
/// each server event's `data` payload, without owning sockets or the
/// ActionCable protocol. Pair it with `ForegroundSubscription` in
/// `foreground_subscription.dart` so the socket tears down when the app
/// backgrounds or the screen closes.
class GraphQlSubscriptions {
  GraphQlSubscriptions({
    required this.account,
    required this.readToken,
    Uri? cableUri,
  }) : cableUri = cableUri ?? resolveCableUri(account);

  final AccountKey account;
  final TokenReader readToken;
  final Uri cableUri;

  /// Streams each server event's GraphQL `data` map for [query].
  ///
  /// The socket connects and subscribes on first listen and closes on cancel,
  /// so cancelling the returned stream subscription is the whole teardown.
  // ponytail: one socket per subscription; multiplex over a shared cable
  // connection if screens ever hold many subscriptions at once.
  Stream<Map<String, dynamic>> subscribe(
    String query, {
    Map<String, dynamic> variables = const {},
    String? operationName,
  }) {
    // ActionCable identifies a channel subscription by this JSON string and
    // echoes it back verbatim on every frame for it.
    final identifier = jsonEncode({
      'channel': 'GraphqlChannel',
      'query': query,
      'variables': variables,
      'operationName': operationName,
    });
    WebSocket? socket;
    var cancelled = false;
    late final StreamController<Map<String, dynamic>> controller;
    controller = StreamController(
      onListen: () async {
        try {
          final token = (await readToken(account)).accessToken;
          if (cancelled) return;
          final connected = await WebSocket.connect(
            cableUri.toString(),
            headers: {if (token != null) 'Authorization': 'Bearer $token'},
          );
          if (cancelled) {
            await connected.close();
            return;
          }
          socket = connected;
          connected.listen(
            (frame) => _handleFrame(frame, identifier, connected, controller),
            onError: (Object error, StackTrace stackTrace) {
              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
              }
            },
            onDone: () {
              if (!controller.isClosed) unawaited(controller.close());
            },
          );
        } on Object catch (error, stackTrace) {
          if (!cancelled && !controller.isClosed) {
            controller.addError(error, stackTrace);
            await controller.close();
          }
        }
      },
      onCancel: () {
        cancelled = true;
        return socket?.close();
      },
    );
    return controller.stream;
  }

  void _handleFrame(
    Object? frame,
    String identifier,
    WebSocket socket,
    StreamController<Map<String, dynamic>> controller,
  ) {
    final decoded = jsonDecode(frame! as String);
    if (decoded is! Map<String, dynamic>) return;
    switch (decoded['type']) {
      case 'welcome':
        socket.add(
          jsonEncode({'command': 'subscribe', 'identifier': identifier}),
        );
        return;
      case 'reject_subscription':
        controller.addError(StateError('GraphQL subscription rejected'));
        unawaited(_closeTransport(socket, controller));
        return;
    }
    if (decoded['identifier'] != identifier) return;
    final message = decoded['message'];
    if (message is! Map<String, dynamic>) return;
    final result = message['result'];
    final data = result is Map<String, dynamic> ? result['data'] : null;
    // GraphqlChannel's initial confirmation result carries null data; only
    // real events reach subscribers.
    if (data is Map<String, dynamic>) controller.add(data);
    if (message['more'] == false) {
      unawaited(_closeTransport(socket, controller));
    }
  }

  Future<void> _closeTransport(
    WebSocket socket,
    StreamController<Map<String, dynamic>> controller,
  ) async {
    final controllerClosed = controller.isClosed ? null : controller.close();
    await socket.close();
    await controllerClosed;
  }
}
