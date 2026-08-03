import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/pat_auth.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/sign_in/pat_sign_in_screen.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';

Widget app(SignInScreen screen) =>
    MaterialApp(theme: buildAppTheme(), home: screen);

Finder tokenField() => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.obscureText,
);

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
    final attempts = <String>[];
    await tester.pumpWidget(
      app(
        SignInScreen(
          signInWithToken: (base, token) async {
            attempts.add(token);
            if (token != 'glpat-right') {
              throw const PatSignInException(PatSignInFailure.rejected);
            }
          },
        ),
      ),
    );

    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();

    await tester.enterText(tokenField(), 'glpat-wrong');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(attempts, ['glpat-wrong', 'glpat-right']);
    expect(find.byType(PatSignInScreen), findsNothing);
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
    await tester.pumpWidget(
      app(
        SignInScreen(
          signInWithToken: (_, _) async =>
              throw const PatSignInException(PatSignInFailure.network),
        ),
      ),
    );

    await tester.tap(find.text('Having trouble signing in?'));
    await tester.pumpAndSettle();
    await tester.enterText(tokenField(), 'glpat-valid');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Could not reach gitlab.com. '
        'Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('did not accept'), findsNothing);
    expect(tester.widget<TextField>(tokenField()).enabled, isTrue);
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
