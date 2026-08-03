import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/account_key.dart';
import '../../../core/network/connectivity.dart';
import 'issue_models.dart';
import 'issues_repository.dart';

/// A note created by flushing a queued draft, so the issue's thread can fold
/// it into local state without a refetch (the E6.2 pattern).
typedef SentCommentDraft = ({int projectId, int issueIid, IssueNote note});
typedef LoadRecentIssueNotes =
    Future<List<IssueNote>> Function(int projectId, int issueIid);

/// The E14.2 account-scoped offline comment outbox, backed by
/// [AppDatabase.commentDrafts].
///
/// Every send routes through the queue: [send] persists the draft first and
/// then attempts a flush, so an online send completes in one round trip while
/// an offline one stays durably queued, and a new comment never overtakes
/// drafts already waiting. [flush] runs again on every [onReconnect] event.
///
/// Failure policy: a connectivity failure or transient server error (5xx)
/// keeps the draft queued for the next reconnect; a permanent rejection (a
/// non-connectivity 4xx, e.g. 403) marks the draft failed via
/// [CommentDraft.lastError] so it is surfaced instead of retried forever.
class CommentDraftQueue {
  CommentDraftQueue({
    required this.database,
    required this.account,
    required this.repository,
    required this.loadRecentNotes,
    required Stream<void> onReconnect,
    DateTime Function() now = DateTime.now,
    this.retryBackoff = const Duration(seconds: 30),
  }) : _now = now {
    _reconnectSubscription = onReconnect.listen(
      (_) => unawaited(_flushBestEffort()),
    );
  }

  final AppDatabase database;
  final AccountKey account;
  final IssuesRepository repository;
  final LoadRecentIssueNotes loadRecentNotes;
  final Duration retryBackoff;
  final DateTime Function() _now;

  final _sentController = StreamController<SentCommentDraft>.broadcast();
  late final StreamSubscription<void> _reconnectSubscription;
  bool _flushing = false;
  bool _flushRequested = false;

  /// Notes created by flushed drafts, for folding into thread state.
  Stream<SentCommentDraft> get sentNotes => _sentController.stream;

