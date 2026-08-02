import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';

import '../../support/fake_gitlab_server.dart';

void main() {
  const account = AccountKey(instanceHost: 'gitlab.example.com', accountId: 'alice');

  test('a request carries the injected token', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    String? seenAuthHeader;
    server.handle('GET /api/v4/projects', (request) async {
      seenAuthHeader = request.headers.value('authorization');
      request.response.statusCode = 200;
      request.response.write('[]');
      await request.response.close();
    });

    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'tok-abc',
      refreshToken: (_) async => fail('refresh should not be called'),
    );

    final response = await dio.get('/projects');

    expect(response.statusCode, 200);
    expect(seenAuthHeader, 'Bearer tok-abc');
  });

  test('a 401 triggers exactly one refresh and one retry', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    var callCount = 0;
    server.handle('GET /api/v4/projects', (request) async {
      callCount++;
      if (callCount == 1) {
        request.response.statusCode = 401;
        await request.response.close();
        return;
      }
      request.response.statusCode = 200;
      request.response.write('authorized-with-${request.headers.value('authorization')}');
      await request.response.close();
    });

    var refreshCalls = 0;
    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'stale-token',
      refreshToken: (_) async {
        refreshCalls++;
        return 'fresh-token';
      },
    );

    final response = await dio.get('/projects');

    expect(response.statusCode, 200);
    expect(response.data, 'authorized-with-Bearer fresh-token');
    expect(refreshCalls, 1);
    expect(callCount, 2);
  });

  test('a second 401 fails through without looping', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    var callCount = 0;
    server.handle('GET /api/v4/projects', (request) async {
      callCount++;
      request.response.statusCode = 401;
      await request.response.close();
    });

    var refreshCalls = 0;
    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => 'stale-token',
      refreshToken: (_) async {
        refreshCalls++;
        return 'still-bad-token';
      },
    );

    await expectLater(
      dio.get('/projects'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'statusCode', 401)),
    );

    expect(refreshCalls, 1);
    expect(callCount, 2);
  });

  test('base URL resolves per account for two different instances', () {
    const gitlabCom = AccountKey(instanceHost: 'gitlab.com', accountId: 'alice');
    const selfHosted = AccountKey(instanceHost: 'gitlab.example.com', accountId: 'bob');

    expect(resolveApiBaseUrl(gitlabCom).toString(), 'https://gitlab.com/api/v4');
    expect(resolveApiBaseUrl(selfHosted).toString(), 'https://gitlab.example.com/api/v4');
  });
}
