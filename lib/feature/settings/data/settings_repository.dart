import 'dart:async';

import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

abstract class ISettingsRepository {
  Future<void> saveGroup(Group group);
  Future<Group?> getGroup();
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Stream<String> getLanguageChangedStream();
}

class SettingsRepository implements ISettingsRepository {
  final ISettingsLocalDataProvider _localDataProvider;

  SettingsRepository({required ISettingsLocalDataProvider localDataProvider})
      : _localDataProvider = localDataProvider;

  final StreamController<String> _languageChangedController =
      StreamController<String>.broadcast();

  @override
  Future<Group?> getGroup() {
    return _localDataProvider.getGroup();
  }

  @override
  Future<void> saveGroup(Group group) async {
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
}
