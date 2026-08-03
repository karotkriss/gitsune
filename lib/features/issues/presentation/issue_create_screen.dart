import 'package:flutter/material.dart';

import '../../../core/icons/gs_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../data/issue_models.dart';
import '../data/issues_repository.dart';
import 'issue_components.dart';

/// New-issue form: title, markdown description with live preview, and a
/// Create action that POSTs through the repository and pops with the created
/// [Issue] so the caller can fold it into its own state.
class IssueCreateScreen extends StatefulWidget {
  const IssueCreateScreen({
    super.key,
    required this.projectId,
    required this.projectPath,
    required this.repository,
  });

  final int projectId;
  final String projectPath;
  final IssuesRepository repository;

  @override
  State<IssueCreateScreen> createState() => _IssueCreateScreenState();
}

class _IssueCreateScreenState extends State<IssueCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting && _titleController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final description = normalizeIssueDraft(_descriptionController.text);
    setState(() => _submitting = true);
    try {
      final issue = await widget.repository.createIssue(
        widget.projectId,
        title: _titleController.text.trim(),
        description: description,
      );
      if (!mounted) return;
      Navigator.of(context).pop(issue);
    } on Object {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create the issue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final description = normalizeIssueDraft(_descriptionController.text);
    return Scaffold(
      backgroundColor: gs.surfaceSubtle,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: gs.surfaceApp,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: GsIcon(GsIconGlyph.chevronLeft, size: 20, color: gs.accent),
        ),
        title: Text(
          'New issue',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
        actions: [
          if (_submitting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _canSubmit ? _submit : null,
              child: const Text('Create'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.projectPath,
            style: gs.mono.copyWith(color: gs.textSubtle),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            enabled: !_submitting,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            enabled: !_submitting,
            minLines: 4,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the issue (Markdown supported)',
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          IssueDraftPreview(draft: description),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
