import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/icons/gs_icons.dart';
import '../../core/theme/app_theme.dart';
import 'home_tiles.dart';

/// Home tab: the "My Work" shortcut-tile card (E1.4).
///
/// Tiles reorder by long-press drag; the chosen order persists per account
/// through [tileOrderStore]. A null store (before the composition root wires
/// the signed-in account, the same convention as `buildAppRouter`'s optional
/// repositories) renders the default order without persisting.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.tileOrderStore,
    this.onTileTap,
    this.isTileEnabled,
  });

  final HomeTileOrderStore? tileOrderStore;
  final ValueChanged<HomeTile>? onTileTap;

  /// Whether a tile has a destination to navigate to. A disabled tile renders
  /// visibly muted and does not respond to taps (it never dead-taps). Null
  /// enables every tile - the default for isolated screen tests and goldens.
  final bool Function(HomeTile)? isTileEnabled;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeTile> _order = HomeTile.values;
  StreamSubscription<List<HomeTile>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.tileOrderStore?.watchOrder().listen(
      (order) => setState(() => _order = order),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _reorder(int oldIndex, int newIndex) {
    final order = [..._order];
    order.insert(newIndex, order.removeAt(oldIndex));
    setState(() => _order = order);
    unawaited(widget.tileOrderStore?.saveOrder(order));
  }

  Widget _tileRow(HomeTile tile, bool divider) {
    final enabled = widget.isTileEnabled?.call(tile) ?? true;
    return _HomeTileRow(
      key: ValueKey(tile),
      tile: tile,
      divider: divider,
      enabled: enabled,
      onTap: (enabled && widget.onTileTap != null)
          ? () => widget.onTileTap!(tile)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      backgroundColor: gs.surfaceApp,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text('Home', style: gs.screenTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
              child: Text(
                'My Work',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: gs.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gs.borderSubtle),
              ),
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: _reorder,
                children: [
                  for (final (index, tile) in _order.indexed)
                    _tileRow(tile, index < _order.length - 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One shortcut tile, per the mock's `Tile` row: a 32px rounded square in the
/// tile's ramp hue holding its GitLab glyph, the label, and a chevron.
class _HomeTileRow extends StatelessWidget {
  const _HomeTileRow({
    super.key,
    required this.tile,
    required this.divider,
    this.enabled = true,
    this.onTap,
  });

  final HomeTile tile;
  final bool divider;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    // A disabled tile has no destination yet: mute its ramp-colored glyph
    // chip, drop the navigate chevron, and take no tap. The label stays at
    // its full-contrast color so text contrast still passes.
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: divider
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: gs.borderSubtle)),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: enabled ? tile.colorOf(gs) : gs.surfaceStrong,
                borderRadius: BorderRadius.circular(8),
              ),
              // Tile fills are ramp-500 colors, not the accent: white glyphs
              // clear the 3:1 graphical bar on every tile fill.
              child: GsIcon(
                tile.glyph,
                size: 20,
                color: enabled ? gs.textHeading : gs.textSubtle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tile.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (enabled)
              GsIcon(GsIconGlyph.chevronRight, size: 16, color: gs.textSubtle),
          ],
        ),
      ),
    );
  }
}
