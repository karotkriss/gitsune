import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../core/ci/ci_status.dart';
import '../../core/ci/ci_status_badge.dart';
import '../../core/database/app_database.dart';
import '../../core/glass/glass_overlays.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/repository/offline_first_repository.dart';
import '../../core/theme/app_theme.dart';

enum _TodoTriageAction { done, snooze }

/// To-Do List bound to the offline-first repository's reactive cache stream.
///
/// E5.1 intentionally exposes a read-only collection seam. Until a later data
/// task adds reversible write operations for every target type, swipe triage
/// is session-local presentation state. That keeps both actions immediately
/// undoable without inventing a partial server-side restore protocol.
class TodosScreen extends StatefulWidget {
  const TodosScreen({
    super.key,
    this.repository = const _EmptyTodosRepository(),
    this.onTodoTap,
    this.now,
  });

  final OfflineFirstRepository<List<TodoItem>> repository;
  final ValueChanged<TodoItem>? onTodoTap;
  final DateTime? now;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _triagedTodoIds = <int>{};
  late Stream<List<TodoItem>> _todos;
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    _bindRepository();
  }

  @override
  void didUpdateWidget(covariant TodosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _triagedTodoIds.clear();
      _selectedReason = null;
      _bindRepository();
    }
  }

  void _bindRepository() {
    _todos = widget.repository.watch();
    unawaited(widget.repository.refresh());
  }

  Future<void> _refresh() => widget.repository.refresh();

  void _triage(TodoItem todo, _TodoTriageAction action) {
    setState(() => _triagedTodoIds.add(todo.todoId));
    _showUndo(todo, action);
  }

  void _showUndo(TodoItem todo, _TodoTriageAction action) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final message = switch (action) {
      _TodoTriageAction.done => 'To-do marked as done.',
      _TodoTriageAction.snooze => 'To-do snoozed.',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.zero,
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: GlassSurface(
          intensity: GlassIntensity.modest,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              children: [
                Expanded(child: Text(message)),
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() => _triagedTodoIds.remove(todo.todoId));
                    ScaffoldMessenger.of(
                      context,
                    ).hideCurrentSnackBar(reason: SnackBarClosedReason.action);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: gs.accentSelectedText,
                  ),
                  child: const Text('Undo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterSheet(List<TodoItem> todos) async {
    final reasons = _availableReasons(todos);
    final selection = await showModalBottomSheet<_ReasonSelection>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _ReasonFilterSheet(reasons: reasons, selectedReason: _selectedReason),
    );
    if (!mounted || selection == null) return;
    setState(() => _selectedReason = selection.actionName);
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      backgroundColor: gs.surfaceApp,
      body: SafeArea(
        child: StreamBuilder<List<TodoItem>>(
          stream: _todos,
          builder: (context, snapshot) => Column(
            children: [
              _TodosHeader(
                selectedReason: _selectedReason,
                onFilter: () => _showFilterSheet(snapshot.data ?? const []),
              ),
              Expanded(
                child: snapshot.hasError
                    ? _TodosMessageScrollView(
                        title: 'Unable to load to-dos.',
                        detail: 'Try refreshing the list.',
                        actionLabel: 'Try again',
                        onAction: _refresh,
                      )
                    : !snapshot.hasData
                    ? const _TodoListLoading()
                    : _buildList(snapshot.data!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<TodoItem> todos) {
    final visibleTodos = todos
        .where(
          (todo) =>
              !_triagedTodoIds.contains(todo.todoId) &&
              (_selectedReason == null || todo.actionName == _selectedReason),
        )
        .toList(growable: false);
    final filtered = _selectedReason != null;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Theme.of(context).extension<GsTheme>()!.accent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (visibleTodos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _TodosMessage(
                title: filtered
                    ? 'No ${todoReasonLabel(_selectedReason!).toLowerCase()} to-dos.'
                    : 'All done.',
                detail: filtered
                    ? 'Try another reason or show every to-do.'
                    : 'New to-dos will appear here.',
                actionLabel: filtered ? 'Show all' : null,
                onAction: filtered
                    ? () => setState(() => _selectedReason = null)
                    : null,
              ),
            )
          else ...[
            SliverList.builder(
              itemCount: visibleTodos.length,
              itemBuilder: (context, index) {
                final todo = visibleTodos[index];
                return Dismissible(
                  key: ValueKey('todo-row-${todo.todoId}'),
                  direction: DismissDirection.horizontal,
                  dismissThresholds: const {
                    DismissDirection.startToEnd: 0.35,
                    DismissDirection.endToStart: 0.35,
                  },
                  background: const _SwipeActionBackground(
                    alignment: Alignment.centerLeft,
                    action: _TodoTriageAction.done,
                  ),
                  secondaryBackground: const _SwipeActionBackground(
                    alignment: Alignment.centerRight,
                    action: _TodoTriageAction.snooze,
                  ),
                  onDismissed: (direction) => _triage(
                    todo,
                    direction == DismissDirection.startToEnd
                        ? _TodoTriageAction.done
                        : _TodoTriageAction.snooze,
                  ),
                  child: _TodoListRow(
                    todo: todo,
                    now: widget.now ?? DateTime.now(),
                    onTap: widget.onTodoTap == null
                        ? null
                        : () => widget.onTodoTap!(todo),
                    onDone: () => _triage(todo, _TodoTriageAction.done),
                    onSnooze: () => _triage(todo, _TodoTriageAction.snooze),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: _SwipeHint()),
          ],
        ],
      ),
    );
  }
}

class _TodosHeader extends StatelessWidget {
  const _TodosHeader({required this.selectedReason, required this.onFilter});

  final String? selectedReason;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final label = selectedReason == null
        ? 'Filter'
        : todoReasonLabel(selectedReason!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text('To-Do List', style: gs.screenTitle)),
          TextButton.icon(
            key: const ValueKey('todo-filter-button'),
            onPressed: onFilter,
            icon: const GsIcon(GsIconGlyph.filter, size: 16),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 144),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            style: TextButton.styleFrom(foregroundColor: gs.accent),
          ),
        ],
      ),
    );
  }
}

