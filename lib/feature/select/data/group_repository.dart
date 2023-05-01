import 'package:uneconly/feature/select/data/group_network_data_provider.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/model/group.dart';

abstract class IGroupRepository {
  Future<List<Group>> fetchAll();
  Future<List<Faculty>> fetchAllFaculties();
}

class GroupRepository implements IGroupRepository {
  final IGroupNetworkDataProvider _networkDataProvider;

  GroupRepository({required IGroupNetworkDataProvider networkDataProvider})
      : _networkDataProvider = networkDataProvider;

  @override
  Future<List<Group>> fetchAll() {
    return _networkDataProvider.fetchAll();
  }

  @override
  Future<List<Faculty>> fetchAllFaculties() {
    return _networkDataProvider.fetchAllFaculties();
  }
}
