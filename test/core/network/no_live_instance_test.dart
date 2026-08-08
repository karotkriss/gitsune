import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/loopback_http_overrides.dart';

/// Proves the E16.3 no-live-instance guarantee is enforced, not assumed: with
/// the loopback guard active (installed globally by `flutter_test_config.dart`)
/// the in-process fake server on loopback is reachable, while any connection to
/// a real host fails loudly.
void main() {
  test('flutter_test_config installs the loopback guard globally', () {
    expect(HttpOverrides.current, isA<LoopbackHttpOverrides>());
  });

  test('a request to the loopback fake server succeeds', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.respondJson('GET /api/v4/version', {'version': '17.0'});

    final response = await Dio().get<Object?>(
      server.baseUri.resolve('/api/v4/version').toString(),
    );

    expect(response.statusCode, 200);
  });

  test('a request to a non-loopback host is blocked', () async {
    await expectLater(
      Dio().get<Object?>('https://gitlab.example.com/api/v4/version'),
      throwsA(
        isA<DioException>().having(
          (e) => e.error,
          'error',
          isA<LiveNetworkBlocked>(),
        ),
      ),
    );
  });

  test('a raw HttpClient to a non-loopback host is blocked', () {
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    expect(
      () => client.getUrl(Uri.parse('https://gitlab.com/api/v4/version')),
      throwsA(isA<LiveNetworkBlocked>()),
    );
  });

  test('the only HttpOverrides subclass in the test tree is the sanctioned '
      'loopback guard', () {
    // A test that subclasses HttpOverrides itself - especially a bare
    // pass-through with no createHttpClient override - silently re-opens the
    // whole network for its client and defeats this guarantee. The only
    // sanctioned subclass is LoopbackHttpOverrides; every test reuses it.
    // The needle is split so this enforcement file never matches itself.
    final needle =
        'extends '
        'HttpOverrides';
    const sanctioned = 'test/support/loopback_http_overrides.dart';
    final offenders = <String>[];
    for (final dir in const ['test', 'integration_test']) {
      final root = Directory(dir);
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final path = entity.path.replaceAll(r'\', '/');
        if (path == sanctioned) continue;
        if (entity.readAsStringSync().contains(needle)) offenders.add(path);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'These test files declare their own HttpOverrides subclass; route '
          'them through the shared LoopbackHttpOverrides in $sanctioned '
          'instead so the no-live-instance guard is not bypassed.',
    );
  });
}
