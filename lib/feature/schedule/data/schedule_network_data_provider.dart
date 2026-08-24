import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';
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
  Future<AppConfig> fetchAppConfig();
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
  Future<AppConfig> fetchAppConfig() async {
    final response = await _dio.get('/app/config');
    return AppConfig.fromJson(response.data as Map<String, dynamic>);
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

      final periodStart =
          responsePeriodStart ?? getWeekStart(lessons.first.day);
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

      final dayCount = periodEnd.difference(periodStart).inDays + 1;
      final daySchedules = [
        for (var index = 0; index < dayCount; index++)
          DaySchedule(
            day: periodStart.add(Duration(days: index)),
            lessons:
                lessonsByDay[getDate(periodStart.add(Duration(days: index)))] ??
                    const [],
          ),
      ];

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
