import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitsune/core/database/app_database.dart';
import 'package:gitsune/core/network/account_key.dart';
import 'package:gitsune/core/theme/app_theme.dart';
import 'package:gitsune/features/issues/data/comment_draft_queue.dart';
import 'package:gitsune/features/issues/data/issue_models.dart';
import 'package:gitsune/features/issues/presentation/issue_detail_screen.dart';

import '../support/fixture_issues_repository.dart';

/// The fixture repository with a switchable createNote failure, standing in
/// for the network dropping out and coming back.
class _OutboxTestRepository extends FixtureIssuesRepository {
  DioException? createNoteError;

  @override
  Future<IssueNote> createNote(int projectId, int issueIid, String body) {
    final error = createNoteError;
    if (error != null) throw error;
    return super.createNote(projectId, issueIid, body);
  }
}

class _FailingFlushQueue extends CommentDraftQueue {
  _FailingFlushQueue({
    required super.database,
    required super.account,
    required super.repository,
    required super.loadRecentNotes,
    required super.onReconnect,
  });

  @override
  Future<void> flush() => Future.error(StateError('simulated flush failure'));
}

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 8, 2, 10);
  const account = AccountKey(
    instanceHost: 'gitlab.example.com',
    accountId: '1',
  );

  late AppDatabase database;
  late StreamController<void> reconnect;
  late _OutboxTestRepository repository;
  late CommentDraftQueue queue;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    reconnect = StreamController<void>.broadcast();
    repository = _OutboxTestRepository();
    queue = CommentDraftQueue(
      database: database,
      account: account,
      repository: repository,
      loadRecentNotes: (_, _) async => const [],
      onReconnect: reconnect.stream,
    );
  });

  tearDown(() async {
    await queue.dispose();
    await reconnect.close();
    await database.close();
  });

  Widget screen() => MaterialApp(
    theme: buildAppTheme(),
    home: IssueDetailScreen(
      projectId: 7,
      projectPath: 'gitsune/app',
      issueIid: 142,
      repository: repository,
      draftQueue: queue,
      now: now,
    ),
  );

  testWidgets('a comment composed offline shows as a queued draft and folds '
      'into the thread on reconnect', (tester) async {
    repository.createNoteError = DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.connectionError,
    );
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Filed while offline');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    // Queued, not lost and not an error: the draft card announces the plan.
    expect(repository.createdNotes, isEmpty);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Filed while offline'), findsOneWidget);
    expect(find.text('Will send when back online'), findsOneWidget);

    // Connectivity returns: the flush sends it and the thread gains the note.
    repository.createNoteError = null;
    reconnect.add(null);
    await tester.pumpAndSettle();

    expect(repository.createdNotes.single, (
      projectId: 7,
      issueIid: 142,
      body: 'Filed while offline',
    ));
    expect(find.text('Will send when back online'), findsNothing);
    expect(
      find.textContaining('Confirmed on the latest build.', findRichText: true),
      findsOneWidget,
    );

    // Unmounting cancels the drift stream; elapse its cleanup timer.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('a rejected draft is surfaced and Edit moves it back into the '
      'composer', (tester) async {
    repository.createNoteError = DioException(
      requestOptions: RequestOptions(),
      response: Response(requestOptions: RequestOptions(), statusCode: 403),
      type: DioExceptionType.badResponse,
    );
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Not allowed');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't send (HTTP 403)"), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't send (HTTP 403)"), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Not allowed',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('a local persistence failure preserves the composer and '
      'surfaces an error', (tester) async {
    await database.customStatement('''
      CREATE TRIGGER reject_comment_draft
      BEFORE INSERT ON comment_drafts
      BEGIN
        SELECT RAISE(FAIL, 'simulated persistence failure');
      END
    ''');
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Keep this comment');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Keep this comment',
    );
    expect(find.text('Unable to save the comment.'), findsOneWidget);
    expect(await queue.watchDrafts(7, 142).first, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('a flush failure clears the composer after persistence without '
      'reporting a save error', (tester) async {
    await queue.dispose();
    queue = _FailingFlushQueue(
      database: database,
      account: account,
      repository: repository,
      loadRecentNotes: (_, _) async => const [],
      onReconnect: reconnect.stream,
    );
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Already persisted');
    await tester.pump();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    expect(find.text('Unable to save the comment.'), findsNothing);
    expect(
      (await queue.watchDrafts(7, 142).first).single.body,
      'Already persisted',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
