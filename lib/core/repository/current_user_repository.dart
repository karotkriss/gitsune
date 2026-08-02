import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/account_key.dart';
import 'offline_first_repository.dart';

/// The concrete proof of [OfflineFirstRepository]: the signed-in user's own
/// profile (`GET /api/v4/user`), account-scoped and cached as a single row
/// per account in [AppDatabase.currentUserProfiles].
class CurrentUserRepository
    implements OfflineFirstRepository<CurrentUserProfile?> {
  CurrentUserRepository({
    required this.database,
    required this.client,
    required this.account,
  });

  final AppDatabase database;
  final Dio client;
  final AccountKey account;

  @override
  Stream<CurrentUserProfile?> watch() {
    final query = database.select(database.currentUserProfiles)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId),
      );
    return query.watchSingleOrNull();
  }

  @override
  Future<void> refresh() async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await client.get<Map<String, dynamic>>('/user');
    } on DioException {
      return;
    }

    final data = response.data!;
    await database
        .into(database.currentUserProfiles)
        .insertOnConflictUpdate(
          CurrentUserProfilesCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            username: data['username'] as String,
            name: data['name'] as String,
            avatarUrl: Value(data['avatar_url'] as String?),
            updatedAt: DateTime.now(),
          ),
        );
  }
}
