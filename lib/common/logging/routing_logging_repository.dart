import 'dart:async';
import 'dart:developer' as developer;
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_config.dart';

abstract interface class TelemetrySink implements ILoggingRepository {
  Future<void> configure(TelemetryConfig config);
}

/// Independent bounded queues prevent one broken SDK from blocking the other
/// provider or application startup. A policy change invalidates queued events.
class RoutingLoggingRepository implements ILoggingRepository {
  RoutingLoggingRepository({
    required this.appmetrica,
    required this.sentry,
    this.timeout = const Duration(seconds: 4),
  });
  final TelemetrySink appmetrica;
  final TelemetrySink sentry;
  final Duration timeout;
  TelemetryConfig? _config;
  int _generation = 0;
  final List<Future<void> Function(ILoggingRepository)> _early = [];
  final Map<TelemetrySink, Future<void>> _tails = {};
  final Map<TelemetrySink, int> _pending = {};

  void configure(TelemetryConfig config) {
    if (_config?.mode == config.mode &&
        _config?.sentryDsn == config.sentryDsn) {
      return;
    }
    _config = config;
    ++_generation;
    for (final sink in [appmetrica, sentry]) {
      _tails[sink] = Future<void>.sync(() => sink.configure(config))
          .timeout(timeout)
          .catchError((Object error) {
            developer.log(
              'Telemetry configuration unavailable',
              name: 'telemetry',
            );
          });
    }
    for (final event in List.of(_early)) {
      _dispatch(event);
    }
    _early.clear();
  }

  void _enqueue(
    TelemetrySink sink,
    int generation,
    Future<void> Function() action,
  ) {
    if ((_pending[sink] ?? 0) >= 100) return;
    _pending[sink] = (_pending[sink] ?? 0) + 1;
    _tails[sink] = (_tails[sink] ?? Future.value())
        .then((_) async {
          if (generation != _generation) return;
          try {
            await action().timeout(timeout);
          } on Object {
            developer.log('Telemetry provider unavailable', name: 'telemetry');
          }
        })
        .whenComplete(() => _pending[sink] = (_pending[sink] ?? 1) - 1);
  }

  void _dispatch(Future<void> Function(ILoggingRepository) event) {
    final config = _config;
    if (config == null) {
      if (_early.length < 100) _early.add(event);
      return;
    }
    if (config.appmetrica) {
      _enqueue(appmetrica, _generation, () => event(appmetrica));
    }
    if (config.sentry) _enqueue(sentry, _generation, () => event(sentry));
  }

  Future<void> drain() async => Future.wait(List.of(_tails.values));
  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    final snapshot = attributes == null
        ? null
        : Map<String, Object>.of(attributes);
    _dispatch((sink) => sink.logEvent(eventName, snapshot));
  }

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    _dispatch(
      (sink) => sink.logError(exception, stackTrace, hint: hint, fatal: fatal),
    );
  }
}
