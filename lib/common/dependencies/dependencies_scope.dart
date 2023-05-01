import 'package:dio/dio.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/feature/settings/data/settings_repository.dart';

class DependenciesScope {
  final Dio dio;
  final MyDatabase database;
  final ISettingsRepository settingsRepository;

  DependenciesScope({
    required this.database,
    required this.dio,
    required this.settingsRepository,
  });
}
