import 'dart:async';

import 'package:home_widget/home_widget.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

abstract class ISettingsRepository {
  Future<void> saveGroup(Group group);
  Future<Group?> getGroup();
  Future<void> addGroupToFavorites(Group group);
  Future<List<Group>> getFavoriteGroups();
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Stream<String> getLanguageChangedStream();
  Future<void> saveTheme(String theme);
  Future<String?> getTheme();
  Stream<String> getThemeChangedStream();
}

class SettingsRepository implements ISettingsRepository {
  final ISettingsLocalDataProvider _localDataProvider;

  SettingsRepository({required ISettingsLocalDataProvider localDataProvider})
      : _localDataProvider = localDataProvider;

  final StreamController<String> _languageChangedController =
      StreamController<String>.broadcast();

  final StreamController<String> _themeChangedController =
      StreamController<String>.broadcast();

  @override
  Future<Group?> getGroup() {
    return _localDataProvider.getGroup();
  }

  @override
  Future<void> saveGroup(Group group) async {
    await HomeWidget.saveWidgetData<int>(
      'groupId',
      group.id,
    );
    HomeWidget.updateWidget(
      name: 'UWidget',
      iOSName: 'UWidget',
    );
    await _localDataProvider.saveGroup(group);
  }

  @override
  Future<String?> getLanguage() {
    return _localDataProvider.getLanguage();
  }

  @override
  Future<void> saveLanguage(String language) async {
    await _localDataProvider.saveLanguage(language);
    _languageChangedController.add(language);
  }

  @override
  Stream<String> getLanguageChangedStream() =>
      _languageChangedController.stream;

  @override
  Future<String?> getTheme() {
    return _localDataProvider.getTheme();
  }

  @override
  Stream<String> getThemeChangedStream() {
    return _themeChangedController.stream;
  }

  @override
  Future<void> saveTheme(String theme) async {
    await _localDataProvider.saveTheme(theme);
    _themeChangedController.add(theme);
  }

  @override
  Future<void> addGroupToFavorites(Group group) async {
    await _localDataProvider.saveGroup(group);
  }

  @override
  Future<List<Group>> getFavoriteGroups() {
    return _localDataProvider.getFavoriteGroups();
  }
}
