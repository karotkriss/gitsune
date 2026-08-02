import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/fake_gitlab_server.dart';
import 'support/fixtures.dart';

void main() {
  test('fake GitLab server replays a recorded fixture', () async {
    final server = await FakeGitLabServer.start();
    addTearDown(server.close);

    server.respondJson('GET /api/v4/projects', Fixtures.json('projects_list'));

    final client = HttpClient();
    addTearDown(client.close);
    final request = await client.getUrl(
      server.baseUri.resolve('/api/v4/projects'),
    );
    final response = await request.close();
    final body = jsonDecode(await response.transform(utf8.decoder).join());

    expect(response.statusCode, 200);
    expect(body, Fixtures.json('projects_list'));
  });
}
