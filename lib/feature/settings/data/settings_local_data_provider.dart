import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/database/tables/schedule_periods.dart';
import 'package:uneconly/feature/select/model/group.dart';

abstract class ISettingsLocalDataProvider {
  Future<void> saveGroup(Group group);
  Future<Group?> getGroup();
  Future<void> addGroupToFavorites(Group group);
  Future<void> removeGroupFromFavorites(Group group);
  Future<List<Group>> getFavoriteGroups();
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Future<void> saveTheme(String theme);
  Future<String?> getTheme();
  Future<void> clearAppCache();
  Future<bool> isAppCacheEmpty();
  Future<bool> isSystemCalendarSyncingEnabled();
  Future<void> setSystemCalendarSyncingEnabled(bool isEnabled);
}

class SettingsLocalDataProvider implements ISettingsLocalDataProvider {
  final SharedPreferences _prefs;
  final MyDatabase _database;

  static const String _groupIdKey = 'groupId';
  static const String _groupNameKey = 'groupName';
  static const String _groupCourseKey = 'groupCourse';
  static const String _groupFacultyIdKey = 'groupFacultyId';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _favoriteGroupsKey = 'favoriteGroups';
  static const String _systemCalendarSyncingEnabledKey =
      'systemCalendarSyncingEnabled';

  SettingsLocalDataProvider({
    required SharedPreferences prefs,
    required MyDatabase database,
  })  : _prefs = prefs,
        _database = database;

  @override
  Future<Group?> getGroup() async {
    final groupId = _prefs.getInt(_groupIdKey);
    final groupName = _prefs.getString(_groupNameKey);
    final groupCourse = _prefs.getInt(_groupCourseKey);
    final groupFacultyId = _prefs.getInt(_groupFacultyIdKey);

    if (groupId == null ||
        groupName == null ||
        groupCourse == null ||
        groupFacultyId == null) {
      return null;
    }

    return Group(
      id: groupId,
      name: groupName,
      course: groupCourse,
      facultyId: groupFacultyId,
    );
  }

  @override
  Future<void> saveGroup(Group group) async {
    await _prefs.setInt(_groupIdKey, group.id);
    await _prefs.setString(_groupNameKey, group.name);
    await _prefs.setInt(_groupCourseKey, group.course);
    await _prefs.setInt(_groupFacultyIdKey, group.facultyId);
  }

  @override
  Future<String?> getLanguage() async {
    return _prefs.getString(_languageKey);
  }

  @override
  Future<void> saveLanguage(String language) {
    return _prefs.setString(_languageKey, language);
  }

  @override
  Future<String?> getTheme() async {
    return _prefs.getString(_themeKey);
  }

  @override
  Future<void> saveTheme(String theme) {
    return _prefs.setString(_themeKey, theme);
  }

  @override
  Future<void> addGroupToFavorites(Group group) async {
    final favoriteGroups = _prefs.getString(_favoriteGroupsKey);

    if (favoriteGroups == null) {
      await _prefs.setString(
        _favoriteGroupsKey,
        jsonEncode(
          [
            group.toJson(),
          ],
        ),
      );

      return;
    }

    final decoded = jsonDecode(favoriteGroups) as List<dynamic>;

    final filtered = decoded.where((e) => e['id'] != group.id).toList();

    await _prefs.setString(
      _favoriteGroupsKey,
      jsonEncode(
        [
          ...filtered,
          group.toJson(),
        ],
      ),
    );
  }

  @override
  Future<List<Group>> getFavoriteGroups() async {
    final favoriteGroups = _prefs.getString(_favoriteGroupsKey);

    if (favoriteGroups == null) {
      return [];
    }

    final decoded = jsonDecode(favoriteGroups) as List<dynamic>;

    return decoded.map((e) => Group.fromJson(e)).toList();
  }

  @override
  Future<void> removeGroupFromFavorites(Group group) async {
    final favoriteGroups = _prefs.getString(_favoriteGroupsKey);

    if (favoriteGroups == null) {
      return;
    }

    final decoded = jsonDecode(favoriteGroups) as List<dynamic>;

    final filtered = decoded.where((e) => e['id'] != group.id).toList();

    await _prefs.setString(
      _favoriteGroupsKey,
      jsonEncode(
        filtered,
      ),
    );

    return;
  }

  @override
  Future<void> clearAppCache() async {
    await _database.transaction(() async {
      await _database.delete(_database.lessons).go();
      await _database.delete(_database.schedulePeriods).go();
    });
  }

  @override
  Future<bool> isAppCacheEmpty() async {
    final currentPeriods = await (_database.select(_database.schedulePeriods)
          ..where(
            (period) => period.cacheVersion.equals(currentScheduleCacheVersion),
          ))
        .get();
    return currentPeriods.isEmpty;
  }

  @override
  Future<bool> isSystemCalendarSyncingEnabled() async {
    final isEnabled = _prefs.getBool(_systemCalendarSyncingEnabledKey);

    if (isEnabled == null) {
      return false;
    }

    return isEnabled;
  }

  @override
  Future<void> setSystemCalendarSyncingEnabled(bool isEnabled) {
    return _prefs.setBool(_systemCalendarSyncingEnabledKey, isEnabled);
  }
}
