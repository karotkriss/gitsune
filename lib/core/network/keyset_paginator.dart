import 'package:dio/dio.dart';

/// One page of a keyset/cursor-paginated GitLab collection, plus the URI to
/// fetch the next page.
///
/// GitLab omits total-count headers on keyset-paginated endpoints, so
/// [hasMore] - not a page count - is the only "how much is left" signal.
class KeysetPage<T> {
  const KeysetPage({required this.items, required this.nextUri});

  final List<T> items;
  final Uri? nextUri;

  bool get hasMore => nextUri != null;
}

/// Extracts the `rel="next"` URI from a GitLab response's `Link` header, or
/// `null` on the last page.
///
/// GitLab's keyset pagination (`pagination=keyset`) surfaces the next page
/// only through this header, never through `X-Next-Page`/`X-Total`, which
/// keyset responses omit by design.
Uri? nextPageUriFrom(Response<dynamic> response) {
  final linkHeader = response.headers.value('link');
  if (linkHeader == null) return null;

  for (final part in linkHeader.split(',')) {
    final segments = part.split(';').map((s) => s.trim()).toList();
    if (segments.isEmpty) continue;
    final urlSegment = segments.first;
    if (!urlSegment.startsWith('<') || !urlSegment.endsWith('>')) continue;
    final isNext = segments.skip(1).contains('rel="next"');
    if (!isNext) continue;
    return Uri.parse(urlSegment.substring(1, urlSegment.length - 1));
  }
  return null;
}

/// Fetches one page at a time from a keyset/cursor-paginated GitLab
/// collection, following the `Link` header's `rel="next"` URI rather than
/// any page-number or total-count header.
///
/// Call [loadNext] to fetch and decode the next page; [hasMore] reports
/// whether another page is available. [resumeToken] captures where to pick
/// up later - persist it (e.g. via a small drift table) and pass it back
/// through [KeysetPaginator.resume] to continue an interrupted listing.
class KeysetPaginator<T> {
  KeysetPaginator({
    required Dio dio,
    required Uri initialUri,
    required T Function(Map<String, dynamic> json) decode,
  }) : this._(dio, initialUri, decode, initialUri);

  /// Resumes a paginator from a previously persisted [resumeToken] rather
  /// than the collection's first page.
  ///
  /// If [resumeToken] is null or empty, starts fresh from [initialUri]. A
  /// resume token that the server later rejects (an expired/invalid
  /// cursor) is handled by [loadNext], which falls back to [initialUri]
  /// rather than failing the listing.
  KeysetPaginator.resume({
    required Dio dio,
    required Uri initialUri,
    required T Function(Map<String, dynamic> json) decode,
    required String? resumeToken,
  }) : this._(
         dio,
         initialUri,
         decode,
         (resumeToken == null || resumeToken.isEmpty)
             ? initialUri
             : Uri.tryParse(resumeToken) ?? initialUri,
       );

  KeysetPaginator._(this._dio, this._initialUri, this._decode, this._nextUri);

  final Dio _dio;
  final Uri _initialUri;
  final T Function(Map<String, dynamic> json) _decode;
  Uri? _nextUri;

  /// Whether another page is available to fetch.
  bool get hasMore => _nextUri != null;

  /// The URI to resume from after this point, or `null` once the
  /// collection is exhausted. Persist this so an interrupted listing can
  /// resume later via [KeysetPaginator.resume].
  String? get resumeToken => _nextUri?.toString();

  /// Fetches and decodes the next page.
  ///
  /// Throws [StateError] if [hasMore] is false. If the server rejects the
  /// current cursor with a 4xx (an expired/invalid resume token) and this
  /// isn't already the first page, falls back to a clean restart from
  /// [initialUri] instead of throwing.
  Future<KeysetPage<T>> loadNext() async {
    final uri = _nextUri;
    if (uri == null) {
      throw StateError('No more pages to load.');
    }

    try {
      return await _fetch(uri);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final isClientError = status != null && status >= 400 && status < 500;
      if (isClientError && uri != _initialUri) {
        return _fetch(_initialUri);
      }
      rethrow;
    }
  }

  Future<KeysetPage<T>> _fetch(Uri uri) async {
    final response = await _dio.getUri<dynamic>(uri);
    final items = (response.data as List<dynamic>)
        .map((item) => _decode(item as Map<String, dynamic>))
        .toList();
    final next = nextPageUriFrom(response);
    _nextUri = next;
    return KeysetPage(items: items, nextUri: next);
  }
}
