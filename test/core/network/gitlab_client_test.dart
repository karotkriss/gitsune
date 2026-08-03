import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';

import '../../support/fake_gitlab_server.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'alice',
  );

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
      readToken: (_) async => const TokenReadResult('tok-abc'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );

    final response = await dio.get('/projects');

    expect(response.statusCode, 200);
    expect(seenAuthHeader, 'Bearer tok-abc');
  });

  test('a caller-provided authorization header is preserved', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    String? seenAuthHeader;
    server.handle('GET /api/v4/projects', (request) async {
      seenAuthHeader = request.headers.value('authorization');
      request.response.statusCode = 200;
      await request.response.close();
    });

    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('account-token'),
      refreshToken: (_, _) async => fail('refresh should not be called'),
    );

    await dio.get(
      '/projects',
      options: Options(headers: {'authorization': 'Bearer caller-token'}),
    );

    expect(seenAuthHeader, 'Bearer caller-token');
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
      request.response.write(
        'authorized-with-${request.headers.value('authorization')}',
      );
      await request.response.close();
    });

    var refreshCalls = 0;
    String? rejectedToken;
    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('stale-token'),
      refreshToken: (_, rejected) async {
        refreshCalls++;
        rejectedToken = rejected;
        return 'fresh-token';
      },
    );

    final response = await dio.get('/projects');

    expect(response.statusCode, 200);
    expect(response.data, 'authorized-with-Bearer fresh-token');
    expect(refreshCalls, 1);
    // The refresher is told which token the 401'd request carried.
    expect(rejectedToken, 'stale-token');
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
      readToken: (_) async => const TokenReadResult('stale-token'),
      refreshToken: (_, _) async {
        refreshCalls++;
        return 'still-bad-token';
      },
    );

    await expectLater(
      dio.get('/projects'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    expect(refreshCalls, 1);
    expect(callCount, 2);
  });

  test('a multipart request body is replayed after a 401', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    final requestBodies = <String>[];
    server.handle('POST /api/v4/projects', (request) async {
      requestBodies.add(await utf8.decoder.bind(request).join());
      if (requestBodies.length == 1) {
        request.response.statusCode = 401;
      } else {
        request.response.statusCode = 201;
        request.response.write('{}');
      }
      await request.response.close();
    });

    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('stale-token'),
      refreshToken: (_, _) async => 'fresh-token',
    );

    final response = await dio.post(
      '/projects',
      data: FormData.fromMap({'name': 'gitsune'}),
    );

    expect(response.statusCode, 201);
    expect(requestBodies, hasLength(2));
    expect(requestBodies[0], contains('gitsune'));
    expect(requestBodies[1], requestBodies[0]);
  });

  test('a stream request body is not retried after a 401', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    var requestCount = 0;
    server.handle('POST /api/v4/projects', (request) async {
      requestCount++;
      await request.drain<void>();
      request.response.statusCode = 401;
      await request.response.close();
    });

    var refreshCalls = 0;
    final dio = createGitLabClient(
      account: account,
      baseUrl: server.baseUri.resolve('/api/v4'),
      readToken: (_) async => const TokenReadResult('stale-token'),
      refreshToken: (_, _) async {
        refreshCalls++;
        return 'fresh-token';
      },
    );

    await expectLater(
      dio.post(
        '/projects',
        data: Stream<List<int>>.value(utf8.encode('payload')),
        options: Options(headers: {'content-length': '7'}),
      ),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );

    expect(refreshCalls, 0);
    expect(requestCount, 1);
  });

  test('base URL resolves per account for two different instances', () {
    const gitlabCom = AccountKey(
      instanceHost: 'gitlab.com',
      accountId: 'alice',
    );
    const selfHosted = AccountKey(
      instanceHost: 'gitlab.example.com',
      accountId: 'bob',
    );

    expect(
      resolveApiBaseUrl(gitlabCom).toString(),
      'https://gitlab.com/api/v4',
    );
    expect(
      resolveApiBaseUrl(selfHosted).toString(),
      'https://gitlab.example.com/api/v4',
    );
  });
}