class _TodoListRow extends StatelessWidget {
  const _TodoListRow({
    required this.todo,
    required this.now,
    required this.onTap,
    required this.onDone,
    required this.onSnooze,
  });

  final TodoItem todo;
  final DateTime now;
  final VoidCallback? onTap;
  final VoidCallback onDone;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    final reference = _todoReference(todo);
    final projectAndReference = [
      todo.projectPathWithNamespace,
      reference,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' ');
    final title = _todoTitle(todo);
    final note = todo.body.isNotEmpty && todo.body != title
        ? todo.body
        : todoReasonLabel(todo.actionName);
    final time = formatTodoRelativeTime(todo.createdAt, now);
    final semanticLabel = [
      title,
      if (projectAndReference.isNotEmpty) projectAndReference,
      note,
      todoReasonLabel(todo.actionName),
      time,
      'Swipe right to mark done or left to snooze.',
    ].join('. ');

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      onTap: onTap,
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Mark as done'): onDone,
        const CustomSemanticsAction(label: 'Snooze'): onSnooze,
      },
      child: ExcludeSemantics(
        child: Material(
          color: gs.surfaceApp,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: gs.borderSubtle)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                  child: Row(
                    children: [
                      _todoLeading(todo.targetType, gs),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: gs.textDefault,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(
                                children: [
                                  if (projectAndReference.isNotEmpty)
                                    TextSpan(
                                      text: projectAndReference,
                                      style: gs.mono.copyWith(
                                        color: gs.textSubtle,
                                        fontSize: 12,
                                        height: 16 / 12,
                                      ),
                                    ),
                                  if (projectAndReference.isNotEmpty)
                                    const TextSpan(text: ' · '),
                                  TextSpan(text: note),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: gs.caption.copyWith(color: gs.textSubtle),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            time,
                            style: gs.caption.copyWith(color: gs.textSubtle),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Mark as done',
                        onPressed: onDone,
                        color: gs.statusSuccess,
                        icon: const GsIcon(GsIconGlyph.checkCircle, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({required this.alignment, required this.action});

  final Alignment alignment;
  final _TodoTriageAction action;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final done = action == _TodoTriageAction.done;
    return ExcludeSemantics(
      child: ColoredBox(
        color: done ? gs.feedbackSuccessBg : gs.feedbackWarningBg,
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!done) ...[
                  Text(
                    'Snooze',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: gs.feedbackWarningText,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                GsIcon(
                  done ? GsIconGlyph.checkCircle : GsIconGlyph.clock,
                  size: 20,
                  color: done ? gs.feedbackSuccessText : gs.feedbackWarningText,
                ),
                if (done) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Done',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: gs.feedbackSuccessText,
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

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Text(
        'Swipe right to mark done · swipe left to snooze',
        textAlign: TextAlign.center,
        style: gs.caption.copyWith(color: gs.textSubtle),
      ),
    );
  }
}

class _ReasonFilterSheet extends StatelessWidget {
  const _ReasonFilterSheet({
    required this.reasons,
    required this.selectedReason,
  });

  final List<String> reasons;
  final String? selectedReason;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final availableHeight = MediaQuery.sizeOf(context).height * 0.8;
    final desiredHeight = 76.0 + (reasons.length + 1) * 49;
    final height = desiredHeight < availableHeight
        ? desiredHeight
        : availableHeight;
    final options = <String?>[null, ...reasons];

    return SizedBox(
      height: height,
      child: GlassBottomSheet(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Filter by reason',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final reason = options[index];
                  final selected = reason == selectedReason;
                  return InkWell(
                    key: ValueKey('todo-filter-${reason ?? 'all'}'),
                    onTap: () =>
                        Navigator.of(context).pop(_ReasonSelection(reason)),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: index == options.length - 1
                              ? null
                              : Border(
                                  bottom: BorderSide(color: gs.borderSubtle),
                                ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reason == null
                                      ? 'All'
                                      : todoReasonLabel(reason),
                                ),
                              ),
                              if (selected)
                                GsIcon(
                                  GsIconGlyph.check,
                                  size: 16,
                                  color: gs.accent,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonSelection {
  const _ReasonSelection(this.actionName);

  final String? actionName;
}

class _TodoListLoading extends StatelessWidget {
  const _TodoListLoading();

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: gs.borderSubtle)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: gs.surfaceStrong,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: index.isEven ? 0.72 : 0.58,
                    child: Container(height: 12, color: gs.surfaceStrong),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: index.isEven ? 0.48 : 0.64,
                    child: Container(height: 8, color: gs.surfaceStrong),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodosMessageScrollView extends StatelessWidget {
  const _TodosMessageScrollView({
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _TodosMessage(
            title: title,
            detail: detail,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
      ],
    );
  }
}

class _TodosMessage extends StatelessWidget {
  const _TodosMessage({
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: gs.textSubtle),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyTodosRepository implements OfflineFirstRepository<List<TodoItem>> {
  const _EmptyTodosRepository();

  @override
  Future<void> refresh() async {}

  @override
  Stream<List<TodoItem>> watch() => Stream.value(const []);
}

List<String> _availableReasons(List<TodoItem> todos) {
  const preferredOrder = [
    'assigned',
    'mentioned',
    'directly_addressed',
    'review_requested',
    'approval_required',
    'build_failed',
    'unmergeable',
    'merge_train_removed',
    'member_access_requested',
    'marked',
  ];
  final reasons = todos.map((todo) => todo.actionName).toSet().toList();
  reasons.sort((left, right) {
    final leftRank = preferredOrder.indexOf(left);
    final rightRank = preferredOrder.indexOf(right);
    if (leftRank >= 0 && rightRank >= 0) return leftRank.compareTo(rightRank);
    if (leftRank >= 0) return -1;
    if (rightRank >= 0) return 1;
    return todoReasonLabel(left).compareTo(todoReasonLabel(right));
  });
  return reasons;
}

String todoReasonLabel(String actionName) => switch (actionName) {
  'assigned' => 'Assigned',
  'mentioned' => 'Mentioned',
  'directly_addressed' => 'Directly addressed',
  'review_requested' => 'Review requested',
  'approval_required' => 'Approval required',
  'build_failed' => 'Pipeline failed',
  'unmergeable' => 'Unmergeable',
  'merge_train_removed' => 'Removed from merge train',
  'member_access_requested' => 'Access requested',
  'marked' => 'Marked',
  _ => _sentenceCase(actionName.replaceAll('_', ' ')),
};

String formatTodoRelativeTime(DateTime createdAt, DateTime now) {
  final difference = now.toUtc().difference(createdAt.toUtc());
  if (difference.isNegative || difference.inMinutes < 1) return 'now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inDays < 1) return '${difference.inHours}h';
  if (difference.inDays < 7) return '${difference.inDays}d';
  if (difference.inDays < 365) return '${difference.inDays ~/ 7}w';
  return '${difference.inDays ~/ 365}y';
}

String _todoTitle(TodoItem todo) {
  final targetTitle = todo.targetTitle?.trim();
  if (targetTitle != null && targetTitle.isNotEmpty) return targetTitle;
  final body = todo.body.trim();
  if (body.isNotEmpty) return body;
  return todoReasonLabel(todo.actionName);
}

String? _todoReference(TodoItem todo) {
  final targetIid = todo.targetIid ?? _trailingUrlId(todo.targetUrl);
  if (targetIid == null) return null;
  return switch (todo.targetType) {
    'MergeRequest' => '!$targetIid',
    'Issue' || 'Pipeline' => '#$targetIid',
    _ => null,
  };
}

int? _trailingUrlId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.pathSegments.isEmpty) return null;
  return int.tryParse(uri.pathSegments.last);
}

GsIconGlyph _todoGlyph(String targetType) => switch (targetType) {
  'MergeRequest' => GsIconGlyph.mergeRequest,
  'Issue' => GsIconGlyph.issueOpen,
  _ => GsIconGlyph.comments,
};

Color _todoGlyphColor(GsTheme gs, String targetType) => switch (targetType) {
  'MergeRequest' => gs.statusInfo,
  'Issue' => gs.statusSuccess,
  _ => gs.statusNeutral,
};

Widget _todoLeading(String targetType, GsTheme gs) {
  if (targetType == 'Pipeline') {
    return const CiStatusBadge(
      status: CiStatus.failed,
      size: 20,
      excludeFromSemantics: true,
    );
  }
  return GsIcon(
    _todoGlyph(targetType),
    size: 20,
    color: _todoGlyphColor(gs, targetType),
  );
}

String _sentenceCase(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
