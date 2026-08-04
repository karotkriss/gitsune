import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// An in-process fake of GitLab's ActionCable GraphQL subscription endpoint
/// (`/-/cable`), so subscription tests never reach a live instance.
///
/// Speaks just enough of the ActionCable protocol for `GraphqlChannel`:
/// `welcome` on connect, `confirm_subscription` on subscribe, and
/// server-pushed result frames via [FakeCableConnection.pushResult].
class FakeCableServer {
  FakeCableServer._(this._server) {
    _server.listen(_handleUpgrade);
  }

  final HttpServer _server;
  final connections = <FakeCableConnection>[];

  static Future<FakeCableServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return FakeCableServer._(server);
  }

  /// The `ws://` URI tests point `GraphQlSubscriptions.cableUri` at.
  Uri get uri => Uri(
    scheme: 'ws',
    host: 'localhost',
    port: _server.port,
    path: '/-/cable',
  );

  Future<void> _handleUpgrade(HttpRequest request) async {
    final authorization = request.headers.value('authorization');
    final socket = await WebSocketTransformer.upgrade(request);
    final connection = FakeCableConnection._(socket, authorization);
    connections.add(connection);
    socket.add(jsonEncode({'type': 'welcome'}));
    socket.listen((frame) {
      final command = jsonDecode(frame as String) as Map<String, dynamic>;
      switch (command['command']) {
        case 'subscribe':
          connection.identifier = command['identifier'] as String;
          socket.add(
            jsonEncode({
              'identifier': connection.identifier,
              'type': 'confirm_subscription',
            }),
          );
        case 'unsubscribe':
          connection.identifier = null;
      }
    }, onDone: () => connection.closed = true);
  }

  Future<void> close() async {
    // Upgraded sockets are detached from the HttpServer, so close them too.
    for (final connection in connections) {
      await connection._socket.close();
    }
    await _server.close(force: true);
  }
}

/// One accepted cable connection: the bearer header it arrived with, the
/// channel identifier it subscribed (null until then), and whether the
/// client has closed it.
class FakeCableConnection {
  FakeCableConnection._(this._socket, this.authorization);

  final WebSocket _socket;
  final String? authorization;
  String? identifier;
  bool closed = false;

  /// Pushes one GraphQL event the way GitLab's `GraphqlChannel` streams
  /// subscription results.
  void pushResult(Map<String, dynamic> data, {bool more = true}) {
    _socket.add(
      jsonEncode({
        'identifier': identifier,
        'message': {
          'result': {'data': data},
          'more': more,
        },
      }),
    );
  }

  void rejectSubscription() {
    _socket.add(
      jsonEncode({'identifier': identifier, 'type': 'reject_subscription'}),
    );
  }
}

/// Polls [condition] until it holds, failing after [timeout]. Wait on an
/// observable condition rather than a fixed delay: full-suite concurrency
/// can overrun any fixed sleep.
Future<void> waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('waitUntil condition not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
