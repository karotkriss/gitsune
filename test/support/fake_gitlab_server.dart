import 'dart:convert';
import 'dart:io';

/// An in-process fake GitLab server for tests that need real HTTP semantics
/// (status codes, headers, pagination) rather than just a decoded fixture.
///
/// Binds to loopback only, so the suite never touches the network and never
/// talks to a real GitLab instance.
class FakeGitLabServer {
  FakeGitLabServer._(this._server) {
    _server.listen(_dispatch);
  }

  final HttpServer _server;
  final _handlers = <String, Future<void> Function(HttpRequest)>{};

  static Future<FakeGitLabServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return FakeGitLabServer._(server);
  }

  /// Base URL tests should point their HTTP client's base URL at.
  Uri get baseUri => Uri(scheme: 'http', host: 'localhost', port: _server.port);

  /// Registers a raw handler for `'METHOD /path'`, e.g. `'GET /api/v4/projects'`.
  void handle(
    String methodAndPath,
    Future<void> Function(HttpRequest request) handler,
  ) {
    _handlers[methodAndPath] = handler;
  }

  /// Registers a canned JSON response for `'METHOD /path'`.
  void respondJson(
    String methodAndPath,
    Object? body, {
    int statusCode = 200,
    Map<String, String> headers = const {},
  }) {
    handle(methodAndPath, (request) async {
      request.response.statusCode = statusCode;
      headers.forEach(request.response.headers.set);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
      await request.response.close();
    });
  }

  Future<void> _dispatch(HttpRequest request) async {
    final handler = _handlers['${request.method} ${request.uri.path}'];
    if (handler == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    await handler(request);
  }

  Future<void> close() => _server.close(force: true);
}
