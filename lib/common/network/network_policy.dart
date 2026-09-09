import 'package:dio/dio.dart';

/// Network deadlines are deliberately shorter than a user's willingness to
/// wait on a blocked screen. Schedule pages retain cached content while these
/// expire; screens without cache expose an explicit retry action.
const apiConnectTimeout = Duration(seconds: 8);
const apiSendTimeout = Duration(seconds: 10);
const apiReceiveTimeout = Duration(seconds: 12);
const auxiliarySdkTimeout = Duration(seconds: 4);

Dio createApiClient({
  required String baseUrl,
  Duration connectTimeout = apiConnectTimeout,
  Duration sendTimeout = apiSendTimeout,
  Duration receiveTimeout = apiReceiveTimeout,
}) => Dio(
  BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: connectTimeout,
    sendTimeout: sendTimeout,
    receiveTimeout: receiveTimeout,
  ),
);
