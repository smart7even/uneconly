import 'package:drift/drift.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

abstract class IScheduleLocalDataProvider {
  Future<Schedule?> getSchedule(int week, int groupId);
  Future<void> saveSchedule(Schedule schedule);
}

class ScheduleLocalDataProvider implements IScheduleLocalDataProvider {
  final MyDatabase _database;

  ScheduleLocalDataProvider(this._database);

  @override
  Future<Schedule?> getSchedule(int week, int groupId) async {
    final nowTime = DateTime.now();
    final startOfWeekDateTime = getStartOfStudyWeek(week, nowTime);
    final endOfWeekDateTime = startOfWeekDateTime
        .add(
          const Duration(days: 7),
        )
        .subtract(
          const Duration(seconds: 1),
        );

    final lessons = await (_database.select(_database.lessons)
          ..where((tbl) {
            return tbl.start.year
                    .isBiggerOrEqualValue(startOfWeekDateTime.year) &
                // tbl.start.month
                //     .isBiggerOrEqualValue(startOfWeekDateTime.month) &
                // tbl.start.day.isBiggerOrEqualValue(startOfWeekDateTime.day) &
                tbl.end.year.isSmallerOrEqualValue(endOfWeekDateTime.year) &
                tbl.groupId.equals(groupId);
            // tbl.end.month.isSmallerOrEqualValue(endOfWeekDateTime.month) &
            // tbl.end.day.isSmallerOrEqualValue(endOfWeekDateTime.day);
          }))
        .get();

    final domainLessons = lessons
        .map(
          (e) => Lesson(
            name: e.name,
            day: getDate(e.start),
            dayOfWeek: '',
            start: e.start,
            end: e.end,
            professor: e.professor,
            location: e.location,
          ),
        )
        .where((element) =>
            (element.day.isAtSameMomentAs(startOfWeekDateTime) ||
                element.day.isAfter(startOfWeekDateTime)) &&
            (element.day.isAtSameMomentAs(endOfWeekDateTime) ||
                element.day.isBefore(endOfWeekDateTime)))
        .toList();

    if (domainLessons.isEmpty) {
      return null;
    }

    final days = [
      for (int i = 0; i < 7; i++) startOfWeekDateTime.add(Duration(days: i)),
    ];
    List<DaySchedule> daySchedules = [];

    for (var day in days) {
      daySchedules.add(
        DaySchedule(
          day: day,
          lessons:
              domainLessons.where((element) => element.day == day).toList(),
        ),
      );
    }

    return Schedule(
      week: week,
      daySchedules: daySchedules,
      groupId: groupId,
    );
  }

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    DateTime currentDateTime = DateTime.now();

    return _database.transaction(() async {
      for (final daySchedule in schedule.daySchedules) {
        await _deleteDaySchedule(daySchedule);

        for (final lesson in daySchedule.lessons) {
          // save to db
          await _database.into(_database.lessons).insert(
                LessonsCompanion(
                  name: Value(lesson.name),
                  professor: Value(lesson.professor),
                  location: Value(lesson.location),
                  start: Value(lesson.start),
                  end: Value(lesson.end),
                  createdAt: Value(currentDateTime),
                  groupId: Value(schedule.groupId),
                ),
              );
        }
      }
    });
  }

  Future<void> _deleteDaySchedule(DaySchedule daySchedule) async {
    final deleteStamement = _database.delete(_database.lessons)
      ..where(
        (tbl) =>
            tbl.start.year.equals(daySchedule.day.year) &
            tbl.start.month.equals(daySchedule.day.month) &
            tbl.start.day.equals(daySchedule.day.day),
      );

    await deleteStamement.go();

    return;
  }
}
