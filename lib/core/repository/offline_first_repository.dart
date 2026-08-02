/// The seam every offline-first repository follows: the UI reads a reactive
/// database stream via [watch]; [refresh] fetches from the network and
/// writes through to the database in the background, causing that stream to
/// re-emit (stale-while-revalidate).
///
/// See the "Offline-first through the repository layer" operating principle
/// in `docs/plan/roadmap.md`. This is intentionally not a framework: each
/// feature repository (issues, MRs, todos, ...) implements these two methods
/// itself, against whatever query and endpoint shape fits its entity.
abstract class OfflineFirstRepository<T> {
  /// The reactive database read the UI subscribes to.
  Stream<T> watch();

  /// Fetches from the network and writes through to the database. A network
  /// failure is swallowed here rather than rethrown, so [watch] keeps
  /// serving the last cached value instead of the UI seeing an error.
  Future<void> refresh();
}
