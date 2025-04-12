import 'dart:async';
import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';
import 'package:uneconly/feature/settings/model/calendar_settings_entity.dart';

abstract class ISettingsRepository {
  Future<void> saveGroup(Group group);
  Future<Group?> getGroup();
  Future<void> addGroupToFavorites(Group group);
  Future<void> removeGroupFromFavorites(Group group);
  Future<List<Group>> getFavoriteGroups();
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Stream<String> getLanguageChangedStream();
  Future<void> saveTheme(String theme);
  Future<String?> getTheme();
  Stream<String> getThemeChangedStream();
  Future<void> clearAppCache();
  Future<bool> isAppCacheEmpty();
  Future<CalendarSettingsEntity> getCalendarSettings();
  Future<void> saveCalendarSettings(
    CalendarSettingsEntity calendarSettings,
  );
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
    if (Platform.isAndroid || Platform.isIOS) {
      await HomeWidget.saveWidgetData<int>(
        'groupId',
        group.id,
      );
      HomeWidget.updateWidget(
        name: 'UWidget',
        iOSName: 'UWidget',
      );
    }

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
    await _localDataProvider.addGroupToFavorites(group);
  }

  @override
  Future<List<Group>> getFavoriteGroups() {
    return _localDataProvider.getFavoriteGroups();
  }

  @override
  Future<void> removeGroupFromFavorites(Group group) {
    return _localDataProvider.removeGroupFromFavorites(group);
  }

  @override
  Future<void> clearAppCache() {
    return _localDataProvider.clearAppCache();
  }

  @override
  Future<bool> isAppCacheEmpty() {
    return _localDataProvider.isAppCacheEmpty();
  }

  @override
  Future<CalendarSettingsEntity> getCalendarSettings() async {
    final isCalendarSyncingEnabled =
        await _localDataProvider.isSystemCalendarSyncingEnabled();

    return CalendarSettingsEntity(
      isCalendarSyncingEnabled: isCalendarSyncingEnabled,
    );
  }

  @override
  Future<void> saveCalendarSettings(
    CalendarSettingsEntity calendarSettings,
  ) async {
    await _localDataProvider.setSystemCalendarSyncingEnabled(
      calendarSettings.isCalendarSyncingEnabled,
    );
  }
}
