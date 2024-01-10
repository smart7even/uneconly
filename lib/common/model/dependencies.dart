import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/feature/initialization/widget/inherited_dependencies.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

class Dependencies {
  Dependencies();

  late final SharedPreferences sharedPreferences;
  late final ISettingsRepository settingsRepository;
  late final MyDatabase database;
  late final Dio dio;

  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);
}
