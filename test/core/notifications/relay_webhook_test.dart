import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/notifications/relay_webhook.dart';

import '../../support/fixtures.dart';

void main() {
  const topic = 'gitsune-a1b2c3';
  const appToken = 'azGDORePK8gMaC0QOYAMyEEuzJnyUi';
  const userKey = 'uQiRzpo4DXghDmr9QzzfQu27cmVRsG';

  Matcher rejects(RelayInputRejection rejection) => throwsA(
    isA<RelayInputException>().having(
      (e) => e.rejection,
      'rejection',
      rejection,
    ),
  );

  group('parseNtfyTarget', () {
    test('defaults the scheme to https and drops any query', () {
      final target = parseNtfyTarget(
        server: 'ntfy.example.com?x=1',
        topic: ' $topic ',
      );
      expect(target.server, Uri.parse('https://ntfy.example.com'));
      expect(target.topic, topic);
    });

    test('preserves a self-hosted subpath', () {
      final target = parseNtfyTarget(
        server: 'https://example.com/ntfy/',
        topic: topic,
      );
      expect(target.server, Uri.parse('https://example.com/ntfy/'));
    });

    test('rejects each bad input with its specific rejection', () {
      expect(
        () => parseNtfyTarget(server: '  ', topic: topic),
        rejects(RelayInputRejection.emptyServer),
      );
      expect(
        () => parseNtfyTarget(server: 'not a url', topic: topic),
        rejects(RelayInputRejection.malformedServer),
      );
      expect(
        () => parseNtfyTarget(server: 'ntfy.sh', topic: ''),
        rejects(RelayInputRejection.emptyTopic),
      );
      expect(
        () => parseNtfyTarget(server: 'ntfy.sh', topic: 'has spaces!'),
        rejects(RelayInputRejection.malformedTopic),
      );
    });
  });

  group('parsePushoverTarget', () {
    test('accepts and trims the documented 30-character keys', () {
      final target = parsePushoverTarget(
        appToken: ' $appToken ',
        userKey: userKey,
      );
      expect(target.appToken, appToken);
      expect(target.userKey, userKey);
    });

    test('rejects each bad input with its specific rejection', () {
      expect(
        () => parsePushoverTarget(appToken: '', userKey: userKey),
        rejects(RelayInputRejection.emptyAppToken),
      );
      expect(
        () => parsePushoverTarget(appToken: 'too-short', userKey: userKey),
        rejects(RelayInputRejection.malformedAppToken),
      );
      expect(
        () => parsePushoverTarget(appToken: appToken, userKey: ''),
        rejects(RelayInputRejection.emptyUserKey),
      );
      expect(
        () => parsePushoverTarget(appToken: appToken, userKey: 'nope'),
        rejects(RelayInputRejection.malformedUserKey),
      );
    });
  });

  group('buildRelayWebhookConfig', () {
    test('ntfy: publish-as-JSON at the server root, exact template', () {
      final config = buildRelayWebhookConfig(
        NtfyTarget(server: Uri.parse('https://ntfy.sh'), topic: topic),
      );
      expect(config.url, Uri.parse('https://ntfy.sh'));
      expect(
        config.payloadTemplate,
        Fixtures.raw('notifications/ntfy_webhook_template').trimRight(),
      );
    });

    test('ntfy: a subpath server posts to that subpath, exact template', () {
      final config = buildRelayWebhookConfig(
        NtfyTarget(
          server: Uri.parse('https://example.com/ntfy/'),
          topic: topic,
        ),
      );
      expect(config.url, Uri.parse('https://example.com/ntfy/'));
      expect(
        config.payloadTemplate,
        Fixtures.raw('notifications/ntfy_webhook_template').trimRight(),
      );
    });

    test('pushover: messages API with credentials in the template', () {
      final config = buildRelayWebhookConfig(
        const PushoverTarget(appToken: appToken, userKey: userKey),
      );
      expect(config.url, Uri.parse('https://api.pushover.net/1/messages.json'));
      expect(
        config.payloadTemplate,
        Fixtures.raw('notifications/pushover_webhook_template').trimRight(),
      );
    });
  });

  group('sendRelayTestNotification', () {
    Future<HttpServer> relayServer(
      void Function(HttpRequest request, String body) handle,
    ) async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      server.listen((request) async {
        handle(request, await utf8.decoder.bind(request).join());
        await request.response.close();
      });
      return server;
    }

    test('posts the ntfy JSON shape and succeeds on 200', () async {
      Map<String, dynamic>? received;
      String? contentType;
      final server = await relayServer((request, body) {
        contentType = request.headers.contentType?.mimeType;
        received = jsonDecode(body) as Map<String, dynamic>;
        request.response.statusCode = 200;
      });

      await sendRelayTestNotification(
        NtfyTarget(server: Uri.parse('https://ntfy.sh'), topic: topic),
        url: Uri.parse('http://127.0.0.1:${server.port}/'),
      );

      expect(contentType, 'application/json');
      expect(received!['topic'], topic);
      expect(received!['title'], 'Gitsune');
      expect(received!['message'], 'Test notification from Gitsune');
    });

    test('posts the pushover JSON shape with the credentials', () async {
      Map<String, dynamic>? received;
      final server = await relayServer((request, body) {
        received = jsonDecode(body) as Map<String, dynamic>;
        request.response.statusCode = 200;
      });

      await sendRelayTestNotification(
        const PushoverTarget(appToken: appToken, userKey: userKey),
        url: Uri.parse('http://127.0.0.1:${server.port}/1/messages.json'),
      );

      expect(received!['token'], appToken);
      expect(received!['user'], userKey);
    });

    Matcher fails(RelayTestFailure failure) => throwsA(
      isA<RelayTestException>().having((e) => e.failure, 'failure', failure),
    );

    test('a 4xx answer is a rejection (bad topic, token, or key)', () async {
      final server = await relayServer((request, _) {
        request.response.statusCode = 403;
      });
      await expectLater(
        sendRelayTestNotification(
          NtfyTarget(server: Uri.parse('https://ntfy.sh'), topic: topic),
          url: Uri.parse('http://127.0.0.1:${server.port}/'),
        ),
        fails(RelayTestFailure.rejected),
      );
    });

    test('a connection failure is unreachable', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();
      await expectLater(
        sendRelayTestNotification(
          NtfyTarget(server: Uri.parse('https://ntfy.sh'), topic: topic),
          url: Uri.parse('http://127.0.0.1:$port/'),
        ),
        fails(RelayTestFailure.unreachable),
      );
    });

    test('a 5xx answer is unexpected, not a credential rejection', () async {
      final server = await relayServer((request, _) {
        request.response.statusCode = 500;
      });
      await expectLater(
        sendRelayTestNotification(
          NtfyTarget(server: Uri.parse('https://ntfy.sh'), topic: topic),
          url: Uri.parse('http://127.0.0.1:${server.port}/'),
        ),
        fails(RelayTestFailure.unexpected),
      );
    });
  });
}
