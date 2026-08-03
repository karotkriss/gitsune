import 'package:gitsune/features/merge_requests/data/merge_request_models.dart';
import 'package:gitsune/features/merge_requests/data/merge_requests_repository.dart';

import '../../../support/fixtures.dart';

class FixtureMergeRequestsRepository implements MergeRequestsRepository {
  FixtureMergeRequestsRepository()
    : _firstPage = _mergeRequestsFrom('merge_requests_page1'),
      _secondPage = _mergeRequestsFrom('merge_requests_page2'),
      _details = MergeRequestDetails(
        mergeRequest: _mergeRequestFrom('merge_request_142'),
        pipelines: _pipelinesFrom([
          'merge_request_142_pipelines_page1',
          'merge_request_142_pipelines_page2',
        ]),
        approvals: MergeRequestApprovals.fromJson(
          Map<String, dynamic>.from(
            Fixtures.json('merge_request_142_approvals') as Map,
          ),
        ),
      );

  final List<MergeRequest> _firstPage;
  final List<MergeRequest> _secondPage;
  final MergeRequestDetails _details;
  int firstPageLoads = 0;
  int nextPageLoads = 0;
  int detailLoads = 0;

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
  Future<MergeRequestDetails> loadMergeRequest(
    int projectId,
    int mergeIid,
  ) async {
    detailLoads++;
    return _details;
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
