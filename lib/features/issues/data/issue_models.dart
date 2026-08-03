/// Immutable issue data shaped from GitLab's REST v4 issue and notes payloads.
class Issue {
  const Issue({
    required this.id,
    required this.projectId,
    required this.iid,
    required this.title,
    required this.description,
    required this.state,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
    required this.assignees,
    required this.userNotesCount,
    this.milestoneTitle,
    this.webUrl,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    final rawAssignees = json['assignees'];
    final milestone = json['milestone'];

    return Issue(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      iid: json['iid'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      state: IssueState.fromApi(json['state'] as String),
      author: IssueAuthor.fromJson(_jsonMap(json['author'])),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      labels: rawLabels is List
          ? rawLabels.map(IssueLabel.fromJson).toList(growable: false)
          : const [],
      assignees: rawAssignees is List
          ? rawAssignees
                .map((value) => IssueAuthor.fromJson(_jsonMap(value)))
                .toList(growable: false)
          : const [],
      userNotesCount: json['user_notes_count'] as int? ?? 0,
      milestoneTitle: milestone is Map
          ? _jsonMap(milestone)['title'] as String?
          : null,
      webUrl: json['web_url'] as String?,
    );
  }

  final int id;
  final int projectId;
  final int iid;
  final String title;
  final String description;
  final IssueState state;
  final IssueAuthor author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<IssueLabel> labels;
  final List<IssueAuthor> assignees;
  final int userNotesCount;
  final String? milestoneTitle;
  final String? webUrl;

  String get reference => '#$iid';

  /// The issue update endpoint returns labels as plain names, so a caller
  /// folding its response can restore the detailed colors it already knows.
  Issue withLabelDetailsFrom(Iterable<IssueLabel> known) {
    final byName = {for (final label in known) label.name: label};
    return Issue(
      id: id,
      projectId: projectId,
      iid: iid,
      title: title,
      description: description,
      state: state,
      author: author,
      createdAt: createdAt,
      updatedAt: updatedAt,
      labels: labels
          .map(
            (label) =>
                label.colorHex != null ? label : (byName[label.name] ?? label),
          )
          .toList(growable: false),
      assignees: assignees,
      userNotesCount: userNotesCount,
      milestoneTitle: milestoneTitle,
      webUrl: webUrl,
    );
  }
}

enum IssueState {
  opened,
  closed;

  factory IssueState.fromApi(String value) => switch (value) {
    'opened' => IssueState.opened,
    'closed' => IssueState.closed,
    _ => throw FormatException('Unknown issue state: $value'),
  };

  String get label => switch (this) {
    IssueState.opened => 'Open',
    IssueState.closed => 'Closed',
  };
}

class IssueAuthor {
  const IssueAuthor({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
  });

  factory IssueAuthor.fromJson(Map<String, dynamic> json) => IssueAuthor(
    id: json['id'] as int,
    username: json['username'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatar_url'] as String?,
  );

  final int id;
  final String username;
  final String name;
  final String? avatarUrl;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }
}

/// GitLab returns detailed label maps when `with_labels_details=true` and
/// plain strings otherwise, so both forms are accepted.
class IssueLabel {
  const IssueLabel({required this.name, this.colorHex, this.textColorHex});

  factory IssueLabel.fromJson(Object? value) {
    if (value is String) return IssueLabel(name: value);
    final json = _jsonMap(value);
    return IssueLabel(
      name: json['name'] as String,
      colorHex: json['color'] as String?,
      textColorHex: json['text_color'] as String?,
    );
  }

  final String name;
  final String? colorHex;
  final String? textColorHex;

  bool get isScoped => name.contains('::');

  String get scope => isScoped ? name.split('::').first : name;

  String get value => isScoped ? name.substring(name.indexOf('::') + 2) : name;
}

class IssueNote {
  const IssueNote({
    required this.id,
    required this.body,
    required this.author,
    required this.createdAt,
    required this.system,
    required this.internal,
  });

  factory IssueNote.fromJson(Map<String, dynamic> json) => IssueNote(
    id: json['id'] as int,
    body: json['body'] as String,
    author: IssueAuthor.fromJson(_jsonMap(json['author'])),
    createdAt: DateTime.parse(json['created_at'] as String),
    system: json['system'] as bool? ?? false,
    internal: json['internal'] as bool? ?? false,
  );

  final int id;
  final String body;
  final IssueAuthor author;
  final DateTime createdAt;
  final bool system;
  final bool internal;
}

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Expected a JSON object.');
  }
  return Map<String, dynamic>.from(value);
}
