import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/pat_auth.dart';
import 'package:gitsune/core/auth/token_store.dart';
import 'package:gitsune/core/network/account_key.dart';

Dio _stubDio(
  void Function(RequestOptions, RequestInterceptorHandler) onRequest,
) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}

class _MemoryTokenStore implements TokenStore {
  final tokens = <AccountKey, OAuthTokens>{};

  @override
  Future<void> save(AccountKey account, OAuthTokens tokens) async =>
      this.tokens[account] = tokens;

  @override
  Future<OAuthTokens?> read(AccountKey account) async => tokens[account];

  @override
  Future<void> clear(AccountKey account) async => tokens.remove(account);
}

void main() {
  test('a valid token is checked with GET /user and stored under the '
      'account composite key without refresh token or expiry', () async {
    late RequestOptions request;
    final dio = _stubDio((options, handler) {
      request = options;
      handler.resolve(
        Response(
          requestOptions: options,
          data: {'id': 42, 'username': 'alice'},
          statusCode: 200,
        ),
      );
    });
    final store = _MemoryTokenStore();
    final baseUrl = Uri.parse('https://gitlab.example.com');

    final session = await signInWithPat(
      baseUrl: baseUrl,
      token: 'glpat-abc123',
      tokenStore: store,
      dio: dio,
    );

    expect(request.uri.toString(), 'https://gitlab.example.com/api/v4/user');
    expect(request.headers['Authorization'], 'Bearer glpat-abc123');
    expect(dio.options.connectTimeout, patValidationTimeout);
    expect(dio.options.receiveTimeout, patValidationTimeout);
    final account = AccountKey(
      instanceHost: baseUrl.authority,
      accountId: '42',
    );
    expect(session.account, account);
    final stored = store.tokens[account]!;
    expect(stored.accessToken, 'glpat-abc123');
    // A PAT never refreshes: a later 401 must surface as re-enter-token.
    expect(stored.refreshToken, isNull);
    expect(stored.expiresAt, isNull);
  });

  test('a rejected token throws and persists nothing', () async {
    final dio = _stubDio((request, handler) {
      handler.reject(
        DioException.badResponse(
          statusCode: 401,
          requestOptions: request,
          response: Response(requestOptions: request, statusCode: 401),
        ),
      );
    });
    final store = _MemoryTokenStore();

    final attempt = signInWithPat(
      baseUrl: Uri.parse('https://gitlab.example.com'),
      token: 'glpat-wrong',
      tokenStore: store,
      dio: dio,
    );

    await expectLater(
      attempt,
      throwsA(
        isA<PatSignInException>().having(
          (error) => error.failure,
          'failure',
          PatSignInFailure.rejected,
        ),
      ),
    );
    expect(store.tokens, isEmpty);
  });

  test('an HTTP instance is refused before the token is sent', () async {
    var requested = false;
    final dio = _stubDio((_, _) {
      requested = true;
    });

    final attempt = signInWithPat(
      baseUrl: Uri.parse('http://gitlab.example.com'),
      token: 'glpat-secret',
      tokenStore: _MemoryTokenStore(),
      dio: dio,
    );

    await expectLater(
      attempt,
      throwsA(
        isA<PatSignInException>().having(
          (error) => error.failure,
          'failure',
          PatSignInFailure.insecureTransport,
        ),
      ),
    );
    expect(requested, isFalse);
  });

  test(
    'a stalled validation is bounded and classified as a network error',
    () async {
      final dio = _stubDio((request, handler) {
        handler.reject(
          DioException(
            requestOptions: request,
            type: DioExceptionType.receiveTimeout,
          ),
        );
      });

      final attempt = signInWithPat(
        baseUrl: Uri.parse('https://gitlab.example.com'),
        token: 'glpat-abc123',
        tokenStore: _MemoryTokenStore(),
        dio: dio,
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        attempt,
        throwsA(
          isA<PatSignInException>().having(
            (error) => error.failure,
            'failure',
            PatSignInFailure.network,
          ),
        ),
      );
      expect(dio.options.connectTimeout, const Duration(milliseconds: 50));
      expect(dio.options.receiveTimeout, const Duration(milliseconds: 50));
    },
  );
}
