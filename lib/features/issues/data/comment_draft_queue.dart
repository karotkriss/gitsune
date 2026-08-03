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
    required Stream<void> onReconnect,
  }) {
    _reconnectSubscription = onReconnect.listen((_) => flush());
  }

  final AppDatabase database;
  final AccountKey account;
  final IssuesRepository repository;

  final _sentController = StreamController<SentCommentDraft>.broadcast();
  late final StreamSubscription<void> _reconnectSubscription;
  int _lastDraftId = 0;
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
    await database
        .into(database.commentDrafts)
        .insert(
          CommentDraftsCompanion.insert(
            instanceHost: account.instanceHost,
            accountId: account.accountId,
            draftId: _nextDraftId(),
            projectId: projectId,
            issueIid: issueIid,
            body: body,
          ),
        );
    await flush();
  }

  /// Removes a draft without sending it (e.g. to move a rejected draft's
  /// body back into the composer for editing).
  Future<void> discard(int draftId) async {
    await (database.delete(database.commentDrafts)..where(
          (t) => _accountScope(t) & t.draftId.equals(draftId),
        ))
        .go();
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
      if (error is DioException &&
          !isConnectivityError(error) &&
          status != null &&
          status >= 400 &&
          status < 500) {
        // Permanent rejection: surface it and let later drafts still send.
        await (database.update(database.commentDrafts)..where(
              (t) => _accountScope(t) & t.draftId.equals(draft.draftId),
            ))
            .write(CommentDraftsCompanion(lastError: Value('HTTP $status')));
        return true;
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

  /// Client-assigned queue position: creation time in microseconds, bumped
  /// past the last issued id when two drafts land in the same microsecond.
  int _nextDraftId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _lastDraftId = now > _lastDraftId ? now : _lastDraftId + 1;
    return _lastDraftId;
  }

  Expression<bool> _accountScope($CommentDraftsTable t) =>
      t.instanceHost.equals(account.instanceHost) &
      t.accountId.equals(account.accountId);

  Future<void> dispose() async {
    await _reconnectSubscription.cancel();
    await _sentController.close();
  }
}
