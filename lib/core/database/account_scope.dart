import 'package:drift/drift.dart';

/// Adds the composite scope key that every database row carries: instance
/// host plus account identifier (see the "Account scoping is a composite
/// key" operating principle in `docs/plan/roadmap.md`).
///
/// Feature tables inherit this by declaring `with AccountScoped` and folding
/// [instanceHost] and [accountId] into their own primary key, rather than
/// re-implementing scope columns.
mixin AccountScoped on Table {
  TextColumn get instanceHost => text()();
  TextColumn get accountId => text()();
}
