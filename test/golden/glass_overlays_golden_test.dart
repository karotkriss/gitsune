import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/glass_demo/glass_overlays_demo_screen.dart';

void main() {
  Future<void> pumpDemo(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const GlassOverlaysDemoScreen(),
      ),
    );
  }

  testWidgets('glass modal matches golden', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Modal'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/glass_modal.png'),
    );
  });

  testWidgets('glass drawer matches golden', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Drawer'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/glass_drawer.png'),
    );
  });

  testWidgets('glass bottom sheet matches golden', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/glass_bottom_sheet.png'),
    );
  });
}
