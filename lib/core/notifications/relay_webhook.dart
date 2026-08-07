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

/// The Android opt-in delivery layer's destination (E12.4, ADR 0002's
/// Android layer): the UnifiedPush endpoint a distributor (such as ntfy)
/// issued for this device. Unlike [NtfyTarget], the topic is already baked
/// into [endpoint] by the distributor, and the forwarded body is parsed by
/// Gitsune itself rather than displayed by the relay's own app, so its
/// webhook configuration carries custom headers and trigger events that the
/// user-facing relay wizard (E12.5) never needs.
class UnifiedPushTarget extends RelayTarget {
  const UnifiedPushTarget({required this.endpoint});

  final Uri endpoint;
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

/// The GitLab webhook configuration a platform opt-in path outputs: the
/// webhook URL and the custom payload template ("Custom webhook template",
/// GitLab 16.10+) the user pastes into their project's webhook settings.
class RelayWebhookConfig {
  const RelayWebhookConfig({
    required this.url,
    required this.payloadTemplate,
    this.headers = const {},
    this.triggerEvents = const [],
  });

  final Uri url;

  /// A JSON template rendered by GitLab against the event payload.
  final String payloadTemplate;

  /// Custom headers to set on the GitLab webhook. Only [UnifiedPushTarget]
  /// (E12.4) needs these; the ntfy/Pushover relay wizard (E12.5) leaves this
  /// empty since it sets no custom headers.
  final Map<String, String> headers;

  /// The webhook trigger checkboxes to enable, as their GitLab UI labels.
  /// Only [UnifiedPushTarget] (E12.4) needs these; the relay wizard (E12.5)
  /// leaves this empty and recommends triggers in its own copy instead.
  final List<String> triggerEvents;
}

const _titleTemplate = '{{project.path_with_namespace}}';
const _messageTemplate = '{{object_kind}} update by {{user.name}}';

/// Builds the GitLab webhook configuration for [target].
///
/// This is the single webhook-config generator for every platform opt-in
/// path: the iOS relay wizard (E12.5, [NtfyTarget]/[PushoverTarget]) and the
/// Android UnifiedPush bridge (E12.4, [UnifiedPushTarget]) generate their
/// GitLab side through here. ntfy receives GitLab's rendered template via
/// its publish-as-JSON endpoint (the server root, with the topic in the
/// body); Pushover receives it as the JSON body of its messages API,
/// credentials included; the Android bridge posts to the UnifiedPush
/// endpoint the distributor issued, with the compact JSON
/// `PushDeliveryMessage.parse` reads on receipt.
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
    UnifiedPushTarget(:final endpoint) => RelayWebhookConfig(
      url: endpoint,
      headers: const {'Content-Type': 'application/json'},
      payloadTemplate:
          '{"title":"{{object_attributes.title}}",'
          '"body":"{{object_kind}} · {{project.path_with_namespace}}",'
          '"url":"{{object_attributes.url}}"}',
      triggerEvents: const [
        'Issues events',
        'Merge request events',
        'Comments',
      ],
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
///
/// Only meaningful for [NtfyTarget]/[PushoverTarget]: the relay wizard's
/// manual test-send. [UnifiedPushTarget] registration is verified by the
/// distributor's own endpoint callback instead, so it is never passed here.
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
    UnifiedPushTarget() => throw UnsupportedError(
      'sendRelayTestNotification is not used for UnifiedPushTarget; Android '
      'registration is verified by the distributor callback instead.',
    ),
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
