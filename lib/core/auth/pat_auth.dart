import 'package:dio/dio.dart';

import '../network/account_key.dart';
import 'gitlab_oauth.dart';
import 'token_store.dart';

/// Personal Access Token sign-in (E2.4), the fallback for instances where
/// OAuth application registration is impossible
/// (`docs/research/auth-blueprint.md`).
///
/// Validates the pasted token with a lightweight authenticated call
/// (`GET /api/v4/user`, the same call OAuth sign-in uses to resolve the
/// account), then persists it under the account's composite key. GitLab
/// accepts a PAT as a Bearer token, so storing it as the access token means
/// `createGitLabClient` sends it unchanged. It is stored without a refresh
/// token or expiry, so per the blueprint a later 401 surfaces as an
/// authentication failure ("re-enter your token") instead of a refresh.
///
/// Throws (a [DioException] for a rejected or unreachable token check) and
/// persists nothing when validation fails.
Future<SignedInAccount> signInWithPat({
  required Uri baseUrl,
  required String token,
  required TokenStore tokenStore,
  Dio? dio,
}) async {
  final response = await (dio ?? Dio()).get<Map<String, dynamic>>(
    baseUrl.resolve('/api/v4/user').toString(),
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  final account = AccountKey(
    instanceHost: baseUrl.authority,
    accountId: (response.data!['id'] as num).toString(),
  );
  final tokens = OAuthTokens(accessToken: token);
  await tokenStore.save(account, tokens);
  return (account: account, tokens: tokens);
}
