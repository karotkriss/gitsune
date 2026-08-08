import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/accounts/accounts_screen.dart';

void main() {
  testWidgets('the account avatar decodes at its display size, not the '
      'source size (E16.2)', (tester) async {
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Center(
            child: AccountAvatar(
              label: 'Alice',
              avatarUrl: 'https://gitlab.example.com/uploads/avatar.png',
              size: 40,
            ),
          ),
        ),
      ),
    );
    // Read on the mount frame, before the (blocked) network load can flip the
    // widget to its initials fallback on a later frame.
    final circle = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    final provider = circle.foregroundImage;
    expect(provider, isA<ResizeImage>());
    final resize = provider! as ResizeImage;

    // 40 logical px at devicePixelRatio 3.0 => decode a 120 px bitmap, not the
    // full-resolution source.
    expect(resize.width, 120);
    expect(resize.height, 120);
    expect(resize.policy, ResizeImagePolicy.fit);
    expect(resize.imageProvider, isA<NetworkImage>());

    // The blocked network fetch is expected; drain it so it doesn't fail here.
    tester.takeException();
  });
}
