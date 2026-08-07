import 'package:flutter/material.dart';

import '../../core/icons/gs_icons.dart';
import '../../core/notifications/relay_setup.dart';
import '../../core/notifications/relay_webhook.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/copyable_value.dart';

/// The opt-in relay wizard (E12.5, ADR 0002's iOS layer): connects a relay
/// the user controls - their own ntfy topic or Pushover application - and
/// generates the GitLab webhook configuration that sends events straight
/// from their instance to that relay. Gitsune only guides the setup; it
/// never hosts or proxies notifications, and the baseline poller (E12.1)
/// stays the default delivery layer either way.
///
/// The wizard steps render only while the opt-in switch is on, making the
/// switch mean "show me this path": delivery itself is controlled by the
/// webhook in GitLab, which the app never touches, so turning the switch
/// off hides the setup rather than stopping an already-configured webhook
/// (the step-4 copy tells the user where delivery is actually controlled).
class RelayWizardScreen extends StatefulWidget {
  const RelayWizardScreen({super.key, required this.store, this.sendTest});

  final RelaySetupStore store;

  /// Sends the step-3 test notification. Injectable so tests never reach a
  /// live relay; defaults to [sendRelayTestNotification].
  final Future<void> Function(RelayTarget target)? sendTest;

  @override
  State<RelayWizardScreen> createState() => _RelayWizardScreenState();
}

class _RelayWizardScreenState extends State<RelayWizardScreen> {
  final _serverController = TextEditingController();
  final _topicController = TextEditingController();
  final _tokenController = TextEditingController();
  final _userKeyController = TextEditingController();

  RelaySetup? _setup;
  String? _serverError;
  String? _topicError;
  String? _tokenError;
  String? _userKeyError;
  bool _sendingTest = false;
  bool _testSent = false;
  String? _testError;

