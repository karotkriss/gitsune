import '../../../core/ci/ci_status.dart';

/// Immutable data shaped from GitLab's merge request, pipeline, and approval
/// payloads.
class MergeRequest {
  const MergeRequest({
    required this.id,
    required this.projectId,
    required this.iid,
    required this.title,
    required this.description,
    required this.state,
    required this.draft,
    required this.author,
    required this.sourceBranch,
    required this.targetBranch,
    required this.createdAt,
    required this.updatedAt,
    required this.userNotesCount,
    required this.labels,
    this.changesCount,
    this.webUrl,
    this.diffRefs,
    this.mergeStatus,
    this.detailedMergeStatus,
    this.blockingDiscussionsResolved = true,
  });

  factory MergeRequest.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    final rawDiffRefs = json['diff_refs'];
    return MergeRequest(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      iid: json['iid'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      state: MergeRequestState.fromApi(json['state'] as String),
      draft: json['draft'] as bool? ?? false,
      author: MergeRequestAuthor.fromJson(_jsonMap(json['author'])),
      sourceBranch: json['source_branch'] as String,
      targetBranch: json['target_branch'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userNotesCount: json['user_notes_count'] as int? ?? 0,
      labels: rawLabels is List
          ? rawLabels.map(_labelName).toList(growable: false)
          : const [],
      changesCount: switch (json['changes_count']?.toString()) {
        null || '' => null,
        final value => value,
      },
      webUrl: json['web_url'] as String?,
      diffRefs: rawDiffRefs is Map
          ? DiffRefs.fromJson(Map<String, dynamic>.from(rawDiffRefs))
          : null,
      mergeStatus: json['merge_status'] as String?,
      detailedMergeStatus: json['detailed_merge_status'] as String?,
      blockingDiscussionsResolved:
          json['blocking_discussions_resolved'] as bool? ?? true,
    );
  }

  final int id;
  final int projectId;
  final int iid;
  final String title;
  final String description;
  final MergeRequestState state;
  final bool draft;
  final MergeRequestAuthor author;
  final String sourceBranch;
  final String targetBranch;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userNotesCount;
  final List<String> labels;
  final String? changesCount;
  final String? webUrl;
  final DiffRefs? diffRefs;
  final String? mergeStatus;
  final String? detailedMergeStatus;
  final bool blockingDiscussionsResolved;

  String get reference => '!$iid';

  /// Whether GitLab reports the merge request as mergeable, preferring the
  /// modern `detailed_merge_status` over the legacy `merge_status`.
  bool get mergeable => detailedMergeStatus != null
      ? detailedMergeStatus == 'mergeable'
      : mergeStatus == 'can_be_merged';

  /// The API-shaped JSON [fromJson] reads, for the recently-viewed cache.
  Map<String, dynamic> toJson() => {
    'id': id,
    'project_id': projectId,
    'iid': iid,
    'title': title,
    'description': description,
    'state': state.name,
    'draft': draft,
    'author': author.toJson(),
    'source_branch': sourceBranch,
    'target_branch': targetBranch,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'user_notes_count': userNotesCount,
    'labels': labels,
    'changes_count': changesCount,
    'web_url': webUrl,
    'diff_refs': diffRefs?.toJson(),
    'merge_status': mergeStatus,
    'detailed_merge_status': detailedMergeStatus,
    'blocking_discussions_resolved': blockingDiscussionsResolved,
  };

  String get displayStateLabel => draft ? 'Draft' : state.label;

  String get changedFilesLabel => switch (changesCount) {
    null => 'Changed files',
    '1' => '1 file changed',
    final count => '$count files changed',
  };
}

enum MergeRequestState {
  opened,
  closed,
  merged,
  locked;

  factory MergeRequestState.fromApi(String value) => switch (value) {
    'opened' => MergeRequestState.opened,
    'closed' => MergeRequestState.closed,
    'merged' => MergeRequestState.merged,
    'locked' => MergeRequestState.locked,
    _ => throw FormatException('Unknown merge request state: $value'),
  };

