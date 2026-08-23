import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/model/schedule_context.dart';

abstract class IScheduleNetworkDataProvider {
  Future<Schedule> fetch({
    required ScheduleInfo info,
    int? week,
  });
  Future<ScheduleContext> fetchContext();
}

class ScheduleNetworkDataProvider implements IScheduleNetworkDataProvider {
  ScheduleNetworkDataProvider({
    required final Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<ScheduleContext> fetchContext() async {
    final response = await _dio.get('/schedule/context');
    return ScheduleContext.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Schedule> fetch({required ScheduleInfo info, int? week}) async {
    // fetch data from /group/:id/schedule?week=21 endpoint
    try {
      final queryParameters = <String, dynamic>{};

      if (week != null) {
        queryParameters['week'] = week;
      }

      final url = info.map(
        group: (group) => '/group/${group.shortGroupInfo.groupId}/schedule',
        professor: (professor) =>
            '/professor/${professor.shortProfessorInfo.professorId}/schedule',
      );

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
      );

      List<Lesson> lessons = (response.data['lessons'] as List<dynamic>)
          .map<Lesson>((lesson) => Lesson.fromJson(lesson))
          .toList();

      int responseWeek = response.data['week'];

      DateTime? responsePeriodStart;
      DateTime? responsePeriodEnd;
      final periodStartValue = response.data['period_start'];
      final periodEndValue = response.data['period_end'];
      if (periodStartValue is String && periodEndValue is String) {
        responsePeriodStart = DateTime.parse(periodStartValue);
        responsePeriodEnd = DateTime.parse(periodEndValue);
      }

      if (week != null && week != responseWeek) {
        throw Exception('Weeks do not match');
      }

      if (lessons.isEmpty) {
        final fallbackStart = getStartOfStudyWeek(
          responseWeek,
          DateTime.now(),
        );
        final periodStart = responsePeriodStart ?? fallbackStart;
        final periodEnd =
            responsePeriodEnd ?? periodStart.add(const Duration(days: 6));
        return Schedule(
          daySchedules: [],
          week: responseWeek,
          info: info,
          academicYearStart: response.data['academic_year_start'] as int? ??
              getAcademicYearStartForPeriod(periodStart, periodEnd),
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
      }

      var weekStart = getWeekStart(lessons.first.day);
      final periodStart = responsePeriodStart ?? weekStart;
      final periodEnd =
          responsePeriodEnd ?? periodStart.add(const Duration(days: 6));

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
        week: responseWeek,
        info: info,
        academicYearStart: response.data['academic_year_start'] as int? ??
            getAcademicYearStartForPeriod(periodStart, periodEnd),
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    } on Object catch (e, stackTrace) {
      l.e('An error occured in ScheduleNetworkDataProvider', stackTrace);
      rethrow;
    }
  }
}
