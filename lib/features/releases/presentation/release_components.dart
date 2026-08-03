const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// The absolute release date shown on release rows and the detail header,
/// e.g. `Jan 5, 2026`. Absolute rather than relative because a release is a
/// point-in-time artifact users cross-reference with changelogs.
String formatReleaseDate(DateTime timestamp) {
  final local = timestamp.toLocal();
  return '${_monthNames[local.month - 1]} ${local.day}, ${local.year}';
}
