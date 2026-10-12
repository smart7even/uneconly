import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/logging/routing_logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_sinks.dart';

abstract class ILoggingRepositoryFactory {
  Future<ILoggingRepository> create();
}

class LoggingRepositoryFactory implements ILoggingRepositoryFactory {
  @override
  Future<ILoggingRepository> create() async => RoutingLoggingRepository(
    appmetrica: AppMetricaTelemetrySink(),
    sentry: SentryTelemetrySink(),
  );
}
