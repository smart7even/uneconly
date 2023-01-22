import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
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

      if (lessons.isEmpty) {
        return const Schedule.empty();
      }

      var weekStart = getWeekStart(lessons.first.day);

      var lessonsByDay = <DateTime, List<Lesson>>{};
      for (var lesson in lessons) {
        var day = lesson.day;
        if (lessonsByDay.containsKey(day)) {
          lessonsByDay[day]!.add(lesson);
        } else {
          lessonsByDay[day] = [lesson];
        }
      }

      var daySchedules = <DaySchedule>[];

      for (var entry in lessonsByDay.entries) {
        daySchedules.add(
          DaySchedule(
            day: entry.key,
            lessons: entry.value,
          ),
        );
      }

      daySchedules.sort((a, b) => a.day.compareTo(b.day));

      if (daySchedules.isNotEmpty) {
        int weekday = 1;
        int daySchedulesIndex = 0;

        while (weekday <= 7) {
          if (daySchedulesIndex >= daySchedules.length) {
            daySchedules.insert(
              daySchedulesIndex,
              DaySchedule.empty(
                weekStart.add(
                  Duration(
                    days: weekday - 1,
                  ),
                ),
              ),
            );
          }

          var daySchedule = daySchedules[daySchedulesIndex];
          if (daySchedule.day.weekday != weekday) {
            daySchedules.insert(
              daySchedulesIndex,
              DaySchedule.empty(
                weekStart.add(
                  Duration(
                    days: weekday - 1,
                  ),
                ),
              ),
            );
          }
          daySchedulesIndex++;
          weekday++;
        }
      }

      return Schedule(
        daySchedules: daySchedules,
      );
    } on Object catch (e, stackTrace) {
      l.e('An error occured in ScheduleNetworkDataProvider', stackTrace);
      rethrow;
    }
  }
}
