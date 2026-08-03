import '../../../core/ci/ci_status.dart';

class PipelineDetails {
  factory PipelineDetails({
    required Pipeline pipeline,
    required Iterable<PipelineJob> jobs,
  }) {
    final attempts = List<PipelineJob>.unmodifiable(jobs);
    return PipelineDetails._(
      pipeline: pipeline,
      attempts: attempts,
      jobs: _latestJobsInStageOrder(attempts),
    );
  }

  PipelineDetails._({
    required this.pipeline,
    required this._attempts,
    required this.jobs,
  });

  /// Reads the cache-shaped JSON [toJson] writes (this composite of one
  /// pipeline plus its job attempts has no single API payload of its own).
  factory PipelineDetails.fromJson(Map<String, dynamic> json) {
    return PipelineDetails(
      pipeline: Pipeline.fromJson(_jsonMap(json['pipeline'])),
      jobs: (json['jobs'] as List)
          .map((value) => PipelineJob.fromJson(_jsonMap(value)))
          .toList(growable: false),
    );
  }

  final Pipeline pipeline;
  final List<PipelineJob> jobs;
  final List<PipelineJob> _attempts;

  /// Applies a job action's response, replacing same-id jobs (cancel, play)
  /// or adding a new attempt (retry creates a new job id) then re-deriving
  /// the latest-per-stage-and-name view.
  PipelineDetails withUpdatedJob(PipelineJob updated, {DateTime? updatedAt}) {
    final nextUpdatedAt = updatedAt == null
        ? pipeline.updatedAt
        : updatedAt.isAfter(pipeline.updatedAt)
        ? updatedAt
        : pipeline.updatedAt.add(const Duration(microseconds: 1));
    return PipelineDetails(
      pipeline: pipeline.withUpdatedAt(nextUpdatedAt),
      jobs: [..._attempts.where((job) => job.id != updated.id), updated],
    );
  }

  Map<String, dynamic> toJson() => {
    'pipeline': pipeline.toJson(),
    'jobs': [for (final job in _attempts) job.toJson()],
  };
}

List<PipelineJob> _latestJobsInStageOrder(Iterable<PipelineJob> jobs) {
  final firstIdByStage = <String, int>{};
  final firstIdByJob = <(String, String), int>{};
  final latestByJob = <(String, String), PipelineJob>{};

  for (final job in jobs) {
    firstIdByStage.update(
      job.stage,
      (id) => id < job.id ? id : job.id,
      ifAbsent: () => job.id,
    );
    final key = (job.stage, job.name);
    firstIdByJob.update(
      key,
      (id) => id < job.id ? id : job.id,
      ifAbsent: () => job.id,
    );
    final latest = latestByJob[key];
    if (latest == null || job.id > latest.id) latestByJob[key] = job;
  }

  final latestJobs = latestByJob.values.toList();
  latestJobs.sort((a, b) {
    final stageOrder = firstIdByStage[a.stage]!.compareTo(
      firstIdByStage[b.stage]!,
    );
    if (stageOrder != 0) return stageOrder;
    final jobOrder = firstIdByJob[(a.stage, a.name)]!.compareTo(
      firstIdByJob[(b.stage, b.name)]!,
    );
    if (jobOrder != 0) return jobOrder;
    return a.name.compareTo(b.name);
  });
  return List.unmodifiable(latestJobs);
}

class Pipeline {
  const Pipeline({
    required this.id,
    required this.status,
    required this.ref,
    required this.sha,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.duration,
    this.webUrl,
  });

  factory Pipeline.fromJson(Map<String, dynamic> json) => Pipeline(
    id: json['id'] as int,
    status: _pipelineStatus(json),
    ref: json['ref'] as String,
    sha: json['sha'] as String,
    source: json['source'] as String? ?? 'unknown',
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    duration: (json['duration'] as num?)?.toDouble(),
    webUrl: json['web_url'] as String?,
  );

  final int id;
  final CiStatus status;
  final String ref;
  final String sha;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? duration;
  final String? webUrl;

  /// The API-shaped JSON [fromJson] reads, for the recently-viewed cache.
  /// [CiStatus.warning] round-trips because `fromApi` accepts `warning`.
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.apiValue,
    'ref': ref,
    'sha': sha,
    'source': source,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'duration': duration,
    'web_url': webUrl,
  };

  String get shortSha => sha.length <= 8 ? sha : sha.substring(0, 8);

  Pipeline withUpdatedAt(DateTime value) => Pipeline(
    id: id,
    status: status,
    ref: ref,
    sha: sha,
    source: source,
    createdAt: createdAt,
    updatedAt: value,
    duration: duration,
    webUrl: webUrl,
  );
}

class PipelineJob {
  const PipelineJob({
    required this.id,
    required this.name,
    required this.stage,
    required this.status,
    required this.allowFailure,
    CiStatus? badgeStatus,
    this.duration,
    this.queuedDuration,
    this.startedAt,
    this.finishedAt,
    this.webUrl,
  }) : badgeStatus = badgeStatus ?? status;

  factory PipelineJob.fromJson(Map<String, dynamic> json) {
    final status = CiStatus.fromApi(json['status'] as String);
    final allowFailure = json['allow_failure'] as bool? ?? false;
    return PipelineJob(
      id: json['id'] as int,
      name: json['name'] as String,
      stage: json['stage'] as String,
      status: status,
      allowFailure: allowFailure,
      badgeStatus: status == CiStatus.failed && allowFailure
          ? CiStatus.warning
          : status,
      duration: (json['duration'] as num?)?.toDouble(),
      queuedDuration: (json['queued_duration'] as num?)?.toDouble(),
      startedAt: _dateTimeOrNull(json['started_at']),
      finishedAt: _dateTimeOrNull(json['finished_at']),
      webUrl: json['web_url'] as String?,
    );
  }

  final int id;
  final String name;
  final String stage;
  final CiStatus status;
  final bool allowFailure;
  final CiStatus badgeStatus;
  final double? duration;
  final double? queuedDuration;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? webUrl;

  /// The API-shaped JSON [fromJson] reads, for the recently-viewed cache
  /// ([badgeStatus] is re-derived from `status` and `allow_failure`).
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stage': stage,
    'status': status.apiValue,
    'allow_failure': allowFailure,
    'duration': duration,
    'queued_duration': queuedDuration,
    'started_at': startedAt?.toIso8601String(),
    'finished_at': finishedAt?.toIso8601String(),
    'web_url': webUrl,
  };
}

CiStatus _pipelineStatus(Map<String, dynamic> json) {
  final detailedStatus = json['detailed_status'];
  if (detailedStatus is Map && detailedStatus['icon'] == 'status_warning') {
    return CiStatus.warning;
  }
  return CiStatus.fromApi(json['status'] as String);
}

DateTime? _dateTimeOrNull(Object? value) =>
    value is String ? DateTime.parse(value) : null;

Map<String, dynamic> _jsonMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Expected a JSON object.');
  }
  return Map<String, dynamic>.from(value);
}
