import 'package:flutter/material.dart';

import '../../core/icons/gs_icons.dart';
import '../../core/notifications/quiet_hours.dart';
import '../../core/theme/app_theme.dart';

/// The E12.2 quiet-hours settings surface: an enable switch plus start and
/// end times for the daily window during which new-to-do notifications are
/// suppressed. A start later than the end wraps past midnight.
class QuietHoursScreen extends StatefulWidget {
  const QuietHoursScreen({super.key, required this.store});

  final QuietHoursStore store;

  @override
  State<QuietHoursScreen> createState() => _QuietHoursScreenState();
}

class _QuietHoursScreenState extends State<QuietHoursScreen> {
  QuietHours? _settings;

  @override
  void initState() {
    super.initState();
    widget.store.read().then((settings) {
      if (mounted) setState(() => _settings = settings);
    });
  }

  Future<void> _update(QuietHours settings) async {
    setState(() => _settings = settings);
    await widget.store.save(settings);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final settings = _settings!;
    final minutes = isStart ? settings.startMinutes : settings.endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      helpText: isStart ? 'Quiet from' : 'Quiet until',
    );
    if (picked == null) return;
    final pickedMinutes = picked.hour * 60 + picked.minute;
    await _update(
      isStart
          ? settings.copyWith(startMinutes: pickedMinutes)
          : settings.copyWith(endMinutes: pickedMinutes),
    );
  }

  String _format(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final settings = _settings;
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
          'Quiet hours',
          style: theme.textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
      ),
      body: settings == null
          ? const SizedBox.shrink()
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Quiet hours'),
                  subtitle: const Text(
                    'Suppress notifications during the scheduled window',
                  ),
                  value: settings.enabled,
                  onChanged: (enabled) =>
                      _update(settings.copyWith(enabled: enabled)),
                ),
                ListTile(
                  title: const Text('Start'),
                  trailing: Text(
                    _format(settings.startMinutes),
                    style: theme.textTheme.bodyMedium,
                  ),
                  enabled: settings.enabled,
                  onTap: () => _pickTime(isStart: true),
                ),
                ListTile(
                  title: const Text('End'),
                  trailing: Text(
                    _format(settings.endMinutes),
                    style: theme.textTheme.bodyMedium,
                  ),
                  enabled: settings.enabled,
                  onTap: () => _pickTime(isStart: false),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'A window that ends before it starts spans midnight. '
                    'Polling continues during quiet hours, so the To-Do '
                    'List stays up to date.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: gs.textSubtle,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
