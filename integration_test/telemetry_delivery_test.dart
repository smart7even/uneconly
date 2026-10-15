import 'dart:ui';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:uneconly/common/logging/telemetry_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/logging/routing_logging_repository.dart';
import 'package:uneconly/common/logging/telemetry_sinks.dart';
import 'package:uneconly/feature/schedule/data/app_config_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/app_config_service.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';

class PolicySource implements IAppConfigNetworkDataProvider {
  String mode = 'both';
  bool fail = true;
  int revision = 100;
  @override
  Future<AppConfig> fetch({
    required int? groupId,
    required String platform,
  }) async {
    if (fail) throw StateError('Synthetic first config failure');
    return AppConfig(
      roomMapButtonEnabled: false,
      roomMapCaptionEnabled: false,
      revision: ++revision,
      payload: {
        'telemetry': {
          'mode': mode,
          'sentry_dsn': const String.fromEnvironment('SENTRY_TEST_DSN'),
        },
      },
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native providers follow live config without application restart', (
    tester,
  ) async {
    final flutterError = FlutterError.onError;
    final platformError = PlatformDispatcher.instance.onError;
    final logger = RoutingLoggingRepository(
      appmetrica: AppMetricaTelemetrySink(),
      sentry: SentryTelemetrySink(),
    );
    final source = PolicySource();
    final prefs = await SharedPreferences.getInstance();
    final config = AppConfigService(
      preferences: prefs,
      networkDataProvider: source,
      platform: 'test',
    );
    const run = String.fromEnvironment('TELEMETRY_TEST_RUN');
    expect(run, isNotEmpty);
    expect(
      TelemetryConfig.startupSentryDsn,
      const String.fromEnvironment('SENTRY_TEST_DSN'),
    );
    await prefs.remove(AppConfigService.cacheKeyForGroup(-999));
    await logger.logEvent('telemetry/startup/$run/early', {'group_name': run});
    config.addListener(() => logger.configure(config.current.telemetry));
    config.start(groupId: -999);
    logger.configure(config.current.telemetry);
    await config.refreshIfDue(force: true);
    await logger.drain();
    FlutterError.onError = flutterError;
    PlatformDispatcher.instance.onError = platformError;
    expect(config.current.telemetry.mode, 'both');
    await logger.logEvent('telemetry/startup/$run/offline', {
      'group_name': run,
    });
    await logger.drain();
    await AppMetrica.sendEventsBuffer();
    await Future<void>.delayed(const Duration(seconds: 10));
    source.fail = false;
    await config.refreshIfDue(force: true);
    await logger.logEvent('telemetry/startup/$run/remote', {'group_name': run});
    await logger.drain();
    await AppMetrica.sendEventsBuffer();
    await Future<void>.delayed(const Duration(seconds: 10));
    for (final mode in ['appmetrica', 'both', 'sentry', 'off']) {
      source.mode = mode;
      await config.refreshIfDue(force: true);
      await logger.drain();
      FlutterError.onError = flutterError;
      PlatformDispatcher.instance.onError = platformError;
      expect(config.current.telemetry.mode, mode);
      await logger.logEvent('telemetry/routing/$mode', {
        'group_name': const String.fromEnvironment('TELEMETRY_TEST_RUN'),
      });
      if (mode == 'both') {
        await logger.logError(
          StateError('Synthetic telemetry delivery verification'),
          StackTrace.current,
        );
      }
      await logger.drain();
      await AppMetrica.sendEventsBuffer();
      // The SDK batches logs for five seconds. Allow delivery before switching.
      await Future<void>.delayed(const Duration(seconds: 7));
    }
    config.dispose();
    await prefs.remove(AppConfigService.cacheKeyForGroup(-999));
    await Sentry.close();
    FlutterError.onError = flutterError;
    PlatformDispatcher.instance.onError = platformError;
  });
}