  @override
  void initState() {
    super.initState();
    widget.store.read().then((setup) {
      if (!mounted) return;
      _serverController.text = setup.ntfyServer;
      _topicController.text = setup.ntfyTopic;
      _tokenController.text = setup.pushoverAppToken;
      _userKeyController.text = setup.pushoverUserKey;
      setState(() => _setup = setup);
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _topicController.dispose();
    _tokenController.dispose();
    _userKeyController.dispose();
    super.dispose();
  }

  Future<void> _update(RelaySetup setup) async {
    setState(() => _setup = setup);
    await widget.store.save(setup);
  }

  /// A details change invalidates the previous test result and any stale
  /// field error alongside the persisted value.
  void _onDetailsChanged(RelaySetup setup) {
    _testSent = false;
    _testError = null;
    _update(setup);
  }

  String get _serviceName =>
      _setup!.service == RelayService.ntfy ? 'ntfy' : 'Pushover';

  /// The current inputs as a validated target, or null without touching any
  /// error state - build-time use for the generated-configuration step.
  RelayTarget? _targetOrNull() {
    final setup = _setup!;
    try {
      return switch (setup.service) {
        RelayService.ntfy => parseNtfyTarget(
          server: setup.ntfyServer,
          topic: setup.ntfyTopic,
        ),
        RelayService.pushover => parsePushoverTarget(
          appToken: setup.pushoverAppToken,
          userKey: setup.pushoverUserKey,
        ),
      };
    } on RelayInputException {
      return null;
    }
  }

  /// Like [_targetOrNull], but surfaces the specific rejection under the
  /// offending field - button-press use.
  RelayTarget? _validateTarget() {
    try {
      return switch (_setup!.service) {
        RelayService.ntfy => parseNtfyTarget(
          server: _setup!.ntfyServer,
          topic: _setup!.ntfyTopic,
        ),
        RelayService.pushover => parsePushoverTarget(
          appToken: _setup!.pushoverAppToken,
          userKey: _setup!.pushoverUserKey,
        ),
      };
    } on RelayInputException catch (error) {
      setState(() {
        switch (error.rejection) {
          case RelayInputRejection.emptyServer:
            _serverError = 'Enter your ntfy server address.';
          case RelayInputRejection.malformedServer:
            _serverError =
                'That does not look like a server address. '
                'Enter a host like ntfy.sh or https://ntfy.example.com.';
          case RelayInputRejection.emptyTopic:
            _topicError = 'Enter your ntfy topic name.';
          case RelayInputRejection.malformedTopic:
            _topicError =
                'Topic names use only letters, digits, - and _, '
                'up to 64 characters.';
          case RelayInputRejection.emptyAppToken:
            _tokenError =
                'Paste the API token of the Pushover application '
                'you created.';
          case RelayInputRejection.malformedAppToken:
            _tokenError =
                'That does not look like a Pushover API token - '
                'it is 30 letters and digits.';
          case RelayInputRejection.emptyUserKey:
            _userKeyError = 'Paste your Pushover user key.';
          case RelayInputRejection.malformedUserKey:
            _userKeyError =
                'That does not look like a Pushover user key - '
                'it is 30 letters and digits.';
        }
      });
      return null;
    }
  }

  Future<void> _sendTest() async {
    if (_sendingTest) return;
    final target = _validateTarget();
    if (target == null) return;
    setState(() {
      _sendingTest = true;
      _testSent = false;
      _testError = null;
    });
    final host = switch (target) {
      NtfyTarget(:final server) => server.host,
      PushoverTarget() => 'api.pushover.net',
      UnifiedPushTarget() => throw StateError(
        'unreachable: _validateTarget only returns NtfyTarget/PushoverTarget',
      ),
    };
    try {
      await (widget.sendTest ?? sendRelayTestNotification)(target);
      if (mounted) {
        setState(() {
          _sendingTest = false;
          _testSent = true;
        });
      }
    } on RelayTestException catch (error) {
      if (!mounted) return;
      setState(() {
        _sendingTest = false;
        _testError = switch (error.failure) {
          RelayTestFailure.unreachable =>
            'Could not reach $host. Check the server address and your '
                'connection, then try again.',
          RelayTestFailure.rejected =>
            _setup!.service == RelayService.ntfy
                ? '$host rejected the topic. Check the topic name, and '
                      'whether the topic is protected and needs an access '
                      'token.'
                : 'Pushover rejected the credentials. Check the application '
                      'API token and your user key in the Pushover '
                      'dashboard.',
          RelayTestFailure.unexpected =>
            '$host responded unexpectedly. Try again in a moment.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sendingTest = false;
        _testError = 'Sending the test notification failed. Try again.';
      });
    }
  }

  TextField _detailField({
    required Key key,
    required TextEditingController controller,
    required String hint,
    required String helper,
    required String? error,
    required void Function(String value) onChanged,
  }) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return TextField(
      key: key,
      controller: controller,
      enabled: !_sendingTest,
      style: gs.mono.copyWith(fontSize: 15),
      autocorrect: false,
      enableSuggestions: false,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        helperText: helper,
        helperMaxLines: 3,
        errorText: error,
        errorMaxLines: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final setup = _setup;
    final stepStyle = theme.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w600,
      fontVariations: const [FontVariation('wght', 600)],
      color: gs.textHeading,
    );
    final bodyStyle = theme.textTheme.bodyMedium!.copyWith(
      color: gs.textSubtle,
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: gs.surfaceApp,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: Navigator.of(context).pop,
                icon: GsIcon(
                  GsIconGlyph.chevronLeft,
                  size: 20,
                  color: gs.accent,
                ),
              )
            : null,
        title: Text(
          'Instant notifications',
          style: theme.textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
      ),
      body: setup == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      key: const ValueKey('relay-enabled-switch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Relay notifications'),
                      subtitle: const Text(
                        'Off by default. The built-in poller keeps '
                        'notifying either way.',
                      ),
                      value: setup.enabled,
                      onChanged: (enabled) =>
                          _update(setup.copyWith(enabled: enabled)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      child: Text(
                        'iOS only delivers instant push through a server, '
                        'and Gitsune never operates one. This wizard '
                        'connects a relay you control - your own ntfy topic '
                        'or Pushover application - and generates the GitLab '
                        'webhook configuration that sends events straight '
                        'from your instance to that relay. Gitsune never '
                        'sees or forwards these notifications.',
                        style: bodyStyle,
                      ),
                    ),
                    if (setup.enabled) ...[
                      Text('1. Choose your relay service', style: stepStyle),
                      const SizedBox(height: 12),
                      SegmentedButton<RelayService>(
                        segments: const [
                          ButtonSegment(
                            value: RelayService.ntfy,
                            label: Text('ntfy'),
                          ),
                          ButtonSegment(
                            value: RelayService.pushover,
                            label: Text('Pushover'),
                          ),
                        ],
                        selected: {setup.service},
                        onSelectionChanged: (selection) {
                          _serverError = null;
                          _topicError = null;
                          _tokenError = null;
                          _userKeyError = null;
                          _onDetailsChanged(
                            setup.copyWith(service: selection.single),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '2. Enter your $_serviceName details',
                        style: stepStyle,
                      ),
                      const SizedBox(height: 6),
                      if (setup.service == RelayService.ntfy) ...[
                        Text(
                          'Install the ntfy app on this device and subscribe '
                          'it to a topic of your choice. A topic is public to '
                          'anyone who knows its name, so pick one that is '
                          'hard to guess.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        _detailField(
                          key: const ValueKey('relay-ntfy-server'),
                          controller: _serverController,
                          hint: 'Server',
                          helper:
                              'The public ntfy.sh or your own self-hosted '
                              'ntfy server.',
                          error: _serverError,
                          onChanged: (value) {
                            _serverError = null;
                            _onDetailsChanged(
                              setup.copyWith(ntfyServer: value),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _detailField(
                          key: const ValueKey('relay-ntfy-topic'),
                          controller: _topicController,
                          hint: 'Topic',
                          helper:
                              'The topic the ntfy app on this device is '
                              'subscribed to.',
                          error: _topicError,
                          onChanged: (value) {
                            _topicError = null;
                            _onDetailsChanged(setup.copyWith(ntfyTopic: value));
                          },
                        ),
                      ] else ...[
                        Text(
                          'Install the Pushover app on this device, then '
                          'create an application for Gitsune at '
                          'pushover.net/apps - its API token plus your user '
                          'key are all this path needs.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        _detailField(
                          key: const ValueKey('relay-pushover-token'),
                          controller: _tokenController,
                          hint: 'Application API token',
                          helper:
                              'From the application you created at '
                              'pushover.net/apps.',
                          error: _tokenError,
                          onChanged: (value) {
                            _tokenError = null;
                            _onDetailsChanged(
                              setup.copyWith(pushoverAppToken: value),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _detailField(
                          key: const ValueKey('relay-pushover-user'),
                          controller: _userKeyController,
                          hint: 'User key',
                          helper: 'Shown on your Pushover dashboard.',
                          error: _userKeyError,
                          onChanged: (value) {
                            _userKeyError = null;
                            _onDetailsChanged(
                              setup.copyWith(pushoverUserKey: value),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('3. Send a test notification', style: stepStyle),
                      const SizedBox(height: 6),
                      Text(
                        'Confirms these details reach your relay, using the '
                        'same request shape GitLab will send.',
                        style: bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        key: const ValueKey('relay-test-button'),
                        onPressed: _sendingTest ? null : _sendTest,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _sendingTest
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send test notification'),
                      ),
                      if (_testSent)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              GsIcon(
                                GsIconGlyph.checkCircle,
                                size: 16,
                                color: gs.textSuccess,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sent. Check the $_serviceName app on this '
                                  'device.',
                                  style: bodyStyle.copyWith(
                                    color: gs.textSuccess,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_testError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _testError!,
                            style: bodyStyle.copyWith(color: gs.textDanger),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text('4. Add the webhook to GitLab', style: stepStyle),
                      const SizedBox(height: 6),
                      ..._webhookStep(bodyStyle),
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          'Relay notifications are delivered by the '
                          '$_serviceName app, so quiet hours in Gitsune apply '
                          'only to its built-in notifications - use your '
                          'relay app\'s own quiet or do-not-disturb settings '
                          'for this path.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gs.textSubtle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _webhookStep(TextStyle bodyStyle) {
    final target = _targetOrNull();
    if (target == null) {
      return [
        Text(
          'Finish step 2 to generate the webhook configuration.',
          style: bodyStyle,
        ),
      ];
    }
    final config = buildRelayWebhookConfig(target);
    return [
      Text(
        'In each project you want notifications from, open '
        'Settings > Webhooks on your GitLab instance and add a webhook '
        'with this URL:',
        style: bodyStyle,
      ),
      const SizedBox(height: 8),
      GsCopyableValue(config.url.toString()),
      const SizedBox(height: 12),
      Text(
        'Paste this into the "Custom webhook template" field '
        '(GitLab 16.10 or later):',
        style: bodyStyle,
      ),
      const SizedBox(height: 8),
      GsCopyableValue(config.payloadTemplate),
      const SizedBox(height: 12),
      Text(
        'Enable the issue, merge request, comment, and pipeline event '
        'triggers - the template covers all four. Then use the webhook\'s '
        'Test button on GitLab: a failed delivery under Recent events '
        'means the webhook is misconfigured, so re-copy both values '
        'exactly.',
        style: bodyStyle,
      ),
    ];
  }
}
