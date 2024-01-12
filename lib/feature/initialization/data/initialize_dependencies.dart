import 'dart:async';

import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/constants.dart';
import 'package:uneconly/feature/initialization/data/platform/platform_initialization.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
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

typedef _InitializationStep = FutureOr<void> Function(
  Dependencies dependencies,
);
final Map<String, _InitializationStep> _initializationSteps =
    <String, _InitializationStep>{
  'Platform pre-initialization': (_) => $platformInitialization(),
  'Log app open': (_) {},
  'Initialize shared preferences': (dependencies) async =>
      dependencies.sharedPreferences = await SharedPreferences.getInstance(),
  'Initialize settings repository': (dependencies) async =>
      dependencies.settingsRepository = SettingsRepository(
        localDataProvider: SettingsLocalDataProvider(
          prefs: dependencies.sharedPreferences,
        ),
      ),
  'Initialize database': (dependencies) async =>
      dependencies.database = MyDatabase(),
  'Initialize dio': (dependencies) async => dependencies.dio = Dio(
        BaseOptions(
          baseUrl: serverAddress,
        ),
      ),
  'Log app initialized': (_) {},
};
