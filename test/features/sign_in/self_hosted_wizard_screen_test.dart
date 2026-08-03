import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/sign_in/pat_sign_in_screen.dart';
import 'package:gitsune/features/sign_in/self_hosted_wizard_screen.dart';

import '../../support/oauth_errors.dart';

final base = Uri.parse('https://gitlab.example.com');

/// Hosts the wizard behind a push so tests can observe it popping back on
/// success, the way the sign-in screen presents it.
Widget app(SelfHostedWizardScreen screen) => MaterialApp(
  theme: buildAppTheme(),
  home: Builder(
    builder: (context) => Center(
      child: TextButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => screen)),
        child: const Text('open wizard'),
      ),
    ),
  ),
);

Future<void> pumpWizard(
  WidgetTester tester,
  SelfHostedWizardScreen screen,
) async {
  await tester.pumpWidget(app(screen));
  await tester.tap(find.text('open wizard'));
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into the viewport (the wizard is taller than the test
/// window), then taps it.
Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows every value the user must enter: the applications '
      'page, the exact redirect URI, non-confidential, and both scopes', (
    tester,
  ) async {
    await pumpWizard(
      tester,
      SelfHostedWizardScreen(
        base: base,
        signIn: (_, _) async => fail('must not sign in'),
      ),
    );

    expect(
      find.text('https://gitlab.example.com/-/user_settings/applications'),
      findsOneWidget,
    );
    expect(find.text('dev.gitsune://oauth-callback'), findsOneWidget);
    expect(find.textContaining('Uncheck "Confidential"'), findsOneWidget);
    expect(
      find.textContaining('"api" and "read_user" scopes'),
      findsOneWidget,
    );
    expect(find.textContaining('secret'), findsWidgets);
  });

  testWidgets('a valid Application ID starts self-hosted sign-in with the '
      'whitespace-trimmed value and leaves the wizard', (tester) async {
    Uri? signedInto;
    String? applicationId;
    await pumpWizard(
      tester,
      SelfHostedWizardScreen(
        base: base,
        signIn: (base, id) async {
          signedInto = base;
          applicationId = id;
        },
      ),
    );

    // Pasted with the accidental surrounding whitespace the blueprint's
    // paste-error case names; only the trimmed ID may reach sign-in.
    await tester.enterText(find.byType(TextField), '  the-app-id \n');
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Sign in'));

    expect(signedInto, base);
    expect(applicationId, 'the-app-id');
    expect(find.byType(SelfHostedWizardScreen), findsNothing);
  });

  testWidgets('an empty paste asks for the Application ID without ever '
      'calling sign-in', (tester) async {
    await pumpWizard(
      tester,
      SelfHostedWizardScreen(
        base: base,
        signIn: (_, _) async => fail('must not sign in'),
      ),
    );

    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Sign in'));

    expect(
      find.text(
        'Paste the Application ID from the application you just created.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a pasted application secret is refused by name, never sent', (
    tester,
  ) async {
    await pumpWizard(
      tester,
      SelfHostedWizardScreen(
        base: base,
        signIn: (_, _) async => fail('must not sign in'),
      ),
    );

    await tester.enterText(find.byType(TextField), 'gloas-1234567890abcdef');
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Sign in'));

    expect(
      find.textContaining('paste the Application ID instead'),
      findsOneWidget,
    );
  });

  testWidgets('a paste that is more than the Application ID is refused', (
    tester,
  ) async {
    await pumpWizard(
      tester,
      SelfHostedWizardScreen(
        base: base,
        signIn: (_, _) async => fail('must not sign in'),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Application ID: abc123');
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Sign in'));

    expect(
      find.textContaining('Paste only the Application ID value'),
      findsOneWidget,
    );
  });

  group('each named registration failure surfaces its own guidance', () {
    Future<void> expectFailureMessage(
      WidgetTester tester, {
      required Object thrown,
      required String message,
    }) async {
      await pumpWizard(
        tester,
        SelfHostedWizardScreen(base: base, signIn: (_, _) async => throw thrown),
      );
      await tester.enterText(find.byType(TextField), 'the-app-id');
      await scrollToAndTap(
        tester,
        find.widgetWithText(FilledButton, 'Sign in'),
      );
      expect(find.textContaining(message), findsOneWidget);
      // Still on the wizard, ready to retry after the fix.
      expect(find.byType(SelfHostedWizardScreen), findsOneWidget);
    }

    testWidgets('Confidential left checked', (tester) async {
      await expectFailureMessage(
        tester,
        thrown: tokenEndpointError('oauth_error_invalid_client'),
        message: 'uncheck "Confidential"',
      );
    });

    testWidgets('redirect URI mismatch re-displays the exact string', (
      tester,
    ) async {
      await expectFailureMessage(
        tester,
        thrown: tokenEndpointError('oauth_error_invalid_grant'),
        message:
            'set Redirect URI to exactly dev.gitsune://oauth-callback',
      );
    });

    testWidgets('scope mismatch names the required scopes', (tester) async {
      await expectFailureMessage(
        tester,
        thrown: tokenEndpointError('oauth_error_invalid_scope'),
        message: 'select the "api" and "read_user" scopes',
      );
    });

    testWidgets('PKCE unsupported points at the personal access token path', (
      tester,
    ) async {
      await expectFailureMessage(
        tester,
        thrown: tokenEndpointError('oauth_error_invalid_code_challenge_method'),
        message: 'too old for secure app sign-in',
      );
      expect(
        find.textContaining('personal access token'),
        findsWidgets,
      );
    });

    testWidgets('anything unrecognized fails plainly and can be retried', (
      tester,
    ) async {
      await expectFailureMessage(
        tester,
        thrown: StateError('browser dismissed'),
        message: 'Sign-in was not completed. Try again.',
      );
    });
  });

  testWidgets('the impossible-to-register path routes to the personal '
      'access token fallback with the instance pre-filled', (tester) async {
    await pumpWizard(
      tester,
      SelfHostedWizardScreen(
        base: base,
        signIn: (_, _) async => fail('must not sign in'),
        signInWithToken: (_, _) async => fail('must not sign in yet'),
      ),
    );

    expect(
      find.textContaining('disabled OAuth application registration'),
      findsOneWidget,
    );

    await scrollToAndTap(
      tester,
      find.text('Sign in with a personal access token'),
    );

    expect(find.byType(PatSignInScreen), findsOneWidget);
    final instanceField = tester.widget<TextField>(
      find.byType(TextField).first,
    );
    expect(instanceField.controller!.text, 'https://gitlab.example.com');
  });
}
