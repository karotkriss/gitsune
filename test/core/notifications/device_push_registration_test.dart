import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/notifications/device_push_registration.dart';

import '../../support/fake_gitlab_server.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: 'marin',
  );

  test('deferred by default: throws without registering', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    server.handle('POST /api/v4/user/push_subscriptions', (request) async {
      fail('the deferred seam must never reach the network by default');
    });

    expect(
      () => registerDevice(
        _client(server, account),
        const DevicePushSubscription(
          deviceToken: 'abc123',
          platform: 'apns',
        ),
      ),
      throwsStateError,
    );
    expect(nativePushRegistrationEnabled, isFalse);
  });

  test('shaped to POST /user/push_subscriptions when enabled', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);
    String? requestBody;
    server.handle('POST /api/v4/user/push_subscriptions', (request) async {
      requestBody = await utf8.decoder.bind(request).join();
      request.response.statusCode = HttpStatus.created;
      await request.response.close();
    });

    await registerDevice(
      _client(server, account),
      const DevicePushSubscription(deviceToken: 'abc123', platform: 'apns'),
      enabled: true,
    );

    expect(
      jsonDecode(requestBody!),
      {'device_token': 'abc123', 'platform': 'apns'},
    );
  });
}

Dio _client(FakeGitLabServer server, AccountKey account) => createGitLabClient(
  account: account,
  baseUrl: server.baseUri.resolve('/api/v4'),
  readToken: (_) async => const TokenReadResult('fixture-token'),
  refreshToken: (_, _) async => fail('refresh should not be called'),
);
