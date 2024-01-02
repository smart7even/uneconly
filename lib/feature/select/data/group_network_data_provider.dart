import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/select/model/faculty.dart';
import 'package:uneconly/feature/select/model/group.dart';

abstract class IGroupNetworkDataProvider {
  Future<List<Group>> fetchAll();
  Future<List<Faculty>> fetchAllFaculties();
  Future<Group> fetchGroupById(int groupId);
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

  @override
  Future<List<Faculty>> fetchAllFaculties() async {
    // fetch data from /faculty endpoint
    try {
      final response = await _dio.get('/faculty');

      List<Faculty> faculties = (response.data['faculties'] as List<dynamic>)
          .map<Faculty>((faculty) => Faculty.fromJson(faculty))
          .toList();

      return faculties;
    } catch (e, stackTrace) {
      l.e('An error occured in GroupNetworkDataProvider', stackTrace);
      rethrow;
    }
  }

  @override
  Future<Group> fetchGroupById(int groupId) async {
    try {
      final response = await _dio.get('/group/$groupId');

      Group group = Group.fromJson(response.data);

      return group;
    } catch (e, stackTrace) {
      l.e('An error occured in GroupNetworkDataProvider', stackTrace);
      rethrow;
    }
  }
}
