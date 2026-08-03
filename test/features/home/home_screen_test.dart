import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/icons/gs_icons.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/home/home_screen.dart';
import 'package:gitsune/features/home/home_tiles.dart';

void main() {
  const account = AccountKey(instanceHost: 'gitlab.com', accountId: '1');

  Widget wrap(Widget child) => MaterialApp(theme: buildAppTheme(), home: child);

  /// The tiles in visual order, read from their labels' vertical positions.
  List<HomeTile> visibleOrder(WidgetTester tester) {
    final tiles = [...HomeTile.values]
      ..sort(
        (a, b) => tester
            .getTopLeft(find.text(a.label))
            .dy
            .compareTo(tester.getTopLeft(find.text(b.label)).dy),
      );
    return tiles;
  }

  Future<void> dragTileBy(
    WidgetTester tester,
    HomeTile tile,
    Offset offset,
  ) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(tile.label)),
    );
    await tester.pump(kLongPressTimeout + kPressTimeout);
    await gesture.moveBy(Offset(offset.dx / 2, offset.dy / 2));
    await tester.pump(kPressTimeout);
    await gesture.moveBy(Offset(offset.dx / 2, offset.dy / 2));
    await tester.pump(kPressTimeout);
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('renders the six tiles with ramp colors and glyphs', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const HomeScreen()));

    final gs = Theme.of(
      tester.element(find.byType(HomeScreen)),
    ).extension<GsTheme>()!;
    expect(visibleOrder(tester), HomeTile.values);
    for (final tile in HomeTile.values) {
      final square = tester.widget<Container>(
        find
            .ancestor(
              of: find.byWidgetPredicate(
                (widget) => widget is GsIcon && widget.glyph == tile.glyph,
              ),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (square.decoration! as BoxDecoration).color,
        tile.colorOf(gs),
        reason: '${tile.label} tile hue',
      );
    }
  });

  testWidgets('taps report the tile', (tester) async {
    final taps = <HomeTile>[];
    await tester.pumpWidget(wrap(HomeScreen(onTileTap: taps.add)));

    await tester.tap(find.text('To-Do List'));
    expect(taps, [HomeTile.todos]);
  });

  testWidgets('drag-reordering persists across widget and store recreation', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      wrap(
        HomeScreen(
          tileOrderStore: HomeTileOrderStore(
            database: database,
            account: account,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // One row is 49 logical pixels (48 content + divider), so 60 down moves
    // Issues exactly one slot.
    await dragTileBy(tester, HomeTile.issues, const Offset(0, 60));
    final reordered = [
      HomeTile.mergeRequests,
      HomeTile.issues,
      HomeTile.todos,
      HomeTile.pipelines,
      HomeTile.projects,
      HomeTile.groups,
    ];
    expect(visibleOrder(tester), reordered);

    // Recreate the widget and store on the same database: the saved order
    // must come back, as it would across an app restart.
    await tester.pumpWidget(wrap(const SizedBox()));
    await tester.pumpWidget(
      wrap(
        HomeScreen(
          tileOrderStore: HomeTileOrderStore(
            database: database,
            account: account,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(visibleOrder(tester), reordered);

    // Unmount before the test ends: cancelling the drift stream subscription
    // schedules a zero-duration timer, which must fire inside the test body
    // (a timed pump, since only elapsing fake time runs timers).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
