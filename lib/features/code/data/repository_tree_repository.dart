import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/account_key.dart';
import '../../../core/network/keyset_paginator.dart';

/// Read seam consumed by the code browsing screens (tree and file view):
/// one directory level at a time, offline-first per the E3.3 seam.
/// [watchDirectory] is the reactive database read of one directory's cached
/// entries; [refreshDirectory] fetches that directory from the network and
/// writes through, swallowing network failures so the stream keeps serving
/// the cache. [loadFileContent] fetches one blob's raw text for the file
/// view, network-only like the job log: a blob is read on demand and never
/// diffed, so caching whole file bodies would cost more than refetching.
/// [fileWebUrl] resolves the blob's page on the account's GitLab instance
/// for the oversized-file browser fallback.
abstract interface class RepositoryTreeRepository {
  Stream<List<RepositoryTreeEntry>> watchDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  });

  Future<void> refreshDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  });

  Future<String> loadFileContent(
    int projectId, {
    required String path,
    String ref = '',
  });

  Uri fileWebUrl({
    required String projectPath,
    required String path,
    String ref = '',
  });
}

/// GitLab repository tree reader (`GET /projects/:id/repository/tree`),
/// account-scoped and cached per directory in drift.
///
/// A refresh follows every pagination `Link` header via the E3.4 paginator,
/// then replaces the directory's cached rows in one transaction, preserving
/// GitLab's server-side ordering through the `position` column. An empty
/// [RepositoryTreeRepository.refreshDirectory] `ref` omits the `ref`
/// parameter, so GitLab serves the project's default branch.
class GitLabRepositoryTreeRepository implements RepositoryTreeRepository {
  GitLabRepositoryTreeRepository({
    required this.database,
    required this.client,
    required this.account,
  });

  final AppDatabase database;
  final Dio client;
  final AccountKey account;
  final _inFlightRefreshes = <(int, String, String), Future<void>>{};

  @override
  Stream<List<RepositoryTreeEntry>> watchDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  }) {
    final query = database.select(database.repositoryTreeEntries)
      ..where(
        (t) =>
            t.instanceHost.equals(account.instanceHost) &
            t.accountId.equals(account.accountId) &
            t.projectId.equals(projectId) &
            t.ref.equals(ref) &
            t.parentPath.equals(path),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.position)]);
    return query.watch();
  }

  @override
  Future<void> refreshDirectory(
    int projectId, {
    String ref = '',
    String path = '',
  }) {
    final key = (projectId, ref, path);
    final inFlight = _inFlightRefreshes[key];
    if (inFlight != null) return inFlight;

    final refresh = _performRefresh(projectId, ref: ref, path: path);
    _inFlightRefreshes[key] = refresh;
    return refresh.whenComplete(() => _inFlightRefreshes.remove(key));
  }

  Future<void> _performRefresh(
    int projectId, {
    required String ref,
    required String path,
  }) async {
    var position = 0;
    final paginator = KeysetPaginator<RepositoryTreeEntriesCompanion>(
      dio: client,
      initialUri: _treeUri(projectId, ref: ref, path: path),
      decode: (json) => RepositoryTreeEntriesCompanion.insert(
        instanceHost: account.instanceHost,
        accountId: account.accountId,
        projectId: projectId,
        ref: ref,
        parentPath: path,
        name: json['name'] as String,
        path: json['path'] as String,
        entryType: json['type'] as String,
        position: position++,
      ),
    );

    final rows = <RepositoryTreeEntriesCompanion>[];
    try {
      while (paginator.hasMore) {
        rows.addAll((await paginator.loadNext()).items);
      }
    } on DioException {
      return;
    }

    await database.transaction(() async {
      await (database.delete(database.repositoryTreeEntries)..where(
            (t) =>
                t.instanceHost.equals(account.instanceHost) &
                t.accountId.equals(account.accountId) &
                t.projectId.equals(projectId) &
                t.ref.equals(ref) &
                t.parentPath.equals(path),
          ))
          .go();
      await database.batch(
        (batch) => batch.insertAll(database.repositoryTreeEntries, rows),
      );
    });
  }

  @override
  Future<String> loadFileContent(
    int projectId, {
    required String path,
    String ref = '',
  }) async {
    var uri = _apiUri(
      'projects/$projectId/repository/files/'
      '${Uri.encodeComponent(path)}/raw',
    );
    if (ref.isNotEmpty) uri = uri.replace(queryParameters: {'ref': ref});
    final response = await client.getUri<String>(
      uri,
      options: Options(responseType: ResponseType.plain),
    );
    return response.data ?? '';
  }

  @override
  Uri fileWebUrl({
    required String projectPath,
    required String path,
    String ref = '',
  }) {
    // GitLab resolves `HEAD` to the project's default branch, matching what
    // an empty ref means against the API.
    final webRef = ref.isEmpty ? 'HEAD' : ref;
    return Uri.https(account.instanceHost, '$projectPath/-/blob/$webRef/$path');
  }

  Uri _apiUri(String pathAndQuery) {
    final base = client.options.baseUrl.endsWith('/')
        ? client.options.baseUrl
        : '${client.options.baseUrl}/';
    return Uri.parse(base).resolve(pathAndQuery);
  }

  Uri _treeUri(int projectId, {required String ref, required String path}) {
    return _apiUri('projects/$projectId/repository/tree').replace(
      queryParameters: {
        if (path.isNotEmpty) 'path': path,
        if (ref.isNotEmpty) 'ref': ref,
        'pagination': 'keyset',
        'per_page': '100',
      },
    );
  }
}
