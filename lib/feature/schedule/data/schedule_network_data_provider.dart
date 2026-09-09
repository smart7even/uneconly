import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';
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

      final hasScheduleDaysValue = response.data['has_schedule_days'];
      if (hasScheduleDaysValue != null && hasScheduleDaysValue is! bool) {
        throw const FormatException(
          'Schedule publication metadata must be a boolean',
        );
      }
      final hasScheduleDays = hasScheduleDaysValue == true;

      int responseWeek = response.data['week'];

      DateTime? responsePeriodStart;
      DateTime? responsePeriodEnd;
      final periodStartValue = response.data['period_start'];
      final periodEndValue = response.data['period_end'];
      if ((periodStartValue is String) != (periodEndValue is String)) {
        throw const FormatException(
          'Schedule period metadata must contain both boundaries',
        );
      }
      if (periodStartValue is String && periodEndValue is String) {
        responsePeriodStart = getDate(DateTime.parse(periodStartValue));
        responsePeriodEnd = getDate(DateTime.parse(periodEndValue));
      }

      if (!isValidScheduleWeek(responseWeek) ||
          (week != null && week != responseWeek)) {
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
        _validateSchedulePayload(
          lessons: lessons,
          week: responseWeek,
          periodStart: getDate(periodStart),
          periodEnd: getDate(periodEnd),
          academicYearStart: response.data['academic_year_start'] as int?,
        );
        return Schedule(
          daySchedules: hasScheduleDays
              ? [
                  for (var index = 0;
                      index <= periodEnd.difference(periodStart).inDays;
                      index++)
                    DaySchedule.empty(
                      periodStart.add(Duration(days: index)),
                    ),
                ]
              : [],
          week: responseWeek,
          info: info,
          academicYearStart: response.data['academic_year_start'] as int? ??
              getAcademicYearStartForPeriod(periodStart, periodEnd),
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
      }

      final periodStart =
          responsePeriodStart ?? getDate(getWeekStart(lessons.first.day));
      final periodEnd =
          responsePeriodEnd ?? periodStart.add(const Duration(days: 6));

      _validateSchedulePayload(
        lessons: lessons,
        week: responseWeek,
        periodStart: periodStart,
        periodEnd: periodEnd,
        academicYearStart: response.data['academic_year_start'] as int?,
      );

      var lessonsByDay = <DateTime, List<Lesson>>{};
      for (var lesson in lessons) {
        var day = getDate(lesson.day);
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

  void _validateSchedulePayload({
    required List<Lesson> lessons,
    required int week,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int? academicYearStart,
  }) {
    final dayCount = periodEnd.difference(periodStart).inDays + 1;
    final expectedPeriodStart = academicYearStart == null
        ? null
        : schedulePeriodStartForWeek(
            week: week,
            academicYearStart: academicYearStart,
          );
    final expectedPeriodEnd = academicYearStart == null
        ? null
        : schedulePeriodEndForWeek(
            week: week,
            academicYearStart: academicYearStart,
          );
    if (dayCount < 1 ||
        dayCount > 7 ||
        (expectedPeriodStart != null && periodStart != expectedPeriodStart) ||
        (expectedPeriodEnd != null && periodEnd != expectedPeriodEnd)) {
      throw const FormatException('Invalid schedule period metadata');
    }

    for (final lesson in lessons) {
      final lessonDay = getDate(lesson.day);
      if (lessonDay.isBefore(periodStart) ||
          lessonDay.isAfter(periodEnd) ||
          getDate(lesson.start) != lessonDay ||
          getDate(lesson.end) != lessonDay) {
        throw const FormatException(
          'A schedule lesson is outside its canonical period or day',
        );
      }
    }
  }
}
