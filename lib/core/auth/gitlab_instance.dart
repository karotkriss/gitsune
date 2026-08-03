import 'package:dio/dio.dart';

/// Parses user-entered GitLab instance text ("gitlab.com",
/// "https://gitlab.example.com") into an instance base [Uri], or null when
/// the text cannot name an instance.
///
/// The scheme defaults to https; http stays allowed for intranet instances.
/// Only scheme, host, and port survive: instance URLs are host-level, and
/// stray paths or queries the user pasted are dropped.
Uri? parseInstanceUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  // A dotless host ("gitlab", "not a url") is junk far more often than a
  // bare intranet hostname; rejecting it is what makes validation catch
  // typos before a doomed network probe.
  if (uri.host.isEmpty || !uri.host.contains('.')) return null;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  );
}

/// True when [base] answers as a GitLab instance: its REST API
/// (`/api/v4/version`) responds with JSON, either 200 (public) or 401 (the
/// instance requires authentication, which still proves the API is there).
/// Unreachable hosts and non-GitLab servers report false.
Future<bool> isGitLabInstance(Uri base, {Dio? dio}) async {
  final client =
      dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
  try {
    final response = await client.get<void>(
      base.replace(path: '/api/v4/version').toString(),
      options: Options(validateStatus: (_) => true),
    );
    final contentType =
        response.headers.value(Headers.contentTypeHeader) ?? '';
    return contentType.contains('application/json') &&
        (response.statusCode == 200 || response.statusCode == 401);
  } on DioException {
    return false;
  }
}
