import 'dart:ui';
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
  String mode = 'appmetrica';
  int revision = 100;
  @override
  Future<AppConfig> fetch({
    required int? groupId,
    required String platform,
  }) async => AppConfig(
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native providers follow live config without application restart',
    (tester) async {
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
      config.addListener(() => logger.configure(config.current.telemetry));
      config.start(groupId: -999);
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
        if (mode == 'both')
          await logger.logError(
            StateError('Synthetic telemetry delivery verification'),
            StackTrace.current,
          );
        await logger.drain();
        // The SDK batches logs for five seconds. Allow delivery before switching.
      await Future<void>.delayed(const Duration(seconds: 7));
      }
      config.dispose();
      await prefs.remove(AppConfigService.cacheKeyForGroup(-999));
      await Sentry.close();
      FlutterError.onError = flutterError;
      PlatformDispatcher.instance.onError = platformError;
    },
  );
}
