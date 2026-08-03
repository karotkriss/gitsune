import 'dart:convert';

import 'package:gitsune/core/diff/diff_file.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_discussion_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';

import '../../../support/fixtures.dart';

class FixtureMergeRequestsRepository implements MergeRequestsRepository {
  FixtureMergeRequestsRepository({
    this.diffFixtures = const [
      'merge_request_142_diffs_page1',
      'merge_request_142_diffs_page2',
    ],
    this.discussionFixtures = const [
      'merge_request_142_discussions_page1',
      'merge_request_142_discussions_page2',
    ],
  }) : _firstPage = _mergeRequestsFrom('merge_requests_page1'),
       _secondPage = _mergeRequestsFrom('merge_requests_page2'),
       _mergeRequest = _mergeRequestFrom('merge_request_142'),
       _pipelines = _pipelinesFrom([
         'merge_request_142_pipelines_page1',
         'merge_request_142_pipelines_page2',
       ]),
       _approvals = MergeRequestApprovals.fromJson(
         Map<String, dynamic>.from(
           Fixtures.json('merge_request_142_approvals') as Map,
         ),
       );

  final List<String> diffFixtures;
  final List<String> discussionFixtures;
  final List<MergeRequest> _firstPage;
  final List<MergeRequest> _secondPage;
  final MergeRequest _mergeRequest;
  final List<MergeRequestPipeline> _pipelines;
  final MergeRequestApprovals _approvals;
  int firstPageLoads = 0;
  int nextPageLoads = 0;
  int detailLoads = 0;
  String? lastCreatedBody;
  DiffPosition? lastCreatedPosition;
  List<Map<String, dynamic>>? _rawDiscussions;

  List<Map<String, dynamic>> get _discussions =>
      _rawDiscussions ??= discussionFixtures
          .expand((fixture) => Fixtures.json(fixture) as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList();

  @override
  Future<MergeRequestPage> loadFirstPage(int projectId) async {
    firstPageLoads++;
    return MergeRequestPage(items: _firstPage, hasMore: true);
  }

  @override
  Future<MergeRequestPage> loadNextPage(int projectId) async {
    nextPageLoads++;
    return MergeRequestPage(items: _secondPage, hasMore: false);
  }

  @override
  Future<MergeRequest> loadMergeRequest(int projectId, int mergeIid) async {
    detailLoads++;
    return _mergeRequest;
  }

  @override
  Future<MergeRequestPipelinePage> loadFirstPipelinePage(
    int projectId,
    int mergeIid,
  ) async => MergeRequestPipelinePage(items: _pipelines, hasMore: false);

  @override
  Future<MergeRequestPipelinePage> loadNextPipelinePage(
    int projectId,
    int mergeIid,
  ) async => const MergeRequestPipelinePage(items: [], hasMore: false);

  @override
  Future<MergeRequestApprovals> loadApprovals(
    int projectId,
    int mergeIid,
  ) async {
    return _approvals;
  }

  @override
  Future<List<DiffFile>> loadDiffs(int projectId, int mergeIid) async =>
      diffFixtures
          .expand((fixture) => Fixtures.json(fixture) as List)
          .map(
            (value) =>
                DiffFile.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false);

  @override
  Future<List<Discussion>> loadDiscussions(int projectId, int mergeIid) async =>
      _discussions.map(Discussion.fromJson).toList(growable: false);

  @override
  Future<Discussion> createDiffDiscussion(
    int projectId,
    int mergeIid, {
    required String body,
    required DiffPosition position,
  }) async {
    lastCreatedBody = body;
    lastCreatedPosition = position;
    return Discussion.fromJson(
      Map<String, dynamic>.from(
        Fixtures.json('merge_request_142_discussion_created') as Map,
      ),
    );
  }

  @override
  Future<Discussion> setDiscussionResolved(
    int projectId,
    int mergeIid,
    String discussionId, {
    required bool resolved,
  }) async {
    final raw = _discussions.firstWhere(
      (discussion) => discussion['id'] == discussionId,
    );
    final copy = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    for (final note in copy['notes'] as List) {
      final noteMap = note as Map;
      if (noteMap['resolvable'] == true) noteMap['resolved'] = resolved;
    }
    return Discussion.fromJson(copy);
  }
}

List<MergeRequest> _mergeRequestsFrom(String fixture) =>
    (Fixtures.json(fixture) as List)
        .map(
          (value) =>
              MergeRequest.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(growable: false);

MergeRequest _mergeRequestFrom(String fixture) => MergeRequest.fromJson(
  Map<String, dynamic>.from(Fixtures.json(fixture) as Map),
);

List<MergeRequestPipeline> _pipelinesFrom(List<String> fixtures) => fixtures
    .expand((fixture) => Fixtures.json(fixture) as List)
    .map(
      (value) => MergeRequestPipeline.fromJson(
        Map<String, dynamic>.from(value as Map),
      ),
    )
    .toList(growable: false);
