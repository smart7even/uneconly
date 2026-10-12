import 'package:dio/dio.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_identity.dart';

/// Applies only to our API; no hardware, account, or advertising identifiers.
void attachClientIdentity(
  Dio dio, {
  required String version,
  required String build,
  required String platform,
  required String installation,
  required ILoggingRepository logger,
}) {
  final origin = Uri.parse(dio.options.baseUrl).origin;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, handler) {
        if (request.uri.origin == origin) {
          request.headers.addAll({
            'User-Agent': 'Uneconly/$version (build/$build; $platform)',
            'X-App-Version': version,
            'X-App-Build': build,
            'X-App-Platform': platform,
            'X-Installation-ID': installation,
            'X-Request-ID': telemetryId(),
          });
        }
        handler.next(request);
      },
      onError: (error, handler) {
        if (error.requestOptions.uri.origin == origin) {
          // No URL query, request/response body, or raw error message is exported.
          logger.logEvent('api/request_failed', {
            'request_id':
                error.requestOptions.headers['X-Request-ID'] as String,
            'http_method': error.requestOptions.method,
            'http_status_code': error.response?.statusCode ?? 0,
            'error_type': error.type.name,
          }).ignore();
        }
        handler.next(error);
      },
    ),
  );
}
