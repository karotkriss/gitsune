import '../../issues/data/issue_models.dart';

/// Immutable data shaped from GitLab's merge request discussion payloads.
///
/// Note authors reuse [IssueAuthor], the same shape the search feature
/// already borrows, so discussion notes can render with the shared issue
/// comment components.
class Discussion {
  const Discussion({
    required this.id,
    required this.individualNote,
    required this.notes,
  });

  factory Discussion.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    return Discussion(
      id: json['id'] as String,
      individualNote: json['individual_note'] as bool? ?? false,
      notes: rawNotes is List
          ? rawNotes
                .map(
                  (value) => DiscussionNote.fromJson(
                    Map<String, dynamic>.from(value as Map),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  final String id;
  final bool individualNote;
  final List<DiscussionNote> notes;

  /// The diff position this thread anchors to, from its first note.
  DiffPosition? get position => notes.isEmpty ? null : notes.first.position;

  /// True when this discussion is a thread anchored to a diff line.
  bool get isDiffThread =>
      !individualNote && position?.positionType == 'text';

  bool get resolvable => notes.any((note) => note.resolvable);

  /// True when every resolvable note in the thread is resolved.
  bool get resolved {
    final resolvableNotes = notes.where((note) => note.resolvable);
    return resolvableNotes.isNotEmpty &&
        resolvableNotes.every((note) => note.resolved);
  }
}

class DiscussionNote {
  const DiscussionNote({
    required this.id,
    required this.body,
    required this.author,
    required this.createdAt,
    required this.system,
    required this.resolvable,
    required this.resolved,
    this.position,
  });

  factory DiscussionNote.fromJson(Map<String, dynamic> json) {
    final rawPosition = json['position'];
    return DiscussionNote(
      id: json['id'] as int,
      body: json['body'] as String? ?? '',
      author: IssueAuthor.fromJson(
        Map<String, dynamic>.from(json['author'] as Map),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      system: json['system'] as bool? ?? false,
      resolvable: json['resolvable'] as bool? ?? false,
      resolved: json['resolved'] as bool? ?? false,
      position: rawPosition is Map
          ? DiffPosition.fromJson(Map<String, dynamic>.from(rawPosition))
          : null,
    );
  }

  final int id;
  final String body;
  final IssueAuthor author;
  final DateTime createdAt;
  final bool system;
  final bool resolvable;
  final bool resolved;
  final DiffPosition? position;
}

/// A GitLab diff note position: the diff refs plus the file and line the
/// note anchors to. [newLine] is set for additions, [oldLine] for deletions,
/// and both for context lines.
class DiffPosition {
  const DiffPosition({
    required this.baseSha,
    required this.startSha,
    required this.headSha,
    required this.oldPath,
    required this.newPath,
    this.oldLine,
    this.newLine,
    this.positionType = 'text',
  });

  factory DiffPosition.fromJson(Map<String, dynamic> json) => DiffPosition(
    baseSha: json['base_sha'] as String,
    startSha: json['start_sha'] as String,
    headSha: json['head_sha'] as String,
    oldPath: json['old_path'] as String,
    newPath: json['new_path'] as String,
    oldLine: json['old_line'] as int?,
    newLine: json['new_line'] as int?,
    positionType: json['position_type'] as String? ?? 'text',
  );

  final String baseSha;
  final String startSha;
  final String headSha;
  final String oldPath;
  final String newPath;
  final int? oldLine;
  final int? newLine;
  final String positionType;

  /// The API-shaped JSON the create-discussion endpoint accepts.
  Map<String, dynamic> toJson() => {
    'base_sha': baseSha,
    'start_sha': startSha,
    'head_sha': headSha,
    'position_type': positionType,
    'old_path': oldPath,
    'new_path': newPath,
    if (oldLine != null) 'old_line': oldLine,
    if (newLine != null) 'new_line': newLine,
  };
}
