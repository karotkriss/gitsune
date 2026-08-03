import 'package:dio/dio.dart';

import '../network/account_key.dart';
import 'gitlab_oauth.dart';
import 'token_store.dart';

enum PatSignInFailure {
  insecureTransport,
  rejected,
  network,
  server,
  invalidResponse,
  storage,
}

class PatSignInException implements Exception {
  const PatSignInException(this.failure);

  final PatSignInFailure failure;
}

const patValidationTimeout = Duration(seconds: 10);

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
/// Throws [PatSignInException] and persists nothing when validation fails.
Future<SignedInAccount> signInWithPat({
  required Uri baseUrl,
  required String token,
  required TokenStore tokenStore,
  Dio? dio,
  Duration timeout = patValidationTimeout,
}) async {
  if (baseUrl.scheme != 'https') {
    throw const PatSignInException(PatSignInFailure.insecureTransport);
  }

  final client = dio ?? Dio();
  client.options.connectTimeout = timeout;
  client.options.receiveTimeout = timeout;
  late final Response<Map<String, dynamic>> response;
  try {
    response = await client.get<Map<String, dynamic>>(
      baseUrl.resolve('/api/v4/user').toString(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } on DioException catch (error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      throw const PatSignInException(PatSignInFailure.rejected);
    }
    if (status != null) {
      throw const PatSignInException(PatSignInFailure.server);
    }
    throw const PatSignInException(PatSignInFailure.network);
  }

  final id = response.data?['id'];
  if (id is! num) {
    throw const PatSignInException(PatSignInFailure.invalidResponse);
  }
  final account = AccountKey(
    instanceHost: baseUrl.authority,
    accountId: id.toString(),
  );
  final tokens = OAuthTokens(accessToken: token);
  try {
    await tokenStore.save(account, tokens);
  } catch (_) {
    throw const PatSignInException(PatSignInFailure.storage);
  }
  return (account: account, tokens: tokens);
}
