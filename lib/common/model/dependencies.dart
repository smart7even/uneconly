import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/analytics/analytics_repository.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/logging/logging_repository.dart';
import 'package:uneconly/feature/initialization/widget/inherited_dependencies.dart';
import 'package:uneconly/feature/schedule/data/day_schedule_repository.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';
import 'package:uneconly/feature/tutorials/data/tutorial_network_data_provider.dart';
import 'package:uneconly/feature/tutorials/data/tutorial_repository.dart';

class Dependencies {
  Dependencies();

  late final ILoggingRepository loggingRepository;
  late final IAnalyticsRepository analyticsRepository;
  late final SharedPreferences sharedPreferences;
  late final ISettingsRepository settingsRepository;
  late final MyDatabase database;
  late final Dio dio;
  late final IAssetNetworkDataProvider assetNetworkDataProvider;
  late final ITutorialRepository tutorialRepository;
  late final IDayScheduleRepository dayScheduleRepository;

  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);
}