  /// The reactive account-scoped read of one issue's drafts, oldest first.
  Stream<List<CommentDraft>> watchDrafts(int projectId, int issueIid) {
    final query = database.select(database.commentDrafts)
      ..where(
        (t) =>
            _accountScope(t) &
            t.projectId.equals(projectId) &
            t.issueIid.equals(issueIid),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.draftId)]);
    return query.watch();
  }

  /// Persists [body] as a queued draft and attempts a flush.
  Future<void> send(int projectId, int issueIid, String body) async {
    await database.transaction(() async {
      final draftId = database.commentDrafts.draftId.max();
      final persistedMaximum = database.selectOnly(database.commentDrafts)
        ..addColumns([draftId])
        ..where(_accountScope(database.commentDrafts));
      final persistedId =
          (await persistedMaximum.getSingle()).read(draftId) ?? 0;
      final now = _now().microsecondsSinceEpoch;
      await database
          .into(database.commentDrafts)
          .insert(
            CommentDraftsCompanion.insert(
              instanceHost: account.instanceHost,
              accountId: account.accountId,
              draftId: now > persistedId ? now : persistedId + 1,
              projectId: projectId,
              issueIid: issueIid,
              body: body,
            ),
          );
    });
    await _flushBestEffort();
  }

  /// Removes a draft without sending it (e.g. to move a rejected draft's
  /// body back into the composer for editing).
  Future<void> discard(int draftId) async {
    await (database.delete(
      database.commentDrafts,
    )..where((t) => _accountScope(t) & t.draftId.equals(draftId))).go();
  }

  /// Sends this account's queued drafts in order, applying the class-level
  /// failure policy. Only one pass runs at a time; a flush requested while
  /// one is active runs as an extra pass afterwards.
  Future<void> flush() async {
    if (_flushing) {
      _flushRequested = true;
      return;
    }
    _flushing = true;
    try {
      do {
        _flushRequested = false;
        final drafts =
            await (database.select(database.commentDrafts)
                  ..where((t) => _accountScope(t) & t.lastError.isNull())
                  ..orderBy([(t) => OrderingTerm.asc(t.draftId)]))
                .get();
        for (final draft in drafts) {
          if (!await _sendDraft(draft)) return;
        }
      } while (_flushRequested);
    } finally {
      _flushing = false;
    }
  }

  /// Sends one draft; returns whether the pass should continue.
  Future<bool> _sendDraft(CommentDraft draft) async {
    final now = _now();
    if (draft.retryAfter case final retryAfter? when now.isBefore(retryAfter)) {
      return false;
    }
    if (draft.ambiguousSince != null) {
      final reconciled = await _reconcile(draft);
      if (reconciled == null) return false;
      if (reconciled) return true;
      await _updateDraft(
        draft.draftId,
        const CommentDraftsCompanion(
          ambiguousSince: Value(null),
          retryAfter: Value(null),
        ),
      );
    }
    try {
      final note = await repository.createNote(
        draft.projectId,
        draft.issueIid,
        draft.body,
      );
      await discard(draft.draftId);
      _sentController.add((
        projectId: draft.projectId,
        issueIid: draft.issueIid,
        note: note,
      ));
      return true;
    } on Object catch (error, stackTrace) {
      final status = error is DioException ? error.response?.statusCode : null;
      if (error is DioException && _isPermanentRejection(status)) {
        // Permanent rejection: surface it and let later drafts still send.
        await _updateDraft(
          draft.draftId,
          CommentDraftsCompanion(lastError: Value('HTTP $status')),
        );
        return true;
      }
      if (error is DioException && (status == 408 || status == 429)) {
        await _updateDraft(
          draft.draftId,
          CommentDraftsCompanion(retryAfter: Value(_retryAfter(error, now))),
        );
        return false;
      }
      if (error is DioException && hasAmbiguousRequestOutcome(error)) {
        await _updateDraft(
          draft.draftId,
          CommentDraftsCompanion(ambiguousSince: Value(now)),
        );
        return false;
      }
      if (error is! DioException) {
        log(
          'Unable to send a queued comment draft',
          name: 'gitsune.comment_drafts',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Offline or transient: stop and keep the rest queued for the next
      // reconnect.
      return false;
    }
  }

  Future<bool?> _reconcile(CommentDraft draft) async {
    try {
      final notes = await loadRecentNotes(draft.projectId, draft.issueIid);
      final ambiguousSince = draft.ambiguousSince!;
      final earliest = ambiguousSince.subtract(const Duration(minutes: 2));
      final latest = ambiguousSince.add(const Duration(minutes: 2));
      for (final note in notes) {
        if (note.body == draft.body &&
            note.author.id.toString() == account.accountId &&
            !note.createdAt.isBefore(earliest) &&
            !note.createdAt.isAfter(latest)) {
          await discard(draft.draftId);
          _sentController.add((
            projectId: draft.projectId,
            issueIid: draft.issueIid,
            note: note,
          ));
          return true;
        }
      }
      return false;
    } on Object catch (error, stackTrace) {
      log(
        'Unable to reconcile an ambiguous comment draft',
        name: 'gitsune.comment_drafts',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  bool _isPermanentRejection(int? status) =>
      status == 400 ||
      status == 401 ||
      status == 403 ||
      status == 404 ||
      status == 422;

  DateTime _retryAfter(DioException error, DateTime now) {
    final value = error.response?.headers.value('retry-after');
    final seconds = value == null ? null : int.tryParse(value);
    return now.add(seconds == null ? retryBackoff : Duration(seconds: seconds));
  }

  Future<void> _updateDraft(int draftId, CommentDraftsCompanion companion) =>
      (database.update(database.commentDrafts)
            ..where((t) => _accountScope(t) & t.draftId.equals(draftId)))
          .write(companion);

  Future<void> _flushBestEffort() async {
    try {
      await flush();
    } on Object catch (error, stackTrace) {
      log(
        'Unable to flush queued comment drafts',
        name: 'gitsune.comment_drafts',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Expression<bool> _accountScope($CommentDraftsTable t) =>
      t.instanceHost.equals(account.instanceHost) &
      t.accountId.equals(account.accountId);

  Future<void> dispose() async {
    await _reconnectSubscription.cancel();
    await _sentController.close();
  }
}
