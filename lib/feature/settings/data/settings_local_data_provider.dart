import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/feature/select/model/group.dart';

abstract class ISettingsLocalDataProvider {
  Future<void> saveGroup(Group group);
  Future<Group?> getGroup();
  Future<void> addGroupToFavorites(Group group);
  Future<List<Group>> getFavoriteGroups();
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Future<void> saveTheme(String theme);
  Future<String?> getTheme();
}

class SettingsLocalDataProvider implements ISettingsLocalDataProvider {
  final SharedPreferences _prefs;

  static const String _groupIdKey = 'groupId';
  static const String _groupNameKey = 'groupName';
  static const String _groupCourseKey = 'groupCourse';
  static const String _groupFacultyIdKey = 'groupFacultyId';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _favoriteGroupsKey = 'favoriteGroups';

  SettingsLocalDataProvider({required SharedPreferences prefs})
      : _prefs = prefs;

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
    await _prefs.setString(
      _favoriteGroupsKey,
      jsonEncode(
        group.toJson(),
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
}
