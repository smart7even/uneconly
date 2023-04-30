import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/select/model/group.dart';

abstract class IGroupNetworkDataProvider {
  Future<List<Group>> fetchAll();
}

class GroupNetworkDataProvider implements IGroupNetworkDataProvider {
  GroupNetworkDataProvider({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<Group>> fetchAll() async {
    // fetch data from /group endpoint
    try {
      final response = await _dio.get('/group');

      List<Group> groups = (response.data['groups'] as List<dynamic>)
          .map<Group>((group) => Group.fromJson(group))
          .toList();

      return groups;
    } catch (e, stackTrace) {
      l.e('An error occured in GroupNetworkDataProvider', stackTrace);
      rethrow;
    }
  }
}
