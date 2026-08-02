import '../../../core/ci/ci_status.dart';

class PipelineDetails {
  const PipelineDetails({required this.pipeline, required this.jobs});

  final Pipeline pipeline;
  final List<PipelineJob> jobs;
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
    status: CiStatus.fromApi(json['status'] as String),
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

  String get shortSha => sha.length <= 8 ? sha : sha.substring(0, 8);
}

class PipelineJob {
  const PipelineJob({
    required this.id,
    required this.name,
    required this.stage,
    required this.status,
    required this.allowFailure,
    this.duration,
    this.queuedDuration,
    this.startedAt,
    this.finishedAt,
    this.webUrl,
  });

  factory PipelineJob.fromJson(Map<String, dynamic> json) => PipelineJob(
    id: json['id'] as int,
    name: json['name'] as String,
    stage: json['stage'] as String,
    status: CiStatus.fromApi(json['status'] as String),
    allowFailure: json['allow_failure'] as bool? ?? false,
    duration: (json['duration'] as num?)?.toDouble(),
    queuedDuration: (json['queued_duration'] as num?)?.toDouble(),
    startedAt: _dateTimeOrNull(json['started_at']),
    finishedAt: _dateTimeOrNull(json['finished_at']),
    webUrl: json['web_url'] as String?,
  );

  final int id;
  final String name;
  final String stage;
  final CiStatus status;
  final bool allowFailure;
  final double? duration;
  final double? queuedDuration;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? webUrl;
}

DateTime? _dateTimeOrNull(Object? value) =>
    value is String ? DateTime.parse(value) : null;
