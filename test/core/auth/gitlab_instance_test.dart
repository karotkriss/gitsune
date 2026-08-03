import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/gitlab_instance.dart';

import '../../support/fake_gitlab_server.dart';

void main() {
  group('parseInstanceUrl', () {
    test('defaults a bare host to https and keeps only the instance base', () {
      expect(parseInstanceUrl('gitlab.com'), Uri.parse('https://gitlab.com'));
      expect(
        parseInstanceUrl('  gitlab.example.com  '),
        Uri.parse('https://gitlab.example.com'),
      );
      expect(
        parseInstanceUrl('https://gitlab.example.com/some/path?q=1'),
        Uri.parse('https://gitlab.example.com'),
      );
    });

    test('keeps an explicit scheme and port', () {
      expect(
        parseInstanceUrl('http://gitlab.corp.example:8080'),
        Uri.parse('http://gitlab.corp.example:8080'),
      );
    });

    test('rejects text that cannot name an instance', () {
      expect(parseInstanceUrl(''), isNull);
      expect(parseInstanceUrl('   '), isNull);
      expect(parseInstanceUrl('not a url'), isNull);
      expect(parseInstanceUrl('gitlab'), isNull);
      expect(parseInstanceUrl('ftp://gitlab.com'), isNull);
    });
  });

  group('isGitLabInstance', () {
    late FakeGitLabServer server;

    setUp(() async {
      server = await FakeGitLabServer.start();
    });

    tearDown(() => server.close());

    test('accepts a 200 JSON version response', () async {
      server.respondJson('GET /api/v4/version', {'version': '18.0.0'});
      expect(await isGitLabInstance(server.baseUri), isTrue);
    });

    test('accepts a 401 JSON response (API present, auth required)', () async {
      server.respondJson('GET /api/v4/version', {
        'message': '401 Unauthorized',
      }, statusCode: 401);
      expect(await isGitLabInstance(server.baseUri), isTrue);
    });

    test('rejects a server without the GitLab API', () async {
      // The fake server 404s unregistered paths without a JSON body.
      expect(await isGitLabInstance(server.baseUri), isFalse);
    });

    test('rejects an unreachable host', () async {
      final unreachable = server.baseUri;
      await server.close();
      expect(await isGitLabInstance(unreachable), isFalse);
    });
  });
}
