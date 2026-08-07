import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icons/gs_icons.dart';
import '../theme/app_theme.dart';

/// A read-only value the user must transcribe exactly, with a copy button.
/// Wizard screens (E2.3 self-hosted setup, E12.5 relay setup) use this for
/// the values a user carries into an external configuration page.
class GsCopyableValue extends StatelessWidget {
  const GsCopyableValue(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(value, style: gs.mono.copyWith(fontSize: 13))),
          IconButton(
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Copied')));
            },
            icon: GsIcon(
              GsIconGlyph.copyToClipboard,
              size: 16,
              color: gs.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
