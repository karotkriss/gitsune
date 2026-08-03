import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/shell/app_shell.dart';
import 'package:gitsune/features/sign_in/self_hosted_wizard_screen.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';

Widget app(SignInScreen screen) =>
    MaterialApp(theme: buildAppTheme(), home: screen);

void main() {
  testWidgets('shows the instance field pre-filled with gitlab.com and '
      'no credential fields', (tester) async {
    await tester.pumpWidget(app(const SignInScreen()));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'gitlab.com');
    expect(field.obscureText, isFalse);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('assword'), findsNothing);
    expect(find.textContaining('sername'), findsNothing);
  });

  testWidgets('Continue on gitlab.com starts OAuth directly, without '
      'probing', (tester) async {
    var signIns = 0;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => signIns++,
          probeInstance: (_) async => fail('gitlab.com must not be probed'),
          signInSelfHosted: (_) async =>
              fail('gitlab.com must use the baked-in config'),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(signIns, 1);
    expect(find.textContaining('try again'), findsNothing);
  });

  testWidgets('ignores keyboard submissions while sign-in is active', (
    tester,
  ) async {
    final completion = Completer<void>();
    var signIns = 0;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () {
            signIns++;
            return completion.future;
          },
        ),
      ),
    );

    final submit = tester
        .widget<TextField>(find.byType(TextField))
        .onSubmitted!;
    submit('gitlab.com');
    submit('gitlab.com');
    await tester.pump();

    expect(signIns, 1);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);

    completion.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
  });

  testWidgets('a URL failing the basic check shows an inline error and '
      'never signs in', (tester) async {
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => fail('must not sign in'),
          probeInstance: (_) async => fail('must not probe'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'not a url');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid instance URL, like gitlab.com.'),
      findsOneWidget,
    );
  });

  testWidgets('an unreachable or non-GitLab instance shows an inline error', (
    tester,
  ) async {
    Uri? probed;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => fail('must not sign in'),
          probeInstance: (base) async {
            probed = base;
            return false;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'gitlab.example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(probed, Uri.parse('https://gitlab.example.com'));
    expect(
      find.text(
        'gitlab.example.com does not answer as a GitLab instance. '
        'Check the address and try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('an HTTP instance is rejected before probing or sign-in', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => fail('must not sign in'),
          probeInstance: (_) async => fail('must not probe'),
          signInSelfHosted: (_) async => fail('must not sign in'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'http://gitlab.example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Sign-in requires an HTTPS instance.'), findsOneWidget);
  });

  testWidgets('a reachable self-hosted instance starts self-hosted sign-in '
      'with the parsed base URL, never gitlab.com OAuth', (tester) async {
    Uri? signedInto;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => fail('must not start gitlab.com OAuth'),
          probeInstance: (_) async => true,
          signInSelfHosted: (base) async => signedInto = base,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'gitlab.example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(signedInto, Uri.parse('https://gitlab.example.com'));
    expect(find.textContaining('not available yet'), findsNothing);
  });

  testWidgets('a reachable self-hosted instance opens the E2.3 registration '
      'wizard by default', (tester) async {
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async => fail('must not start gitlab.com OAuth'),
          probeInstance: (_) async => true,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'gitlab.example.com');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(SelfHostedWizardScreen), findsOneWidget);
    expect(find.text('dev.gitsune://oauth-callback'), findsOneWidget);
  });

  testWidgets('editing the field clears the inline error', (tester) async {
    await tester.pumpWidget(app(const SignInScreen()));

    await tester.enterText(find.byType(TextField), 'not a url');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('valid instance URL'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'gitlab.com');
    await tester.pumpAndSettle();
    expect(find.textContaining('valid instance URL'), findsNothing);
  });

  testWidgets('a failed OAuth attempt surfaces inline and can be retried', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      app(
        SignInScreen(
          signIn: () async {
            attempts++;
            if (attempts == 1) throw StateError('browser dismissed');
          },
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Sign-in was not completed. Try again.'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.textContaining('try again'), findsNothing);
  });

  testWidgets('the Profile tab opens the sign-in screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: buildAppRouter(initialLocation: '/profile'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
