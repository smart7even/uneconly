import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/logging/routing_logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_config.dart';

class Sink implements TelemetrySink {
  final events = <String>[];
  bool fail = false;
  Completer<void>? blocked;
  @override
  Future<void> configure(TelemetryConfig config) async {
    await blocked?.future;
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    if (fail) throw StateError('offline');
    events.add(eventName);
  }

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) => logEvent('error');
}

void main() {
  test('switches live through appmetrica, both, sentry and off', () async {
    final a = Sink(), s = Sink();
    final router = RoutingLoggingRepository(appmetrica: a, sentry: s);
    await router.logEvent('early');
    router.configure(const TelemetryConfig());
    await router.drain();
    router.configure(const TelemetryConfig(mode: 'both'));
    await router.logEvent('both');
    await router.drain();
    router.configure(const TelemetryConfig(mode: 'sentry'));
    await router.logEvent('sentry');
    await router.drain();
    router.configure(const TelemetryConfig(mode: 'off'));
    await router.logEvent('off');
    await router.drain();
    expect(a.events, ['early', 'both']);
    expect(s.events, ['both', 'sentry']);
  });
  test('one failed provider does not stop other or propagate errors', () async {
    final a = Sink()..fail = true, s = Sink();
    final router = RoutingLoggingRepository(appmetrica: a, sentry: s);
    router.configure(const TelemetryConfig(mode: 'both'));
    await router.logEvent('works');
    await router.drain();
    expect(s.events, ['works']);
  });
  test('hung setup is bounded and stale queued events are discarded', () async {
    final a = Sink()..blocked = Completer<void>(), s = Sink();
    final router = RoutingLoggingRepository(
      appmetrica: a,
      sentry: s,
      timeout: const Duration(milliseconds: 10),
    );
    router.configure(const TelemetryConfig(mode: 'both'));
    unawaited(router.logEvent('obsolete'));
    router.configure(const TelemetryConfig(mode: 'off'));
    await router.drain();
    expect(a.events, isEmpty);
    expect(s.events, isEmpty);
    a.blocked!.complete();
  });
  test('rejects a foreign collector and malformed policy', () {
    expect(
      () => TelemetryConfig.parse({
        'mode': 'both',
        'sentry_dsn': 'https://key@evil.test/1',
      }),
      throwsFormatException,
    );
    expect(
      () => TelemetryConfig.parse({'mode': 'oops'}),
      throwsFormatException,
    );
    expect(
      TelemetryConfig.parse({
        'mode': 'both',
        'sentry_dsn': 'https://key@sentry.roadmapik.com/2',
      }).sentry,
      isTrue,
    );
  });
}
