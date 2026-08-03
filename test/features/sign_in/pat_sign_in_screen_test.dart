import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/pat_auth.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/sign_in/pat_sign_in_screen.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';

import '../../support/fake_gitlab_server.dart';
import '../../support/memory_secure_storage.dart';

Widget app(SignInScreen screen) =>
    MaterialApp(theme: buildAppTheme(), home: screen);

Finder tokenField() => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.obscureText,
);

class _RealHttpOverrides extends HttpOverrides {}

Future<void> signInAgainst(
  FakeGitLabServer server,
  String token, {
  Duration timeout = patValidationTimeout,
}) => HttpOverrides.runWithHttpOverrides(() async {
  await signInWithPat(
    baseUrl: server.baseUri,
    token: token,
    tokenStore: SecureTokenStore(storage: MemorySecureStorage()),
    dio: server.createClient(),
    timeout: timeout,
  );
}, _RealHttpOverrides());

/// Waits for the real network round-trip to finish by watching the submit
/// spinner disappear, rather than sleeping a fixed interval that a loaded
/// machine can overrun.
Future<void> settleNetwork(WidgetTester tester) async {
  await tester.pump();
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty &&
      DateTime.now().isBefore(deadline)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the primary sign-in screen exposes no token or credential '
      'field, only the secondary affordance', (tester) async {
    await tester.pumpWidget(app(const SignInScreen()));

    expect(find.byType(TextField), findsOneWidget);
    expect(tokenField(), findsNothing);
    expect(find.textContaining('token'), findsNothing);
    expect(find.textContaining('Token'), findsNothing);
    expect(find.text('Having trouble signing in?'), findsOneWidget);
  });

  testWidgets('the affordance opens token sign-in with the instance field '
      'carried over and an obscured token field', (tester) async {
    await tester.pumpWidget(app(const SignInScreen()));

    await tester.enterText(find.byType(TextField), 'gitlab.example.com');
    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();

    expect(find.byType(PatSignInScreen), findsOneWidget);
    final instanceField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) => widget is TextField && !widget.obscureText,
      ),
    );
    expect(instanceField.controller!.text, 'gitlab.example.com');
    expect(tokenField(), findsOneWidget);
  });

  testWidgets('a valid token signs in against the entered instance and '
      'returns to the primary screen', (tester) async {
    Uri? signedInto;
    String? signedInWith;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => fail('must not start OAuth'),
          signInWithToken: (base, token) async {
            signedInto = base;
            signedInWith = token;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'gitlab.example.com');
    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();

    await tester.enterText(tokenField(), 'glpat-abc123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(signedInto, Uri.parse('https://gitlab.example.com'));
    expect(signedInWith, 'glpat-abc123');
    expect(find.byType(PatSignInScreen), findsNothing);
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('a rejected token routes back to re-entering it: inline '
      'error, field still editable, and a corrected token succeeds', (
    tester,
  ) async {
    late Zone networkZone;
    late FakeGitLabServer server;
    await tester.runAsync(() async {
      networkZone = Zone.current;
      server = await FakeGitLabServer.startSecure();
    });
    addTearDown(server.close);
    final attempts = <String>[];
    server.handle('GET /api/v4/user', (request) async {
      final token = request.headers.value('authorization')!;
      attempts.add(token.substring('Bearer '.length));
      request.response.headers.contentType = ContentType.json;
      if (token != 'Bearer glpat-right') {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.write('{"message":"401 Unauthorized"}');
      } else {
        request.response.write('{"id":42,"username":"alice"}');
      }
      await request.response.close();
    });
    await tester.pumpWidget(
      app(
        SignInScreen(
          signInWithToken: (_, token) =>
              networkZone.run(() => signInAgainst(server, token)),
        ),
      ),
    );

    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();

    await tester.enterText(tokenField(), 'glpat-wrong');
    await tester.tap(find.text('Sign in'));
    await settleNetwork(tester);

    expect(attempts, ['glpat-wrong']);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(PatSignInScreen), findsOneWidget);
    expect(
      find.text(
        'gitlab.com did not accept that token. '
        'Check it and enter it again.',
      ),
      findsOneWidget,
    );

    await tester.enterText(tokenField(), 'glpat-right');
    await tester.pumpAndSettle();
    expect(find.textContaining('did not accept'), findsNothing);
    await tester.tap(find.text('Sign in'));
    await settleNetwork(tester);

    expect(attempts, ['glpat-wrong', 'glpat-right']);
    expect(find.byType(PatSignInScreen), findsNothing);
    await tester.runAsync(server.close);
  });

  testWidgets('an HTTP instance is refused before the token is sent', (
    tester,
  ) async {
    var attempted = false;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signInWithToken: (_, _) async {
            attempted = true;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'http://gitlab.example.com');
    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();
    await tester.enterText(tokenField(), 'glpat-secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(attempted, isFalse);
    expect(
      find.text('Personal access token sign-in requires an HTTPS instance.'),
      findsOneWidget,
    );
  });

  testWidgets('a network failure is not presented as token rejection', (
    tester,
  ) async {
    late Zone networkZone;
    late FakeGitLabServer server;
    await tester.runAsync(() async {
      networkZone = Zone.current;
      server = await FakeGitLabServer.startSecure();
    });
    addTearDown(server.close);
    server.handle('GET /api/v4/user', (request) async {
      final socket = await request.response.detachSocket();
      socket.destroy();
    });
    await tester.pumpWidget(
      app(
        SignInScreen(
          signInWithToken: (_, token) =>
              networkZone.run(() => signInAgainst(server, token)),
        ),
      ),
    );

    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();
    await tester.enterText(tokenField(), 'glpat-valid');
    await tester.tap(find.text('Sign in'));
    await settleNetwork(tester);

    expect(
      find.text(
        'Could not reach gitlab.com. '
        'Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('did not accept'), findsNothing);
    expect(tester.widget<TextField>(tokenField()).enabled, isTrue);
    await tester.runAsync(server.close);
  });

  testWidgets('a stalled endpoint times out into the inline network error', (
    tester,
  ) async {
    late Zone networkZone;
    late FakeGitLabServer server;
    await tester.runAsync(() async {
      networkZone = Zone.current;
      server = await FakeGitLabServer.startSecure();
    });
    final releaseResponse = Completer<void>();
    addTearDown(() async {
      if (!releaseResponse.isCompleted) releaseResponse.complete();
      await server.close();
    });
    server.handle('GET /api/v4/user', (request) async {
      await releaseResponse.future;
      await request.response.close();
    });
    await tester.pumpWidget(
      app(
        SignInScreen(
          signInWithToken: (_, token) => networkZone.run(
            () => signInAgainst(
              server,
              token,
              timeout: const Duration(milliseconds: 50),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();
    await tester.enterText(tokenField(), 'glpat-valid');
    await tester.tap(find.text('Sign in'));
    await settleNetwork(tester);

    expect(
      find.text(
        'Could not reach gitlab.com. '
        'Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<TextField>(tokenField()).enabled, isTrue);
    releaseResponse.complete();
    await tester.runAsync(server.close);
  });

  testWidgets('an empty token or invalid instance shows an inline error '
      'and never signs in', (tester) async {
    await tester.pumpWidget(
      app(
        SignInScreen(signInWithToken: (_, _) async => fail('must not sign in')),
      ),
    );

    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Paste your personal access token.'), findsOneWidget);

    final instanceField = find.byWidgetPredicate(
      (widget) => widget is TextField && !widget.obscureText,
    );
    await tester.enterText(instanceField, 'not a url');
    await tester.enterText(tokenField(), 'glpat-abc123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a valid instance URL, like gitlab.com.'),
      findsOneWidget,
    );
  });
}
