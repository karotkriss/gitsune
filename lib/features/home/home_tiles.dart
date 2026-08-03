import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../../core/database/app_database.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/network/account_key.dart';
import '../../core/theme/app_theme.dart';

/// The six Home "My Work" shortcut tiles, in their default order.
///
/// Each tile pairs its GitLab glyph with its Pajamas ramp hue (the
/// `--gs-tile-*` tokens on [GsTheme]), matching the mock's
/// `design/ui_kits/gitsune-app/Home.jsx`.
enum HomeTile {
  issues('Issues', GsIconGlyph.issues),
  mergeRequests('Merge Requests', GsIconGlyph.mergeRequest),
  todos('To-Do List', GsIconGlyph.todoDone),
  pipelines('Pipelines', GsIconGlyph.rocket),
  projects('Projects', GsIconGlyph.project),
  groups('Groups', GsIconGlyph.group);

  const HomeTile(this.label, this.glyph);

  final String label;
  final GsIconGlyph glyph;

  Color colorOf(GsTheme gs) => switch (this) {
    issues => gs.tileIssues,
    mergeRequests => gs.tileMrs,
    todos => gs.tileTodos,
    pipelines => gs.tilePipelines,
    projects => gs.tileProjects,
    groups => gs.tileGroups,
  };
}

/// Persists one account's Home tile order in [AppDatabase.homeTileOrders].
///
/// The row stores the tile ids as comma-separated enum names; decoding drops
/// ids this build no longer knows and appends tiles the stored order predates,
/// so the order stays total across app versions.
class HomeTileOrderStore {
  HomeTileOrderStore({required this.database, required this.account});

  final AppDatabase database;
  final AccountKey account;

  Stream<List<HomeTile>> watchOrder() {
    final query = database.select(database.homeTileOrders)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId),
      );
    return query.watchSingleOrNull().map((row) => _decode(row?.tileOrder));
  }

  Future<void> saveOrder(List<HomeTile> order) => database
      .into(database.homeTileOrders)
      .insertOnConflictUpdate(
        HomeTileOrdersCompanion.insert(
          instanceHost: account.instanceHost,
          accountId: account.accountId,
          tileOrder: order.map((tile) => tile.name).join(','),
          updatedAt: DateTime.now(),
        ),
      );

  static List<HomeTile> _decode(String? stored) {
    if (stored == null) return HomeTile.values;
    final byName = {for (final tile in HomeTile.values) tile.name: tile};
    final order = [for (final name in stored.split(',')) ?byName.remove(name)];
    return [...order, ...byName.values];
  }
}
