import 'dart:developer';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';

abstract class ILoggingRepository {
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  });
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]);
}

class AppMetricaLoggingRepository implements ILoggingRepository {
  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    await AppMetrica.reportError(
      message: exception.toString(),
      errorDescription: AppMetricaErrorDescription.fromObjectAndStackTrace(
        exception,
        stackTrace,
      ),
    );
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    await AppMetrica.reportEventWithMap(eventName, attributes);
  }
}

class LocalLoggingRepository implements ILoggingRepository {
  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    log(exception.toString(), stackTrace: stackTrace);
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    log('$eventName $attributes');
  }
}
