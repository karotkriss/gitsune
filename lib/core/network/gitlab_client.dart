import 'package:dio/dio.dart';

import 'account_key.dart';

/// Reads the current access token for [account]. Injected by E2.5's token
/// store; this layer only defines the seam.
typedef TokenReader = Future<String?> Function(AccountKey account);

/// Refreshes [account]'s token and returns the new access token, or `null`
/// if the refresh failed. Injected by E2.5's refresh logic; this layer only
/// defines the seam.
typedef TokenRefresher = Future<String?> Function(AccountKey account);

/// Resolves the REST v4 base URL for an account's own instance.
///
/// Fake-server tests point [createGitLabClient]'s `baseUrl` directly at the
/// server instead of using this resolver, since the fake server runs over
/// plain HTTP rather than HTTPS.
Uri resolveApiBaseUrl(AccountKey account) =>
    Uri.https(account.instanceHost, '/api/v4');

const _retriedAfter401 = 'gitsuneRetriedAfter401';

/// Builds a per-account `dio` client: base URL resolved from [account]'s
/// instance, with interceptor seams for token injection and a one-time 401
/// refresh-and-retry.
///
/// Only the seams live here; the real token store and refresh flow are
/// E2.5's job, injected via [readToken] and [refreshToken].
Dio createGitLabClient({
  required AccountKey account,
  required TokenReader readToken,
  required TokenRefresher refreshToken,
  Uri? baseUrl,
}) {
  final dio = Dio(
    BaseOptions(baseUrl: (baseUrl ?? resolveApiBaseUrl(account)).toString()),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // A 401 retry pre-sets Authorization with the refreshed token before
        // re-entering this interceptor; don't clobber it with the stale one.
        if (!options.headers.containsKey('Authorization')) {
          final token = await readToken(account);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final alreadyRetried =
            error.requestOptions.extra[_retriedAfter401] == true;
        if (error.response?.statusCode != 401 || alreadyRetried) {
          handler.next(error);
          return;
        }

        final newToken = await refreshToken(account);
        if (newToken == null) {
          handler.next(error);
          return;
        }

        final retryOptions = error.requestOptions
          ..extra[_retriedAfter401] = true
          ..headers['Authorization'] = 'Bearer $newToken';

        try {
          handler.resolve(await dio.fetch(retryOptions));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return dio;
}
