import 'dart:io';

/// The test suite's no-live-instance guard (E16.3).
///
/// The whole suite must run against the in-process [FakeGitLabServer] (and the
/// fake cable server) on loopback and never reach a real GitLab instance. An
/// [HttpClient] built under these overrides may connect to loopback only; a
/// connection to any other host throws [LiveNetworkBlocked] so the offending
/// test fails loudly instead of silently talking to the network.
///
/// Two seams install it, together covering every test:
/// - `test/flutter_test_config.dart` sets it as `HttpOverrides.global`, which
///   covers plain-Dart `test()` cases (they get no binding-level HttpClient
///   mock, so without this they could reach the real network).
/// - Widget tests that need the loopback fake server use it as their explicit
///   escape hatch from flutter_test's all-blocking mock client, so even that
///   opt-in stays loopback-only rather than a full pass-through.
///
/// dio (every repository and the auth flow) builds a fresh [HttpClient] per
/// request adapter and so honors the current override; that is the surface a
/// real-instance regression would slip through, and it is fully covered.
class LoopbackHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Tests never route through a proxy, so proxyHost/proxyPort are always
    // null here and the destination host is uri.host.
    // ponytail: loopback-only connection factory; if a proxied test ever
    // appears, tunnel through proxyHost instead.
    client.connectionFactory = (uri, _, _) {
      if (!_isLoopback(uri.host)) {
        throw LiveNetworkBlocked(uri);
      }
      if (uri.isScheme('https')) {
        return SecureSocket.startConnect(uri.host, uri.port, context: context);
      }
      return Socket.startConnect(uri.host, uri.port);
    };
    return client;
  }

  static bool _isLoopback(String host) =>
      host == 'localhost' || host == '127.0.0.1' || host == '::1';
}

/// Thrown when a test tries to open a connection to a non-loopback host,
/// meaning it would touch a live instance. Surfaces through dio as the
/// `error` of a `DioException`, so the failing test names the blocked host.
class LiveNetworkBlocked implements Exception {
  LiveNetworkBlocked(this.uri);

  final Uri uri;

  @override
  String toString() =>
      'LiveNetworkBlocked: the test suite tried to reach $uri. Tests must run '
      'against the in-process fake server on loopback only (E16.3 '
      'no-live-instance guarantee).';
}
