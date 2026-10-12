import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uneconly/common/network/client_identity.dart';
import 'package:uneconly/common/logging/telemetry_identity.dart';
import 'package:uneconly/common/logging/routing_logging_repository.dart';
import 'dart:async';

import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/analytics/analytics_repository.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/network/network_policy.dart';
import 'package:uneconly/common/push/push_notification_service.dart';
import 'package:uneconly/common/review/app_review_service.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/initialization/data/platform/platform_initialization.dart';
import 'package:uneconly/feature/schedule/data/day_schedule_repository.dart';
import 'package:uneconly/feature/schedule/data/app_config_network_data_provider.dart';
import 'package:uneconly/feature/schedule/data/app_config_service.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';
import 'package:uneconly/feature/tutorials/data/tutorial_network_data_provider.dart';
import 'package:uneconly/feature/tutorials/data/tutorial_repository.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
  required ILoggingRepository loggingRepository,
}) async {
  final dependencies = Dependencies();
  final initializationSteps = _getInitializationSteps(
    loggingRepository: loggingRepository,
  );
  final totalSteps = initializationSteps.length;
  var currentStep = 0;
  for (final step in initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);
      l.v6(
        'Initialization | $currentStep/$totalSteps ($percent%) | "${step.key}"',
      );
      await step.value(dependencies);
    } on Object catch (error, stackTrace) {
      l.e('Initialization failed at step "${step.key}": $error', stackTrace);
      Error.throwWithStackTrace(
        'Initialization failed at step "${step.key}": $error',
        stackTrace,
      );
    }
  }

  return dependencies;
}

typedef _InitializationStep =
    FutureOr<void> Function(Dependencies dependencies);

Map<String, _InitializationStep> _getInitializationSteps({
  required ILoggingRepository loggingRepository,
}) {
  final Map<String, _InitializationStep>
  initializationSteps = <String, _InitializationStep>{
    'Platform pre-initialization': (_) => $platformInitialization(),
    'Provide logging pepository': (dependencies) =>
        dependencies.loggingRepository = loggingRepository,
    'Log app open': (dependencies) {
      dependencies.loggingRepository.logEvent('appOpen');
    },
    'Initialize analytics repository': (dependencies) async =>
        dependencies.analyticsRepository = AnalyticsRepository(
          loggingRepository: dependencies.loggingRepository,
        ),
    'Initialize shared preferences': (dependencies) async =>
        dependencies.sharedPreferences = await SharedPreferences.getInstance(),
    'Initialize app review service': (dependencies) async =>
        dependencies.appReviewService = AppReviewService(
          preferences: dependencies.sharedPreferences,
          loggingRepository: dependencies.loggingRepository,
        ),
    'Initialize push notifications': (dependencies) async {
      dependencies.pushNotificationService = AppMetricaPushNotificationService(
        preferences: dependencies.sharedPreferences,
        loggingRepository: dependencies.loggingRepository,
      );
    },
    'Initialize database': (dependencies) async =>
        dependencies.database = MyDatabase(),
    'Initialize settings local data provider': (dependencies) async =>
        dependencies.settingsLocalDataProvider = SettingsLocalDataProvider(
          prefs: dependencies.sharedPreferences,
          database: dependencies.database,
        ),
    'Initialize settings repository': (dependencies) async =>
        dependencies.settingsRepository = SettingsRepository(
          localDataProvider: dependencies.settingsLocalDataProvider,
        ),
    'Initialize dio': (dependencies) async {
      final dio = dependencies.dio = createApiClient(baseUrl: serverAddress);
      try {
        final info = await PackageInfo.fromPlatform().timeout(
          auxiliarySdkTimeout,
        );
        final id = await installationId(
          dependencies.sharedPreferences,
        ).timeout(auxiliarySdkTimeout);
        attachClientIdentity(
          dio,
          version: info.version,
          build: info.buildNumber,
          platform: Platform.operatingSystem,
          installation: id,
          logger: dependencies.loggingRepository,
        );
      } on Object {
        // Diagnostics metadata must never prevent schedule access.
      }
    },
    'Initialize app config service': (dependencies) async {
      dependencies.appConfigService = AppConfigService(
        preferences: dependencies.sharedPreferences,
        networkDataProvider: AppConfigNetworkDataProvider(
          dio: dependencies.dio,
        ),
      );
      final config = dependencies.appConfigService;
      final logger = dependencies.loggingRepository;
      config.start();
      if (logger is RoutingLoggingRepository) {
        void apply() => logger.configure(config.current.telemetry);
        config.addListener(apply);
        apply();
        // Push requires AppMetrica activation, but neither SDK blocks startup.
        unawaited(
          logger.drain().then(
            (_) => dependencies.pushNotificationService.activate(),
          ),
        );
      } else {
        unawaited(dependencies.pushNotificationService.activate());
      }
    },
    'Initialize asset network data provider': (dependencies) async =>
        dependencies.assetNetworkDataProvider = AssetNetworkDataProvider(
          dio: dependencies.dio,
        ),
    'Initialize tutorial repository': (dependencies) async =>
        dependencies.tutorialRepository = TutorialRepository(
          networkDataProvider: dependencies.assetNetworkDataProvider,
        ),
    'Initialize day schedule repository': (dependencies) async =>
        dependencies.dayScheduleRepository = DayScheduleRepository(
          networkDataProvider: dependencies.assetNetworkDataProvider,
        ),
    'Log app initialized': (_) {
      return;
    },
  };

  return initializationSteps;
}
