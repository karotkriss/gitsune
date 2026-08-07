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
}
