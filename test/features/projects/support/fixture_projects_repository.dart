import 'package:gitsune/features/projects/data/projects_repository.dart';
import 'package:gitsune/features/search/data/search_models.dart';

import '../../../support/fixtures.dart';

/// A canned [ProjectsRepository] for widget tests, serving the shared project
/// fixture (or the pages passed in).
class FixtureProjectsRepository implements ProjectsRepository {
  FixtureProjectsRepository({
    List<SearchProject>? firstPage,
    this.secondPage = const [],
  }) : _firstPage = firstPage ?? _projectsFrom('search_projects_page1');

  final List<SearchProject> _firstPage;
  final List<SearchProject> secondPage;

  int firstPageLoads = 0;
  int nextPageLoads = 0;

  @override
  Future<ProjectPage> loadFirstPage() async {
    firstPageLoads++;
    return ProjectPage(items: _firstPage, hasMore: secondPage.isNotEmpty);
  }

  @override
  Future<ProjectPage> loadNextPage() async {
    nextPageLoads++;
    return ProjectPage(items: secondPage, hasMore: false);
  }

  static List<SearchProject> _projectsFrom(String fixture) => [
    for (final json in Fixtures.json(fixture) as List)
      SearchProject.fromJson(json as Map<String, dynamic>),
  ];
}
