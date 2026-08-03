import 'package:flutter/material.dart';

import '../../../core/ansi/ansi_log_parser.dart';
import '../../../core/ci/ci_status_badge.dart';
import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/pipeline_models.dart';
import '../data/pipelines_repository.dart';

/// The standard 16-color ANSI palette tuned for the dark log surface. Fixed
/// rather than themed for the same reason as the CI badge colors: terminal
/// colors are part of the log's meaning, not the app's brand.
const _ansiColors = <Color>[
  Color(0xFF6E6E6E), // black, lifted so it stays visible on the dark surface
  Color(0xFFF66151), // red
  Color(0xFF33D17A), // green
  Color(0xFFE9AD0C), // yellow
  Color(0xFF5B9BF8), // blue
  Color(0xFFC061CB), // magenta
  Color(0xFF33C7DE), // cyan
  Color(0xFFD0CFCC), // white
  Color(0xFF9A9996), // bright black
  Color(0xFFFF7B63), // bright red
  Color(0xFF57E389), // bright green
  Color(0xFFF8E45C), // bright yellow
  Color(0xFF82AFFF), // bright blue
  Color(0xFFDC8ADD), // bright magenta
  Color(0xFF66E0EE), // bright cyan
  Color(0xFFFFFFFF), // bright white
];

/// A CI job's trace log: a header with the job's name, status badge, and
/// ref, above the parsed, virtualized log body.
class JobLogScreen extends StatefulWidget {
  const JobLogScreen({
    super.key,
    required this.projectId,
    required this.jobId,
    required this.repository,
    this.job,
    this.ref,
  });

  final int projectId;
  final int jobId;
  final PipelinesRepository repository;

  /// The job as already loaded by the pipeline surface; null on a direct
  /// deep link, which falls back to the job id alone.
  final PipelineJob? job;

  /// The pipeline's ref, shown in the header when known.
  final String? ref;

  @override
  State<JobLogScreen> createState() => _JobLogScreenState();
}

class _JobLogScreenState extends State<JobLogScreen> {
  List<AnsiLine>? _lines;
  bool _loading = true;
  bool _failed = false;
  int _loadGeneration = 0;

  String get _jobName => widget.job?.name ?? 'Job #${widget.jobId}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant JobLogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.jobId != widget.jobId ||
        oldWidget.repository != widget.repository) {
      _lines = null;
      _load();
    }
  }

  Future<void> _load() async {
    final loadGeneration = ++_loadGeneration;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final trace = await widget.repository.loadJobLog(
        widget.projectId,
        widget.jobId,
      );
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        // ponytail: parsed on the UI thread; move to an isolate if traces
        // beyond a few megabytes measurably stall the frame.
        _lines = parseAnsiLog(trace);
        _loading = false;
      });
    } on Object {
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      if (_lines != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to refresh this job log.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final lines = _lines;
    return Scaffold(
      backgroundColor: gs.codeBg,
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
          _jobName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: gs.mono.copyWith(
            color: gs.textHeading,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _JobLogHeader(jobName: _jobName, job: widget.job, ref: widget.ref),
          if (_loading && lines != null)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: lines == null
                ? _JobLogInitialState(loading: _loading, failed: _failed)
                : RefreshIndicator(
                    onRefresh: _load,
                    color: gs.accent,
                    child: _JobLogBody(lines: lines),
                  ),
          ),
        ],
      ),
    );
  }
}

class _JobLogHeader extends StatelessWidget {
  const _JobLogHeader({required this.jobName, this.job, this.ref});

  final String jobName;
  final PipelineJob? job;
  final String? ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final job = this.job;
    final ref = this.ref;
    return Semantics(
      container: true,
      label:
          '$jobName${job == null ? '' : ', ${job.status.label}'}'
          '${ref == null ? '' : ', ref $ref'}.',
      child: ExcludeSemantics(
        child: ColoredBox(
          color: gs.surfaceApp,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                if (job != null) ...[
                  CiStatusBadge(
                    status: job.badgeStatus,
                    size: 24,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job?.status.label ?? jobName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: gs.textHeading,
                        ),
                      ),
                      if (job != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${job.stage} stage',
                          style: gs.caption.copyWith(color: gs.textSubtle),
                        ),
                      ],
                    ],
                  ),
                ),
                if (ref != null) ...[
                  const SizedBox(width: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: gs.surfaceStrong,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        ref,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: gs.mono.copyWith(color: gs.textDefault),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobLogBody extends StatelessWidget {
  const _JobLogBody({required this.lines});

  final List<AnsiLine> lines;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final base = gs.mono.copyWith(color: gs.textDefault);
    if (lines.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'This job has no log yet.',
            style: base.copyWith(color: gs.textSubtle),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        return Text.rich(
          line.spans.isEmpty
              ? const TextSpan(text: '')
              : TextSpan(
                  children: [
                    for (final span in line.spans)
                      TextSpan(
                        text: span.text,
                        style: span.fgIndex == null && !span.bold
                            ? null
                            : TextStyle(
                                color: span.fgIndex == null
                                    ? null
                                    : _ansiColors[span.fgIndex!],
                                fontWeight: span.bold ? FontWeight.w600 : null,
                              ),
                      ),
                  ],
                ),
          style: base,
        );
      },
    );
  }
}

class _JobLogInitialState extends StatelessWidget {
  const _JobLogInitialState({required this.loading, required this.failed});

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
              'Unable to load this job log.',
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
