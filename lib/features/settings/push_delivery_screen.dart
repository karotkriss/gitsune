import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/icons/gs_icons.dart';
import '../../core/notifications/push_delivery.dart';
import '../../core/theme/app_theme.dart';

/// The E12.4 Android opt-in push settings surface (ADR 0002, layer 3). An
/// off-by-default switch enables the UnifiedPush path; once a distributor
/// issues an endpoint, the screen shows the exact GitLab webhook
/// configuration for the user to add to their own project or group. Gitsune
/// operates no server: it only generates this configuration.
class PushDeliveryScreen extends StatelessWidget {
  const PushDeliveryScreen({super.key, required this.controller});

  final PushDeliveryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
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
          'Android push',
          style: theme.textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final config = controller.webhookConfig;
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Instant push (UnifiedPush)'),
                subtitle: const Text(
                  'Advanced, opt-in. Deliver events near-instantly through a '
                  'push service you run, instead of the default polling.',
                ),
                value: controller.enabled,
                onChanged: (value) => controller.setEnabled(value),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Gitsune runs no server. You install a UnifiedPush '
                  'distributor (such as ntfy) and add a webhook to a GitLab '
                  'project or group you own; GitLab posts events to your '
                  'distributor, which forwards them here. This is per-project '
                  'and owner-configured. Baseline polling keeps running, and '
                  'quiet hours still applies.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: gs.textSubtle,
                  ),
                ),
              ),
              if (controller.enabled && config == null)
                _InfoPanel(
                  gs: gs,
                  text:
                      'Waiting for an endpoint. Install a UnifiedPush '
                      'distributor (such as ntfy), then reopen this screen.',
                ),
              if (controller.enabled && config != null)
                _WebhookConfigSection(gs: gs, theme: theme, config: config),
            ],
          );
        },
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.gs, required this.text});

  final GsTheme gs;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gs.feedbackInfoBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: gs.feedbackInfoText),
        ),
      ),
    );
  }
}

class _WebhookConfigSection extends StatelessWidget {
  const _WebhookConfigSection({
    required this.gs,
    required this.theme,
    required this.config,
  });

  final GsTheme gs;
  final ThemeData theme;
  final NtfyWebhookConfig config;

  @override
  Widget build(BuildContext context) {
    final headers = config.headers.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Add this webhook',
            style: theme.textTheme.titleSmall?.copyWith(color: gs.textHeading),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'In your GitLab project or group: Settings > Webhooks > Add new '
            'webhook. Paste each value below, enable the listed triggers, and '
            'save.',
            style: theme.textTheme.bodySmall?.copyWith(color: gs.textSubtle),
          ),
        ),
        _CopyField(gs: gs, label: 'URL', value: config.url.toString()),
        _CopyField(gs: gs, label: 'Custom headers', value: headers),
        _CopyField(
          gs: gs,
          label: 'Custom payload template',
          value: config.payloadTemplate,
          monospace: true,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Enable these triggers',
            style: theme.textTheme.labelLarge?.copyWith(color: gs.textDefault),
          ),
        ),
        for (final event in config.triggerEvents)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
            child: Text(
              '• $event',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: gs.textDefault,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// A labelled, read-only config value with a copy button, so the user can
/// transfer each field into GitLab's webhook form without retyping.
class _CopyField extends StatelessWidget {
  const _CopyField({
    required this.gs,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final GsTheme gs;
  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: gs.textSubtle),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: gs.codeBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: gs.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      value,
                      style: monospace
                          ? gs.mono
                          : theme.textTheme.bodyMedium?.copyWith(
                              color: gs.textDefault,
                            ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy $label',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$label copied')));
                  },
                  icon: GsIcon(
                    GsIconGlyph.copyToClipboard,
                    size: 18,
                    color: gs.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
