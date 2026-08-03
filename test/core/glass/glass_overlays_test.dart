import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/glass/glass_overlays.dart';
import 'package:gitsune/core/glass/glass_surface.dart';
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

  GlassSurface surfaceIn(WidgetTester tester, Type overlay) =>
      tester.widget<GlassSurface>(
        find.descendant(
          of: find.byType(overlay),
          matching: find.byType(GlassSurface),
        ),
      );

  Color? routeScrim(WidgetTester tester) => tester
      .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier).last)
      .color
      .value;

  Color drawerScrim(WidgetTester tester) => tester
      .widget<ColoredBox>(
        find.descendant(
          of: find.byType(DrawerController),
          matching: find.byWidgetPredicate(
            (widget) => widget is ColoredBox && widget.child is LimitedBox,
          ),
        ),
      )
      .color;

  testWidgets('modal renders heavy glass over the scrim and dismisses on '
      'scrim tap', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Modal'));
    await tester.pumpAndSettle();

    expect(surfaceIn(tester, GlassModal).intensity, GlassIntensity.heavy);
    final gs = Theme.of(
      tester.element(find.byType(GlassModal)),
    ).extension<GsTheme>()!;
    expect(routeScrim(tester), gs.scrim);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(GlassModal), findsNothing);
  });

  testWidgets('modal dismisses on the system back button', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Modal'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GlassModal), findsNothing);
  });

  testWidgets('drawer renders heavy glass over the scrim and dismisses on '
      'scrim tap', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Drawer'));
    await tester.pumpAndSettle();

    expect(surfaceIn(tester, GlassDrawer).intensity, GlassIntensity.heavy);
    final gs = Theme.of(
      tester.element(find.byType(GlassDrawer)),
    ).extension<GsTheme>()!;
    expect(drawerScrim(tester), gs.scrim);

    // The drawer is 304 wide, so this hits the scrim beside it.
    await tester.tapAt(const Offset(380, 400));
    await tester.pumpAndSettle();
    expect(find.byType(GlassDrawer).hitTestable(), findsNothing);
  });

  testWidgets('drawer dismisses on the system back button', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Drawer'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GlassDrawer).hitTestable(), findsNothing);
  });

  testWidgets('bottom sheet renders heavy glass over the scrim and drags '
      'down to dismiss', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();

    expect(surfaceIn(tester, GlassBottomSheet).intensity, GlassIntensity.heavy);
    final gs = Theme.of(
      tester.element(find.byType(GlassBottomSheet)),
    ).extension<GsTheme>()!;
    expect(routeScrim(tester), gs.scrim);

    await tester.drag(
      find.byType(GlassBottomSheet),
      const Offset(0, 400),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.byType(GlassBottomSheet), findsNothing);
  });

  testWidgets('bottom sheet dismisses on scrim tap', (tester) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(GlassBottomSheet), findsNothing);
  });

  testWidgets('bottom sheet dismisses on the system back button', (
    tester,
  ) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GlassBottomSheet), findsNothing);
  });
}
