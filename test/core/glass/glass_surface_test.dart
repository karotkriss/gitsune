import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/glass/glass_surface.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('modest intensity frosts via BackdropFilter with glass tokens', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const GlassSurface(
          intensity: GlassIntensity.modest,
          child: SizedBox(width: 100, height: 40),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(GlassSurface),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(GlassSurface),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, GlassSurface.modestBackground);
    expect(decoration.border, Border.all(color: GlassSurface.borderColor));
  });

  testWidgets('heavy intensity uses the strong background token', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const GlassSurface(
          intensity: GlassIntensity.heavy,
          child: SizedBox(width: 100, height: 40),
        ),
      ),
    );

    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(GlassSurface),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (box.decoration as BoxDecoration).color,
      GlassSurface.heavyBackground,
    );
  });
}
