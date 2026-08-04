import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/network/gitlab_client.dart';
import 'package:gitsune/core/network/graphql_subscriptions.dart';

import '../../support/fake_cable_server.dart';

void main() {
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: '7',
  );
  late FakeCableServer server;

  setUp(() async {
    server = await FakeCableServer.start();
  });

  tearDown(() => server.close());

  GraphQlSubscriptions subscriptions({String? token = 'token-123'}) =>
      GraphQlSubscriptions(
        account: account,
        readToken: (_) async => TokenReadResult(token),
        cableUri: server.uri,
      );

  test('resolves the instance cable endpoint over wss', () {
    expect(
      resolveCableUri(account),
      Uri.parse('wss://gitlab.example.com/-/cable'),
    );
  });

  test('preserves a self-hosted instance port in the cable endpoint', () {
    expect(
      resolveCableUri(
        const AccountKey(
          instanceHost: 'gitlab.example.com:8443',
          accountId: '7',
        ),
      ),
      Uri.parse('wss://gitlab.example.com:8443/-/cable'),
    );
  });

  test('subscribes with the bearer token and streams pushed events', () async {
    const query = 'subscription { issuableTitleUpdated { title } }';
    final events = <Map<String, dynamic>>[];
    final subscription = subscriptions()
        .subscribe(query, variables: {'issuableId': 'gid://gitlab/Issue/1'})
        .listen(events.add);

    await waitUntil(() => server.connections.any((c) => c.identifier != null));
    final connection = server.connections.single;
    expect(connection.authorization, 'Bearer token-123');
    final identifier =
        jsonDecode(connection.identifier!) as Map<String, dynamic>;
    expect(identifier['channel'], 'GraphqlChannel');
    expect(identifier['query'], query);
    expect(identifier['variables'], {'issuableId': 'gid://gitlab/Issue/1'});

    connection.pushResult({
      'issuableTitleUpdated': {'title': 'Renamed'},
    });
    await waitUntil(() => events.isNotEmpty);
    expect(events.single, {
      'issuableTitleUpdated': {'title': 'Renamed'},
    });

    await subscription.cancel();
  });

  test('cancelling the subscription closes the socket', () async {
    final subscription = subscriptions()
        .subscribe('subscription { x }')
        .listen((_) {});
    await waitUntil(() => server.connections.any((c) => c.identifier != null));

    await subscription.cancel();
    await waitUntil(() => server.connections.single.closed);
  });

  test('cancelling while token loading prevents a connection', () async {
    final token = Completer<TokenReadResult>();
    final pending = GraphQlSubscriptions(
      account: account,
      readToken: (_) => token.future,
      cableUri: server.uri,
    ).subscribe('subscription { x }').listen((_) {});

    await pending.cancel();
    token.complete(const TokenReadResult('token-123'));
    await Future<void>.delayed(Duration.zero);

    expect(server.connections, isEmpty);
  });

  test('a rejected subscription closes the stream and socket', () async {
    Object? error;
    var done = false;
    subscriptions()
        .subscribe('subscription { x }')
        .listen(
          (_) {},
          onError: (Object value) => error = value,
          onDone: () => done = true,
        );
    await waitUntil(() => server.connections.any((c) => c.identifier != null));

    server.connections.single.rejectSubscription();
    await waitUntil(() => done && server.connections.single.closed);

    expect(error, isA<StateError>());
  });

  test('a terminal result closes the stream and socket', () async {
    final events = <Map<String, dynamic>>[];
    var done = false;
    subscriptions()
        .subscribe('subscription { x }')
        .listen(events.add, onDone: () => done = true);
    await waitUntil(() => server.connections.any((c) => c.identifier != null));

    server.connections.single.pushResult({'x': true}, more: false);
    await waitUntil(() => done && server.connections.single.closed);

    expect(events, [
      {'x': true},
    ]);
  });

  test('a server-side close ends the stream', () async {
    var done = false;
    subscriptions()
        .subscribe('subscription { x }')
        .listen((_) {}, onDone: () => done = true);
    await waitUntil(() => server.connections.any((c) => c.identifier != null));

    await server.close();
    await waitUntil(() => done);
  });
}
