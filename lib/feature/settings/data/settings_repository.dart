import 'package:uneconly/feature/select/model/group.dart';
import 'package:uneconly/feature/settings/data/settings_local_data_provider.dart';

abstract class ISettingsRepository {
  Future<void> saveGroup(Group group);
  Future<Group?> getGroup();
}

class SettingsRepository implements ISettingsRepository {
  final ISettingsLocalDataProvider _localDataProvider;

  SettingsRepository({required ISettingsLocalDataProvider localDataProvider})
      : _localDataProvider = localDataProvider;

  @override
  Future<Group?> getGroup() {
    return _localDataProvider.getGroup();
  }

  @override
  Future<void> saveGroup(Group group) async {
    await _localDataProvider.saveGroup(group);
  }
}
