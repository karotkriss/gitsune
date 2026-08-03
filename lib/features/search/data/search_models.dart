import '../../issues/data/issue_models.dart';

/// A project result from GitLab's search API (`scope=projects`).
class SearchProject {
  const SearchProject({
    required this.id,
    required this.name,
    required this.nameWithNamespace,
    required this.description,
    this.avatarUrl,
    this.starCount = 0,
    this.webUrl,
  });

  factory SearchProject.fromJson(Map<String, dynamic> json) => SearchProject(
    id: json['id'] as int,
    name: json['name'] as String,
    nameWithNamespace:
        json['name_with_namespace'] as String? ?? json['name'] as String,
    description: json['description'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String?,
    starCount: json['star_count'] as int? ?? 0,
    webUrl: json['web_url'] as String?,
  );

  final int id;
  final String name;
  final String nameWithNamespace;
  final String description;
  final String? avatarUrl;
  final int starCount;
  final String? webUrl;
}

enum SearchMergeRequestState {
  opened,
  closed,
  merged,
  locked;

  factory SearchMergeRequestState.fromApi(String value) => switch (value) {
    'opened' => SearchMergeRequestState.opened,
    'closed' => SearchMergeRequestState.closed,
    'merged' => SearchMergeRequestState.merged,
    'locked' => SearchMergeRequestState.locked,
    _ => throw FormatException('Unknown merge request state: $value'),
  };

  String get label => switch (this) {
    SearchMergeRequestState.opened => 'Open',
    SearchMergeRequestState.closed => 'Closed',
    SearchMergeRequestState.merged => 'Merged',
    SearchMergeRequestState.locked => 'Locked',
  };
}

/// A merge request result from GitLab's search API (`scope=merge_requests`).
///
/// E7.1 (MR list/detail) hasn't landed a canonical `MergeRequest` model yet,
/// so this is the minimal shape a search result row needs. It reuses
/// [IssueAuthor]/[IssueLabel] since the search API returns the same
/// author/label JSON shape for issues and merge requests.
class SearchMergeRequest {
  const SearchMergeRequest({
    required this.id,
    required this.projectId,
    required this.iid,
    required this.title,
    required this.state,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
    required this.userNotesCount,
    this.webUrl,
  });

  factory SearchMergeRequest.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    return SearchMergeRequest(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      iid: json['iid'] as int,
      title: json['title'] as String,
      state: SearchMergeRequestState.fromApi(json['state'] as String),
      author: IssueAuthor.fromJson(_jsonMap(json['author'])),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      labels: rawLabels is List
          ? rawLabels.map(IssueLabel.fromJson).toList(growable: false)
          : const [],
      userNotesCount: json['user_notes_count'] as int? ?? 0,
      webUrl: json['web_url'] as String?,
    );
  }

  final int id;
  final int projectId;
  final int iid;
  final String title;
  final SearchMergeRequestState state;
  final IssueAuthor author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<IssueLabel> labels;
  final int userNotesCount;
  final String? webUrl;

  String get reference => '!$iid';
}

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Expected a JSON object.');
  }
  return Map<String, dynamic>.from(value);
}
