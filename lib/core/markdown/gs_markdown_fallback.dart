import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Renders [source] as a plain code block.
///
/// Shared degrade path for math and Mermaid blocks that fail to render: never
/// throws, never blanks, just falls back to the raw authored text.
Widget gsRawSourceFallback(BuildContext context, String source) {
  final gs = Theme.of(context).extension<GsTheme>()!;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: gs.codeBg,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(source, style: gs.mono),
  );
}
