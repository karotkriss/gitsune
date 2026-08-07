import 'dart:convert';

import 'package:dio/dio.dart';

import '../auth/gitlab_instance.dart';
import '../network/connectivity.dart';

/// The user-controlled relay services the opt-in wizard (E12.5, ADR 0002's
/// iOS layer) can configure. The relay is operated by the service the user
/// chose and authorized - never by this project, which runs no notification
/// servers of any kind.
enum RelayService { ntfy, pushover }

/// A validated relay destination: everything needed to send it one message,
/// whether by GitLab's webhook executor or by the wizard's test send.
sealed class RelayTarget {
  const RelayTarget();
}

class NtfyTarget extends RelayTarget {
  const NtfyTarget({required this.server, required this.topic});

  /// Host-level ntfy server base URL: the public `https://ntfy.sh` or the
  /// user's self-hosted server.
  final Uri server;

  final String topic;
}

class PushoverTarget extends RelayTarget {
  const PushoverTarget({required this.appToken, required this.userKey});

  /// The API token of a Pushover application the user created themselves.
  final String appToken;

  final String userKey;
}

/// Why a wizard input could not become part of a [RelayTarget].
enum RelayInputRejection {
  emptyServer,
  malformedServer,
  emptyTopic,
  malformedTopic,
  emptyAppToken,
  malformedAppToken,
  emptyUserKey,
  malformedUserKey,
}

class RelayInputException implements Exception {
  const RelayInputException(this.rejection);

  final RelayInputRejection rejection;
}

/// ntfy topic names: letters, digits, `-` and `_`, up to 64 characters.
final _ntfyTopicPattern = RegExp(r'^[-_A-Za-z0-9]{1,64}$');

/// Pushover API tokens and user keys are 30 case-sensitive alphanumerics.
final _pushoverKeyPattern = RegExp(r'^[A-Za-z0-9]{30}$');

/// Parses the wizard's ntfy inputs, throwing [RelayInputException] with the
/// specific rejection when a value cannot work. The server address accepts
/// the same forms as instance entry ("ntfy.sh", "https://ntfy.example.com")
/// and, unlike GitLab instance entry, keeps any URL subpath so a
/// self-hosted ntfy under a subpath ("https://example.com/ntfy/") is
/// published to correctly.
NtfyTarget parseNtfyTarget({required String server, required String topic}) {
  final serverText = server.trim();
  if (serverText.isEmpty) {
    throw const RelayInputException(RelayInputRejection.emptyServer);
  }
  final base = parseInstanceUrl(serverText);
  if (base == null) {
    throw const RelayInputException(RelayInputRejection.malformedServer);
  }
  final withPath = base.replace(
    path: Uri.parse(
      serverText.contains('://') ? serverText : 'https://$serverText',
    ).path,
  );
  final topicText = topic.trim();
  if (topicText.isEmpty) {
    throw const RelayInputException(RelayInputRejection.emptyTopic);
  }
  if (!_ntfyTopicPattern.hasMatch(topicText)) {
    throw const RelayInputException(RelayInputRejection.malformedTopic);
  }
  return NtfyTarget(server: withPath, topic: topicText);
}

/// Parses the wizard's Pushover inputs, throwing [RelayInputException] with
/// the specific rejection when a value cannot work.
PushoverTarget parsePushoverTarget({
  required String appToken,
  required String userKey,
}) {
  final tokenText = appToken.trim();
  if (tokenText.isEmpty) {
    throw const RelayInputException(RelayInputRejection.emptyAppToken);
  }
  if (!_pushoverKeyPattern.hasMatch(tokenText)) {
    throw const RelayInputException(RelayInputRejection.malformedAppToken);
  }
  final userText = userKey.trim();
  if (userText.isEmpty) {
    throw const RelayInputException(RelayInputRejection.emptyUserKey);
  }
  if (!_pushoverKeyPattern.hasMatch(userText)) {
    throw const RelayInputException(RelayInputRejection.malformedUserKey);
  }
  return PushoverTarget(appToken: tokenText, userKey: userText);
}

