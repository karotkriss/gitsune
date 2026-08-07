import 'dart:convert';

import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/features/releases/data/releases_repository.dart';

import '../../../support/fixtures.dart';

/// Serves the recorded release fixtures straight from memory, mirroring the
/// rows the real repository reads from its drift cache.
class FixtureReleasesRepository implements ReleasesRepository {
  FixtureReleasesRepository([List<ReleaseEntry>? releases])
    : _releases = releases ?? fixtureReleases();

  final List<ReleaseEntry> _releases;
  final refreshedProjectIds = <int>[];
  final downloadedAssets = <ReleaseAssetLink>[];

  /// Set to make the next [downloadAsset] call fail instead of succeeding.
  Object? downloadError;

  @override
  Stream<List<ReleaseEntry>> watchReleases(int projectId) =>
      Stream.value(List.unmodifiable(_releases));

  @override
  Stream<ReleaseEntry?> watchRelease(int projectId, String tagName) =>
      Stream.value(
        _releases.where((release) => release.tagName == tagName).firstOrNull,
      );

  @override
  Future<void> refreshReleases(int projectId) async {
    refreshedProjectIds.add(projectId);
  }

  /// Deliberately doesn't touch the real filesystem: `dart:io` async file
  /// operations hang under `testWidgets` (unlike a plain `test()`), so the
  /// real download-and-write path is covered at the repository level against
  /// the fake HTTP server instead; this double only exercises the screen's
  /// progress and completion/error UI.
  @override
  Future<void> downloadAsset(
    ReleaseAssetLink asset,
    String destinationPath, {
    void Function(int received, int total)? onProgress,
  }) async {
    onProgress?.call(5, 10);
    if (downloadError case final error?) {
      throw error;
    }
    downloadedAssets.add(asset);
    onProgress?.call(10, 10);
  }
}

/// The two fixture pages decoded into cache rows, in server order.
List<ReleaseEntry> fixtureReleases() {
  final pages = [
    Fixtures.json('releases_page1') as List,
    Fixtures.json('releases_page2') as List,
  ];
  var position = 0;
  return [
    for (final page in pages)
      for (final release in page.cast<Map<String, dynamic>>())
        ReleaseEntry(
          instanceHost: 'gitlab.example.com',
          accountId: 'alice',
          projectId: 7,
          tagName: release['tag_name'] as String,
          name: release['name'] as String? ?? release['tag_name'] as String,
          description: release['description'] as String? ?? '',
          releasedAt: DateTime.parse(
            (release['released_at'] ?? release['created_at']) as String,
          ),
          authorName:
              (release['author'] as Map<String, dynamic>?)?['name'] as String?,
          assetsJson: jsonEncode(release['assets'] ?? const {}),
          position: position++,
        ),
  ];
}
