import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/sign_in/sign_in_screen.dart';

void main() {
  Future<void> pumpSignIn(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const SignInScreen()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Sign-in screen matches the golden', (tester) async {
    await pumpSignIn(tester);

    await expectLater(
      find.byType(SignInScreen),
      matchesGoldenFile('goldens/sign_in_screen.png'),
    );
  });

  testWidgets('Sign-in screen with an inline URL error matches the golden', (
    tester,
  ) async {
    await pumpSignIn(tester);

    await tester.enterText(find.byType(TextField), 'not a url');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SignInScreen),
      matchesGoldenFile('goldens/sign_in_screen_url_error.png'),
    );
  });
}