/// The GitLab webhook configuration the wizard outputs: the webhook URL and
/// the custom payload template ("Custom webhook template", GitLab 16.10+)
/// the user pastes into their project's webhook settings.
class RelayWebhookConfig {
  const RelayWebhookConfig({required this.url, required this.payloadTemplate});

  final Uri url;

  /// A JSON template rendered by GitLab against the event payload. Its
  /// `{{...}}` fields are common to issue, merge request, note, and pipeline
  /// events, which are the triggers the wizard recommends enabling.
  final String payloadTemplate;
}

const _titleTemplate = '{{project.path_with_namespace}}';
const _messageTemplate = '{{object_kind}} update by {{user.name}}';

/// Builds the GitLab webhook configuration for [target].
///
/// This is the single webhook-config generator for both platform opt-in
/// paths: the iOS relay wizard (E12.5) and the Android webhook-to-ntfy
/// bridge (E12.4) generate their GitLab side through here. ntfy receives
/// GitLab's rendered template via its publish-as-JSON endpoint (the server
/// root, with the topic in the body); Pushover receives it as the JSON body
/// of its messages API, credentials included, so neither needs anything
/// beyond a plain webhook with a custom payload template.
RelayWebhookConfig buildRelayWebhookConfig(RelayTarget target) {
  const encoder = JsonEncoder.withIndent('  ');
  return switch (target) {
    NtfyTarget(:final server, :final topic) => RelayWebhookConfig(
      url: server,
      payloadTemplate: encoder.convert({
        'topic': topic,
        'title': _titleTemplate,
        'message': _messageTemplate,
      }),
    ),
    PushoverTarget(:final appToken, :final userKey) => RelayWebhookConfig(
      url: Uri.https('api.pushover.net', '/1/messages.json'),
      payloadTemplate: encoder.convert({
        'token': appToken,
        'user': userKey,
        'title': _titleTemplate,
        'message': _messageTemplate,
      }),
    ),
  };
}

/// How a relay test send failed, mapped to the wizard's named error states.
enum RelayTestFailure {
  /// The relay was never reached: bad address, DNS failure, or no network.
  unreachable,

  /// The relay answered 4xx: a bad topic, token, or user key.
  rejected,

  /// The relay answered something else entirely.
  unexpected,
}

class RelayTestException implements Exception {
  const RelayTestException(this.failure);

  final RelayTestFailure failure;
}

/// Sends one test notification from this device to [target]'s relay, using
/// the same endpoint and body shape the generated webhook configuration
/// makes GitLab send, so a passing test proves both the credentials and the
/// payload shape. Throws [RelayTestException] on failure.
///
/// [url] overrides the destination (loopback in tests); the default is
/// exactly [buildRelayWebhookConfig]'s URL.
Future<void> sendRelayTestNotification(
  RelayTarget target, {
  Dio? dio,
  Uri? url,
}) async {
  final client =
      dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
  const title = 'Gitsune';
  const message = 'Test notification from Gitsune';
  final body = switch (target) {
    NtfyTarget(:final topic) => {
      'topic': topic,
      'title': title,
      'message': message,
    },
    PushoverTarget(:final appToken, :final userKey) => {
      'token': appToken,
      'user': userKey,
      'title': title,
      'message': message,
    },
  };
  final Response<void> response;
  try {
    response = await client.post<void>(
      (url ?? buildRelayWebhookConfig(target).url).toString(),
      data: body,
      options: Options(validateStatus: (_) => true),
    );
  } on DioException catch (error) {
    throw RelayTestException(
      isConnectivityError(error)
          ? RelayTestFailure.unreachable
          : RelayTestFailure.unexpected,
    );
  }
  final status = response.statusCode ?? 0;
  if (status >= 200 && status < 300) return;
  throw RelayTestException(
    status >= 400 && status < 500
        ? RelayTestFailure.rejected
        : RelayTestFailure.unexpected,
  );
}
