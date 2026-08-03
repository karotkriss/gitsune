import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Builds the DioException the token endpoint produces for the OAuth error
/// body in `test/fixtures/auth/[name].json`, as Doorkeeper sends it.
DioException tokenEndpointError(String name) {
  final body =
      jsonDecode(File('test/fixtures/auth/$name.json').readAsStringSync())
          as Map<String, dynamic>;
  final options = RequestOptions(path: '/oauth/token');
  return DioException.badResponse(
    statusCode: 400,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 400, data: body),
  );
}
