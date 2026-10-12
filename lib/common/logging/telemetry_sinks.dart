import 'dart:io';
import 'dart:math';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/logging/routing_logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_config.dart';
import 'package:uneconly/constants.dart';

String telemetryId() => List.generate(
  16,
  (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

class AppMetricaTelemetrySink extends AppMetricaLoggingRepository
    implements TelemetrySink {
  Future<void>? _activation;
  bool _enabled = false;
  TelemetryConfig _desired = const TelemetryConfig();
  @override
  Future<void> configure(TelemetryConfig config) async {
    _desired = config;
    _enabled = config.appmetrica;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await (_activation ??= AppMetrica.activate(
        AppMetricaConfig(
          kDebugMode ? appMetricaDevKey : appMetricaProductionKey,
          dataSendingEnabled: false,
          crashReporting: true,
        ),
      ));
    } on Object {
      _activation = null;
      rethrow;
    }
    await AppMetrica.setDataSendingEnabled(_enabled);
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    if (_enabled && _activation == null) await configure(_desired);
    if (_enabled && (Platform.isAndroid || Platform.isIOS)) {
      await super.logEvent(eventName, attributes);
    }
  }

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    if (_enabled && _activation == null) await configure(_desired);
    if (_enabled && (Platform.isAndroid || Platform.isIOS)) {
      await super.logError(exception, stackTrace, hint: hint, fatal: fatal);
    }
  }
}

class SentryTelemetrySink implements TelemetrySink {
  bool _enabled = false;
  TelemetryConfig _desired = const TelemetryConfig();
  String? _dsn;
  Future<void> _transition = Future.value();
  int _policyRevision = 0;
  String _installation = '';
  final String _session = telemetryId();
  String _version = '';
  @override
  Future<void> configure(TelemetryConfig config) {
    _desired = config;
    _enabled = config.sentry;
    final revision = ++_policyRevision;
    final transition = _transition.catchError((Object _) {}).then((_) async {
      if (revision != _policyRevision) return;
      if (!config.sentry) {
        if (_dsn != null) await Sentry.close();
        _dsn = null;
      } else if (_dsn != config.sentryDsn) {
        await _initialize(config.sentryDsn);
      }
    });
    _transition = transition;
    return transition;
  }

  Future<void> _initialize(String dsn) async {
    final preferences = await SharedPreferences.getInstance();
    _installation =
        preferences.getString('telemetry.installation_id') ?? telemetryId();
    await preferences.setString('telemetry.installation_id', _installation);
    final info = await PackageInfo.fromPlatform();
    _version = '${info.version}+${info.buildNumber}';
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.environment = kDebugMode ? 'development' : 'production';
      options.release = 'uneconly@$_version';
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0;
      options.enableAutoSessionTracking = false;
      options.enableAutoPerformanceTracing = false;
      options.enableAutoNativeBreadcrumbs = false;
      options.enableNativeCrashHandling = true;
      options.beforeSend = (event, hint) =>
          _enabled && hint.get('uneconly_manual') == true ? event : null;
      options.enableLogs = true;
      options.beforeSendLog = (log) =>
          _enabled && log.attributes.containsKey('event_name') ? log : null;
      options.maxBreadcrumbs = 0;
      options.attachStacktrace = true;
    });
    _dsn = dsn;
  }

  @override
  Future<void> logEvent(
    String eventName, [
    Map<String, Object>? attributes,
  ]) async {
    if (!_enabled) return;
    if (_dsn == null) await configure(_desired);
    if (!_enabled || _dsn == null) return;
    final values = <String, SentryAttribute>{
      'event_name': SentryAttribute.string(eventName),
      'event_id': SentryAttribute.string(telemetryId()),
      'installation_id': SentryAttribute.string(_installation),
      'session_id': SentryAttribute.string(_session),
      'app_version': SentryAttribute.string(_version),
      'platform': SentryAttribute.string(Platform.operatingSystem),
      'schema_version': SentryAttribute.int(1),
    };
    const allowed = {
      'relationship',
      'scope',
      'group_id',
      'group_name',
      'group_course',
      'course',
      'faculty_id',
      'stage',
      'surface',
      'source',
      'format',
      'result',
      'group_faculty_id',
      'group_faculty_name',
      'page',
      'week',
      'direction',
    };
    for (final entry in (attributes ?? <String, Object>{}).entries) {
      if (!allowed.contains(entry.key)) continue;
      final value = entry.value;
      if (value is String && value.length <= 200) {
        values[entry.key] = SentryAttribute.string(value);
      }
      if (value is int) values[entry.key] = SentryAttribute.int(value);
      if (value is bool) values[entry.key] = SentryAttribute.bool(value);
      if (entry.key == 'page' && value is Map && value['name'] is String) {
        values['page'] = SentryAttribute.string(value['name'] as String);
      }
    }
    Sentry.logger.info(eventName, attributes: values);
  }

  @override
  Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    bool fatal = false,
  }) async {
    if (!_enabled) return;
    if (_dsn == null) await configure(_desired);
    if (!_enabled || _dsn == null) return;
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: Hint.withMap({'uneconly_manual': true}),
      withScope: (scope) {
        scope.level = fatal ? SentryLevel.fatal : SentryLevel.error;
      },
    );
  }
}
