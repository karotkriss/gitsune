import 'package:dio/dio.dart';

import '../../../core/network/keyset_paginator.dart';
import '../../search/data/search_models.dart';

class ProjectPage {
  const ProjectPage({required this.items, required this.hasMore});

  final List<SearchProject> items;
  final bool hasMore;
}

/// Network-backed seam behind the Home "Projects" tile: the projects the
/// signed-in user is a member of, most recently active first.
///
/// Rows reuse [SearchProject] - GitLab's `GET /projects` simple
/// representation carries the same fields as its project search results.
/// Like the other list repositories, this stays network-backed with no
/// offline cache.
abstract interface class ProjectsRepository {
  Future<ProjectPage> loadFirstPage();

  Future<ProjectPage> loadNextPage();
}

/// GitLab REST v4 membership-project reader with Link-header pagination.
class GitLabProjectsRepository implements ProjectsRepository {
  GitLabProjectsRepository(this._client);

  final Dio _client;

  KeysetPaginator<SearchProject>? _paginator;
  Future<ProjectPage>? _pageLoad;

  @override
  Future<ProjectPage> loadFirstPage() {
    final paginator = KeysetPaginator<SearchProject>(
      dio: _client,
      initialUri: _apiUri('projects', {
        'membership': 'true',
        'order_by': 'last_activity_at',
        'sort': 'desc',
        'simple': 'true',
        'per_page': '20',
      }),
      decode: SearchProject.fromJson,
    );
    _paginator = paginator;
    return _loadPage(paginator);
  }

  @override
  Future<ProjectPage> loadNextPage() {
    final existing = _pageLoad;
    if (existing != null) return existing;

    final paginator = _paginator;
    if (paginator == null) {
      throw StateError('Load the first project page before loading the next.');
    }
    if (!paginator.hasMore) {
      return Future.value(const ProjectPage(items: [], hasMore: false));
    }
    return _loadPage(paginator);
  }

  Future<ProjectPage> _loadPage(KeysetPaginator<SearchProject> paginator) {
    final future = paginator.loadNext().then(
      (page) => ProjectPage(items: page.items, hasMore: page.hasMore),
    );
    _pageLoad = future;
    return future.whenComplete(() {
      if (identical(_pageLoad, future)) _pageLoad = null;
    });
  }

  Uri _apiUri(String path, Map<String, String> queryParameters) {
    final base = _client.options.baseUrl.endsWith('/')
        ? _client.options.baseUrl
        : '${_client.options.baseUrl}/';
    return Uri.parse(
      base,
    ).resolve(path).replace(queryParameters: queryParameters);
  }
}
