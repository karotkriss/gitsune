import 'dart:io';

import 'package:dio/dio.dart';

/// Whether [error] means the server was never reached (connection refused,
/// no route, DNS failure, or a timed-out connection attempt) rather than the
/// server answering with a rejection.
///
/// Connectivity failures are safe to retry once the network returns; anything
/// else is a real server response and must be handled, not requeued.
bool isConnectivityError(DioException error) =>
    error.type == DioExceptionType.connectionError ||
    error.type == DioExceptionType.connectionTimeout ||
    error.error is SocketException;
