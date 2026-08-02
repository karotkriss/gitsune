/// The composite key that scopes a network client to one account: instance
/// host plus account identifier (see the "Account scoping is a composite
/// key" operating principle in `docs/plan/roadmap.md`).
///
/// Mirrors the same two fields as `core/database/account_scope.dart`'s
/// `AccountScoped` mixin, but as a plain value type rather than a Drift table
/// mixin, since the network client isn't a database row.
class AccountKey {
  const AccountKey({required this.instanceHost, required this.accountId});

  final String instanceHost;
  final String accountId;

  @override
  bool operator ==(Object other) =>
      other is AccountKey &&
      other.instanceHost == instanceHost &&
      other.accountId == accountId;

  @override
  int get hashCode => Object.hash(instanceHost, accountId);

  @override
  String toString() => '$accountId@$instanceHost';
}
