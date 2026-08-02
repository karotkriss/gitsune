import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import 'ci_status.dart';

/// GitLab's circular pipeline-status badge with a fixed status-to-color map.
///
/// The color cannot be overridden because this mapping is part of the Pajamas
/// CI language. Supply [semanticLabel] when the surrounding context should say
/// more than the default "CI status" label.
class CiStatusBadge extends StatelessWidget {
  const CiStatusBadge({
    super.key,
    required this.status,
    this.size = 20,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }) : assert(size > 0);

  final CiStatus status;
  final double size;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final glyph = SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 14 14">'
      '${_svgBody(status)}'
      '</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(_statusColor(gs, status), BlendMode.srcIn),
    );

    if (excludeFromSemantics) return ExcludeSemantics(child: glyph);
    return Semantics(
      image: true,
      label: semanticLabel ?? 'CI status: ${status.label}',
      child: ExcludeSemantics(child: glyph),
    );
  }
}

Color _statusColor(GsTheme gs, CiStatus status) => switch (status) {
  CiStatus.success => gs.statusSuccess,
  CiStatus.failed => gs.statusDanger,
  CiStatus.running => gs.statusInfo,
  CiStatus.pending ||
  CiStatus.warning ||
  CiStatus.waitingForResource => gs.statusWarning,
  CiStatus.canceled ||
  CiStatus.canceling ||
  CiStatus.skipped ||
  CiStatus.manual ||
  CiStatus.created ||
  CiStatus.scheduled ||
  CiStatus.preparing ||
  CiStatus.unknown => gs.statusNeutral,
};

String _svgBody(CiStatus status) => switch (status) {
  CiStatus.success =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M6.278 7.697L5.045 6.464a.296.296 0 0 0-.42-.002l-.613.614a.298.298 0 0 0 .002.42l1.91 1.909a.5.5 0 0 0 .703.005l.265-.265L9.997 6.04a.291.291 0 0 0-.009-.408l-.614-.614a.29.29 0 0 0-.408-.009L6.278 7.697z"/>',
  CiStatus.failed =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M7 5.969L5.599 4.568a.29.29 0 0 0-.413.004l-.614.614a.294.294 0 0 0-.004.413L5.968 7l-1.4 1.401a.29.29 0 0 0 .004.413l.614.614c.113.114.3.117.413.004L7 8.032l1.401 1.4a.29.29 0 0 0 .413-.004l.614-.614a.294.294 0 0 0 .004-.413L8.032 7l1.4-1.401a.29.29 0 0 0-.004-.413l-.614-.614a.294.294 0 0 0-.413-.004L7 5.968z"/>',
  CiStatus.running =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M7 3c2.2 0 4 1.8 4 4s-1.8 4-4 4c-1.3 0-2.5-.7-3.3-1.7L7 7V3"/>',
  CiStatus.pending || CiStatus.waitingForResource =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M4.7 5.3c0-.2.1-.3.3-.3h.9c.2 0 .3.1.3.3v3.4c0 .2-.1.3-.3.3H5c-.2 0-.3-.1-.3-.3V5.3m3 0c0-.2.1-.3.3-.3h.9c.2 0 .3.1.3.3v3.4c0 .2-.1.3-.3.3H8c-.2 0-.3-.1-.3-.3V5.3"/>',
  CiStatus.created =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<circle cx="7" cy="7" r="3.25"/>',
  CiStatus.canceled || CiStatus.canceling =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M5.2 3.8l4.9 4.9c.2.2.2.5 0 .7l-.7.7c-.2.2-.5.2-.7 0L3.8 5.2c-.2-.2-.2-.5 0-.7l.7-.7c.2-.2.5-.2.7 0"/>',
  CiStatus.skipped =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M6.415 7.04L4.579 5.203a.295.295 0 0 1 .004-.416l.349-.349a.29.29 0 0 1 .416-.004l2.214 2.214a.289.289 0 0 1 .019.021l.132.133c.11.11.108.291 0 .398L5.341 9.573a.282.282 0 0 1-.398 0l-.331-.331a.285.285 0 0 1 0-.399L6.415 7.04zm2.54 0L7.119 5.203a.295.295 0 0 1 .004-.416l.349-.349a.29.29 0 0 1 .416-.004l2.214 2.214a.289.289 0 0 1 .019.021l.132.133c.11.11.108.291 0 .398L7.881 9.573a.282.282 0 0 1-.398 0l-.331-.331a.285.285 0 0 1 0-.399L8.955 7.04z"/>',
  CiStatus.manual =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M10.5 7.63V6.37l-.787-.13c-.044-.175-.132-.349-.263-.61l.481-.652-.918-.913-.657.478a2.346 2.346 0 0 0-.612-.26L7.656 3.5H6.388l-.132.783c-.219.043-.394.13-.612.26l-.657-.478-.918.913.437.652c-.131.218-.175.392-.262.61l-.744.086v1.261l.787.13c.044.218.132.392.263.61l-.438.651.92.913.655-.434c.175.086.394.173.613.26l.131.783h1.313l.131-.783c.219-.043.394-.13.613-.26l.656.478.918-.913-.48-.652c.13-.218.218-.435.262-.61l.656-.13zM7 8.283a1.285 1.285 0 0 1-1.313-1.305c0-.739.57-1.304 1.313-1.304.744 0 1.313.565 1.313 1.304 0 .74-.57 1.305-1.313 1.305z"/>',
  CiStatus.scheduled =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M6.995 10.64a3.645 3.645 0 1 1 0-7.29 3.645 3.645 0 0 1 0 7.29zm0-1.042a2.603 2.603 0 1 0 0-5.206 2.603 2.603 0 0 0 0 5.206z"/>'
        '<path d="M7.033 4.92h-.065a.488.488 0 0 0-.488.488v1.627c0 .27.218.488.488.488h.065c.27 0 .488-.218.488-.488V5.408a.488.488 0 0 0-.488-.488z"/>'
        '<path d="M8.075 6.48H6.968a.488.488 0 0 0-.488.488v.065c0 .27.218.488.488.488h1.107c.27 0 .488-.218.488-.488v-.065a.488.488 0 0 0-.488-.488z"/>',
  CiStatus.warning =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M6 3.5c0-.3.2-.5.5-.5h1c.3 0 .5.2.5.5v4c0 .3-.2.5-.5.5h-1c-.3 0-.5-.2-.5-.5v-4m0 6c0-.3.2-.5.5-.5h1c.3 0 .5.2.5.5v1c0 .3-.2.5-.5.5h-1c-.3 0-.5-.2-.5-.5v-1"/>',
  CiStatus.preparing =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<circle cx="7" cy="7" r="1"/>'
        '<circle cx="10" cy="7" r="1"/>'
        '<circle cx="4" cy="7" r="1"/>',
  CiStatus.unknown =>
    '<path d="M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z"/>'
        '<path d="M8.16 7.184c.519-.37.904-.857 1.07-1.477.384-1.427-.619-2.897-2.246-2.897-.732 0-1.327.26-1.766.692a2.163 2.163 0 0 0-.509.743.75.75 0 0 0 1.4.54.78.78 0 0 1 .16-.213c.168-.165.39-.262.715-.262.597 0 .936.496.798 1.007-.067.249-.235.462-.492.644-.231.165-.47.264-.601.3a.75.75 0 0 0-.556.724v1.421a.75.75 0 0 0 1.5 0v-.909a3.74 3.74 0 0 0 .526-.313z"/>'
        '<circle cx="6.889" cy="10.634" r="1"/>',
};
