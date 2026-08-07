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
/// for a URL with no usable path segments.
///
/// The result is always a bare file name with any directory components
/// stripped: a percent-decoded segment can decode to contain `/`, `\`, or
/// `..`, so passing it through unsanitized would let a crafted asset URL from
/// an untrusted instance escape the downloads directory.
String fileNameForAsset(ReleaseAssetLink asset) {
  final segments = Uri.parse(asset.url).pathSegments;
  final fromUrl = _sanitizeFileName(segments.isEmpty ? '' : segments.last);
  return fromUrl.isEmpty ? _sanitizeFileName(asset.name) : fromUrl;
}

String _sanitizeFileName(String value) {
  final base = value.split(RegExp(r'[/\\]')).last;
  return (base == '.' || base == '..') ? '' : base;
}
