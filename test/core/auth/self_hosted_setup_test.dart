import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/auth/self_hosted_setup.dart';

import '../../support/oauth_errors.dart';

void main() {
  group('normalizeApplicationId', () {
    test('trims accidental surrounding whitespace off a paste', () {
      expect(
        normalizeApplicationId('  3a81e41d6dfc8fb4b4cadcfc2ef5fd69\n'),
        '3a81e41d6dfc8fb4b4cadcfc2ef5fd69',
      );
    });

    test('passes a clean Application ID through unchanged', () {
      expect(normalizeApplicationId('abc123'), 'abc123');
    });

    test('rejects an empty or whitespace-only paste', () {
      expect(
        () => normalizeApplicationId('   '),
        throwsA(
          isA<ApplicationIdException>().having(
            (e) => e.rejection,
            'rejection',
            ApplicationIdRejection.empty,
          ),
        ),
      );
    });

    test('rejects a pasted application secret (gloas- prefix)', () {
      expect(
        () => normalizeApplicationId('gloas-1234567890abcdef'),
        throwsA(
          isA<ApplicationIdException>().having(
            (e) => e.rejection,
            'rejection',
            ApplicationIdRejection.secretPasted,
          ),
        ),
      );
    });

    test('rejects a paste with interior whitespace', () {
      expect(
        () => normalizeApplicationId('Application ID: abc123'),
        throwsA(
          isA<ApplicationIdException>().having(
            (e) => e.rejection,
            'rejection',
            ApplicationIdRejection.malformed,
          ),
        ),
      );
    });
  });

  group('classifySelfHostedOAuthFailure', () {
    test('maps invalid_client (Confidential left checked, or a wrong '
        'Application ID) to confidentialClient', () {
      expect(
        classifySelfHostedOAuthFailure(
          tokenEndpointError('oauth_error_invalid_client'),
        ),
        SelfHostedOAuthFailure.confidentialClient,
      );
    });

    test('maps invalid_grant (redirect URI mismatch) to redirectMismatch', () {
      expect(
        classifySelfHostedOAuthFailure(
          tokenEndpointError('oauth_error_invalid_grant'),
        ),
        SelfHostedOAuthFailure.redirectMismatch,
      );
    });

    test('maps invalid_scope to scopeMismatch', () {
      expect(
        classifySelfHostedOAuthFailure(
          tokenEndpointError('oauth_error_invalid_scope'),
        ),
        SelfHostedOAuthFailure.scopeMismatch,
      );
    });

    test('maps a rejected code challenge (PKCE unsupported or too old) to '
        'pkceUnsupported', () {
      expect(
        classifySelfHostedOAuthFailure(
          tokenEndpointError('oauth_error_invalid_code_challenge_method'),
        ),
        SelfHostedOAuthFailure.pkceUnsupported,
      );
    });

    test('classifies the same wording relayed as a browser-leg exception '
        'message, not just token-endpoint JSON', () {
      expect(
        classifySelfHostedOAuthFailure(
          Exception(
            'PlatformException(authorize_failed, invalid_scope: The '
            'requested scope is invalid, unknown, or malformed.)',
          ),
        ),
        SelfHostedOAuthFailure.scopeMismatch,
      );
      expect(
        classifySelfHostedOAuthFailure(
          Exception('The redirect uri included is not valid.'),
        ),
        SelfHostedOAuthFailure.redirectMismatch,
      );
    });

    test('anything unrecognized stays unknown, never a wrong named case', () {
      expect(
        classifySelfHostedOAuthFailure(StateError('browser dismissed')),
        SelfHostedOAuthFailure.unknown,
      );
      expect(
        classifySelfHostedOAuthFailure(
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/oauth/token'),
            reason: 'network unreachable',
          ),
        ),
        SelfHostedOAuthFailure.unknown,
      );
    });
  });
}
