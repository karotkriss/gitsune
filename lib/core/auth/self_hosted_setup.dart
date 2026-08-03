/// Validation and failure classification for the self-hosted registration
/// wizard (E2.3), per `docs/research/auth-blueprint.md`.
///
/// The wizard accepts only an Application ID (public client, PKCE - never a
/// secret) and must map every named registration failure to actionable
/// guidance instead of a generic error; the pure logic for both lives here
/// so it stays unit-testable against fixture error bodies.
library;

import 'package:dio/dio.dart';

/// Why a pasted Application ID was rejected before any network use.
enum ApplicationIdRejection {
  /// Nothing was pasted.
  empty,

  /// The paste is the application *secret* (GitLab prefixes OAuth
  /// application secrets with `gloas-`), which Gitsune never needs.
  secretPasted,

  /// The paste contains interior whitespace, so it is more than just the
  /// Application ID value.
  malformed,
}

/// Thrown by [normalizeApplicationId] with the specific [rejection].
class ApplicationIdException implements Exception {
  const ApplicationIdException(this.rejection);

  final ApplicationIdRejection rejection;

  @override
  String toString() => 'ApplicationIdException(${rejection.name})';
}

/// Trims accidental surrounding whitespace off a pasted Application ID and
/// returns the cleaned value, or throws [ApplicationIdException] when the
/// paste cannot be an Application ID at all.
String normalizeApplicationId(String input) {
  final id = input.trim();
  if (id.isEmpty) {
    throw const ApplicationIdException(ApplicationIdRejection.empty);
  }
  if (id.startsWith('gloas-')) {
    throw const ApplicationIdException(ApplicationIdRejection.secretPasted);
  }
  if (id.contains(RegExp(r'\s'))) {
    throw const ApplicationIdException(ApplicationIdRejection.malformed);
  }
  return id;
}

/// The named ways a self-hosted OAuth sign-in attempt fails after
/// registration, from the wizard section of `docs/research/auth-blueprint.md`.
enum SelfHostedOAuthFailure {
  /// The instance predates PKCE support (or rejects the code challenge);
  /// OAuth cannot work there and the wizard degrades to the PAT path.
  pkceUnsupported,

  /// The application was registered without the scopes Gitsune requests.
  scopeMismatch,

  /// The registered redirect URI does not byte-match Gitsune's fixed one.
  redirectMismatch,

  /// The instance demanded client authentication: "Confidential" was left
  /// checked (or the Application ID does not name a known application).
  confidentialClient,

  /// Anything else - browser dismissed, network dropped, and so on.
  unknown,
}

/// Classifies an error thrown during a self-hosted sign-in attempt into the
/// named failure it represents.
///
/// GitLab reports these as OAuth error responses (Doorkeeper's `error` /
/// `error_description` JSON on the token endpoint, or the same wording
/// relayed through the browser leg's exception message), so classification
/// matches on those documented codes and phrases.
SelfHostedOAuthFailure classifySelfHostedOAuthFailure(Object error) {
  String text;
  if (error is DioException) {
    final data = error.response?.data;
    text = data is Map
        ? '${data['error']} ${data['error_description']}'
        : '$data ${error.message}';
  } else {
    text = error.toString();
  }
  text = text.toLowerCase();
  if (text.contains('code challenge') ||
      text.contains('code_challenge') ||
      text.contains('code_verifier')) {
    return SelfHostedOAuthFailure.pkceUnsupported;
  }
  if (text.contains('invalid_scope') ||
      text.contains('requested scope is invalid')) {
    return SelfHostedOAuthFailure.scopeMismatch;
  }
  if (text.contains('invalid_client') ||
      text.contains('client authentication failed')) {
    return SelfHostedOAuthFailure.confidentialClient;
  }
  // Covers Doorkeeper's explicit invalid-redirect wording and invalid_grant,
  // whose description names a redirection URI mismatch as the cause.
  if (text.contains('redirect') || text.contains('invalid_grant')) {
    return SelfHostedOAuthFailure.redirectMismatch;
  }
  return SelfHostedOAuthFailure.unknown;
}
