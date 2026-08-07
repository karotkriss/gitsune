import '../data/releases_repository.dart';

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

/// The file name a downloaded asset should be saved under: the URL's last
/// path segment, percent-decoded, falling back to the asset's display name
/// for a URL with no path segments.
String fileNameForAsset(ReleaseAssetLink asset) {
  final segments = Uri.parse(asset.url).pathSegments;
  final last = segments.isEmpty ? '' : segments.last;
  return last.isEmpty ? asset.name : Uri.decodeComponent(last);
}