  String get label => switch (this) {
    MergeRequestState.opened => 'Open',
    MergeRequestState.closed => 'Closed',
    MergeRequestState.merged => 'Merged',
    MergeRequestState.locked => 'Locked',
  };
}

/// The merge request's diff refs, needed to position a new diff comment.
class DiffRefs {
  const DiffRefs({
    required this.baseSha,
    required this.startSha,
    required this.headSha,
  });

  factory DiffRefs.fromJson(Map<String, dynamic> json) => DiffRefs(
    baseSha: json['base_sha'] as String,
    startSha: json['start_sha'] as String,
    headSha: json['head_sha'] as String,
  );

  final String baseSha;
  final String startSha;
  final String headSha;

  Map<String, dynamic> toJson() => {
    'base_sha': baseSha,
    'start_sha': startSha,
    'head_sha': headSha,
  };
}

class MergeRequestAuthor {
  const MergeRequestAuthor({
    required this.id,
    required this.username,
    required this.name,
    this.avatarUrl,
  });

  factory MergeRequestAuthor.fromJson(Map<String, dynamic> json) =>
      MergeRequestAuthor(
        id: json['id'] as int,
        username: json['username'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
      );

  final int id;
  final String username;
  final String name;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'avatar_url': avatarUrl,
  };

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class MergeRequestPipeline {
  const MergeRequestPipeline({
    required this.id,
    required this.status,
    required this.ref,
    required this.sha,
    this.updatedAt,
    this.webUrl,
  });

  factory MergeRequestPipeline.fromJson(Map<String, dynamic> json) =>
      MergeRequestPipeline(
        id: json['id'] as int,
        status: _pipelineStatus(json),
        ref: json['ref'] as String,
        sha: json['sha'] as String,
        updatedAt: switch (json['updated_at']) {
          final String value => DateTime.parse(value),
          _ => null,
        },
        webUrl: json['web_url'] as String?,
      );

  final int id;
  final CiStatus status;
  final String ref;
  final String sha;
  final DateTime? updatedAt;
  final String? webUrl;

  String get shortSha => sha.length <= 8 ? sha : sha.substring(0, 8);
}

class MergeRequestApprovals {
  const MergeRequestApprovals({
    required this.approvalsRequired,
    required this.approvalsLeft,
    required this.approvedBy,
    this.userHasApproved = false,
    this.userCanApprove = false,
  });

  factory MergeRequestApprovals.fromJson(Map<String, dynamic> json) {
    final rawApprovedBy = json['approved_by'];
    return MergeRequestApprovals(
      approvalsRequired: json['approvals_required'] as int? ?? 0,
      approvalsLeft: json['approvals_left'] as int? ?? 0,
      approvedBy: rawApprovedBy is List
          ? rawApprovedBy
                .map((value) => _jsonMap(value)['user'])
                .map((value) => MergeRequestAuthor.fromJson(_jsonMap(value)))
                .toList(growable: false)
          : const [],
      userHasApproved: json['user_has_approved'] as bool? ?? false,
      userCanApprove: json['user_can_approve'] as bool? ?? false,
    );
  }

  final int approvalsRequired;
  final int approvalsLeft;
  final List<MergeRequestAuthor> approvedBy;
  final bool userHasApproved;
  final bool userCanApprove;

  int get approvedCount {
    if (approvalsRequired == 0) return approvedBy.length;
    final count = approvalsRequired - approvalsLeft;
    if (count < 0) return 0;
    if (count > approvalsRequired) return approvalsRequired;
    return count;
  }

  bool get complete => approvalsLeft == 0;

  String get summary => approvalsRequired == 0
      ? 'No approvals required'
      : '$approvedCount of $approvalsRequired approved';
}

CiStatus _pipelineStatus(Map<String, dynamic> json) {
  final detailedStatus = json['detailed_status'];
  if (detailedStatus is Map && detailedStatus['icon'] == 'status_warning') {
    return CiStatus.warning;
  }
  return CiStatus.fromApi(json['status'] as String);
}

String _labelName(Object? value) {
  if (value is String) return value;
  return _jsonMap(value)['name'] as String;
}

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Expected a JSON object.');
  }
  return Map<String, dynamic>.from(value);
}
