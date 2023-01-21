import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

abstract class IScheduleNetworkDataProvider {
  Future<Schedule> fetch({int? groupId, int? week});
}

class ScheduleNetworkDataProvider implements IScheduleNetworkDataProvider {
  ScheduleNetworkDataProvider({
    required final Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<Schedule> fetch({int? groupId, int? week}) async {
    // fetch data from /group/:id/schedule?week=21 endpoint
    try {
      final response = await _dio.get(
        '/group/$groupId/schedule',
        queryParameters: {
          'week': week,
        },
      );

      List<Lesson> lessons = (response.data['lessons'] as List<dynamic>)
          .map<Lesson>((lesson) => Lesson.fromJson(lesson))
          .toList();

      return Schedule(lessons: lessons);
    } on Object catch (e, stackTrace) {
      l.e('An error occured in ScheduleNetworkDataProvider', stackTrace);
      rethrow;
    }
  }
}
