import 'package:flutter/material.dart';

import '../../../core/ci/ci_status_badge.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/pipeline_models.dart';
import '../data/pipelines_repository.dart';

class PipelineDetailScreen extends StatefulWidget {
  const PipelineDetailScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.pipelineId,
    required this.repository,
  });

  final int projectId;
  final String projectPath;
  final int pipelineId;
  final PipelinesRepository repository;

  @override
  State<PipelineDetailScreen> createState() => _PipelineDetailScreenState();
}

class _PipelineDetailScreenState extends State<PipelineDetailScreen> {
  PipelineDetails? _details;
  bool _loading = true;
  bool _failed = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PipelineDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.pipelineId != widget.pipelineId ||
        oldWidget.repository != widget.repository) {
      _details = null;
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final details = await widget.repository.loadPipeline(
        widget.projectId,
        widget.pipelineId,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _details = details;
        _loading = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      if (_details != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh this pipeline.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final details = _details;
    return Scaffold(
      backgroundColor: gs.surfaceSubtle,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: gs.surfaceApp,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: GsIcon(
                  GsIconGlyph.chevronLeft,
                  size: 20,
                  color: gs.accent,
                ),
              )
            : null,
        title: Text(
          '${widget.projectPath} · #${widget.pipelineId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(
            color: gs.textHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: details == null
          ? _PipelineInitialState(
              loading: _loading,
              failed: _failed,
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: gs.accent,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_loading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  SliverToBoxAdapter(
                    child: _PipelineHeader(pipeline: details.pipeline),
                  ),
                  ..._jobSlivers(context, details.jobs),
                ],
              ),
            ),
    );
  }
}

class _PipelineHeader extends StatelessWidget {
  const _PipelineHeader({required this.pipeline});

  final Pipeline pipeline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Semantics(
      container: true,
      label:
          'Pipeline ${pipeline.id}, ${pipeline.status.label}. '
          'Reference ${pipeline.ref}. Commit ${pipeline.shortSha}. '
          '${formatPipelineSource(pipeline.source)}. '
          '${formatCiDuration(pipeline.duration)}.',
      child: ExcludeSemantics(
        child: ColoredBox(
          color: gs.surfaceApp,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CiStatusBadge(
                      status: pipeline.status,
                      size: 32,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pipeline.status.label,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: gs.textHeading,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pipeline #${pipeline.id}',
                            style: gs.caption.copyWith(color: gs.textSubtle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PipelineMetadataPill(label: pipeline.ref),
                    _PipelineMetadataPill(label: pipeline.shortSha),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${formatPipelineSource(pipeline.source)} · '
                  '${formatCiDuration(pipeline.duration)}',
                  style: gs.caption.copyWith(color: gs.textSubtle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PipelineMetadataPill extends StatelessWidget {
  const _PipelineMetadataPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gs.surfaceStrong,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: gs.mono.copyWith(color: gs.textDefault)),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({
    required this.job,
    required this.isFirst,
    required this.isLast,
  });

  final PipelineJob job;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final duration = job.duration == null
        ? 'No duration'
        : formatCiDuration(job.duration);
    final failurePolicy = job.allowFailure ? ', allowed to fail' : '';
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );
    return Semantics(
      container: true,
      label:
          '${job.name}, ${job.status.label}, ${job.stage} stage, '
          '$duration$failurePolicy.',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gs.surfaceCard,
            border: Border(
              top: isFirst
                  ? BorderSide(color: gs.borderSubtle)
                  : BorderSide.none,
              left: BorderSide(color: gs.borderSubtle),
              right: BorderSide(color: gs.borderSubtle),
              bottom: BorderSide(color: gs.borderSubtle),
            ),
            borderRadius: radius,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                children: [
                  CiStatusBadge(
                    status: job.badgeStatus,
                    size: 20,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          job.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: gs.textHeading,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.allowFailure
                              ? '${job.stage} · $duration · allowed to fail'
                              : '${job.stage} · $duration',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: gs.caption.copyWith(color: gs.textSubtle),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 116),
                    child: Text(
                      job.status.label,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: gs.caption.copyWith(color: gs.textSubtle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PipelineInitialState extends StatelessWidget {
  const _PipelineInitialState({
    required this.loading,
    required this.failed,
  });

  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (!failed) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load this pipeline.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check your connection.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, List<PipelineJob>> _groupJobsByStage(List<PipelineJob> jobs) {
  final stages = <String, List<PipelineJob>>{};
  for (final job in jobs) {
    stages.putIfAbsent(job.stage, () => []).add(job);
  }
  return stages;
}

List<Widget> _jobSlivers(BuildContext context, List<PipelineJob> jobs) {
  final theme = Theme.of(context);
  final gs = theme.extension<GsTheme>()!;
  if (jobs.isEmpty) {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 36, 16, 48),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              Text(
                'No jobs in this pipeline.',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: gs.textHeading,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Jobs will appear when GitLab creates them.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: gs.textSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  final stages = _groupJobsByStage(jobs);
  return [
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          header: true,
          child: Text(
            'Jobs · ${jobs.length}',
            style: theme.textTheme.titleSmall?.copyWith(color: gs.textHeading),
          ),
        ),
      ),
    ),
    for (final stage in stages.entries) ...[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 7),
        sliver: SliverToBoxAdapter(
          child: Text(
            stage.key.toUpperCase(),
            style: gs.caption.copyWith(
              color: gs.textSubtle,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: stage.value.length,
          itemBuilder: (context, index) => _JobRow(
            job: stage.value[index],
            isFirst: index == 0,
            isLast: index == stage.value.length - 1,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ],
    const SliverToBoxAdapter(child: SizedBox(height: 16)),
  ];
}

String formatCiDuration(num? seconds) {
  if (seconds == null) return 'Not started';
  final totalSeconds = seconds.round();
  if (totalSeconds < 60) return '${totalSeconds}s';
  final minutes = totalSeconds ~/ 60;
  final remainingSeconds = totalSeconds % 60;
  if (minutes < 60) {
    return remainingSeconds == 0
        ? '${minutes}m'
        : '${minutes}m ${remainingSeconds}s';
  }
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  return remainingMinutes == 0 ? '${hours}h' : '${hours}h ${remainingMinutes}m';
}

String formatPipelineSource(String source) => switch (source) {
  'push' => 'Push',
  'web' => 'Run from GitLab',
  'trigger' => 'Trigger',
  'schedule' => 'Schedule',
  'api' => 'API',
  'external' => 'External',
  'pipeline' => 'Child pipeline',
  'chat' => 'Chat',
  'webide' => 'Web IDE',
  'merge_request_event' => 'Merge request',
  'external_pull_request_event' => 'External pull request',
  'parent_pipeline' => 'Parent pipeline',
  'ondemand_dast_scan' => 'On-demand DAST scan',
  'ondemand_dast_validation' => 'On-demand DAST validation',
  'security_orchestration_policy' => 'Security policy',
  _ => 'Pipeline',
};
