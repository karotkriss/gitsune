import 'package:dio/dio.dart';

import 'account_key.dart';

class TokenReadResult {
  const TokenReadResult(this.accessToken, {this.refreshAttempted = false});

  final String? accessToken;
  final bool refreshAttempted;
}

/// Reads the current access token for [account], including any lazy refresh.
/// Implemented by `core/auth/token_refresh.dart`.
typedef TokenReader = Future<TokenReadResult> Function(AccountKey account);

/// Refreshes [account]'s token and returns the new access token, or `null`
/// if the refresh failed. `rejectedAccessToken` is the bearer token the
/// 401'd request carried, letting the refresher skip the refresh when a
/// concurrent one already rotated past it (GitLab refresh tokens are
/// single-use). Implemented by `core/auth/token_refresh.dart`.
typedef TokenRefresher =
    Future<String?> Function(AccountKey account, String? rejectedAccessToken);

/// Resolves the REST v4 base URL for an account's own instance.
///
/// Fake-server tests point [createGitLabClient]'s `baseUrl` directly at the
/// server instead of using this resolver, since the fake server runs over
/// plain HTTP rather than HTTPS.
Uri resolveApiBaseUrl(AccountKey account) =>
    Uri.https(account.instanceHost, '/api/v4');

const _retriedAfter401 = 'gitsuneRetriedAfter401';
const _refreshedBeforeRequest = 'gitsuneRefreshedBeforeRequest';
const _authorizationHeader = 'Authorization';

bool _hasAuthorizationHeader(Map<String, dynamic> headers) => headers.keys.any(
  (header) => header.toLowerCase() == _authorizationHeader.toLowerCase(),
);

String? _bearerToken(Map<String, dynamic> headers) {
  for (final entry in headers.entries) {
    if (entry.key.toLowerCase() == _authorizationHeader.toLowerCase()) {
      final value = entry.value.toString();
      const prefix = 'Bearer ';
      return value.startsWith(prefix) ? value.substring(prefix.length) : null;
    }
  }
  return null;
}

void _setBearerToken(Map<String, dynamic> headers, String token) {
  headers.removeWhere(
    (header, _) => header.toLowerCase() == _authorizationHeader.toLowerCase(),
  );
  headers[_authorizationHeader] = 'Bearer $token';
}

/// Builds a per-account `dio` client: base URL resolved from [account]'s
/// instance, with interceptor seams for token injection and a one-time 401
/// refresh-and-retry.
///
/// Token storage and refresh live in `core/auth/` and are injected via
/// [readToken] and [refreshToken].
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
        if (!_hasAuthorizationHeader(options.headers)) {
          final result = await readToken(account);
          if (result.refreshAttempted) {
            options.extra[_refreshedBeforeRequest] = true;
          }
          if (result.accessToken != null) {
            _setBearerToken(options.headers, result.accessToken!);
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final alreadyRetried =
            error.requestOptions.extra[_retriedAfter401] == true ||
            error.requestOptions.extra[_refreshedBeforeRequest] == true;
        if (error.response?.statusCode != 401 || alreadyRetried) {
          handler.next(error);
          return;
        }

        final requestOptions = error.requestOptions;
        if (requestOptions.data is Stream) {
          handler.next(error);
          return;
        }

        final newToken = await refreshToken(
          account,
          _bearerToken(requestOptions.headers),
        );
        if (newToken == null) {
          handler.next(error);
          return;
        }

        final retryHeaders = Map<String, dynamic>.from(requestOptions.headers);
        _setBearerToken(retryHeaders, newToken);
        final requestData = requestOptions.data;
        final retryOptions = requestOptions.copyWith(
          data: requestData is FormData ? requestData.clone() : requestData,
          extra: {...requestOptions.extra, _retriedAfter401: true},
          headers: retryHeaders,
        );

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
