import 'package:drift/drift.dart';
import 'package:uneconly/common/database/database.dart';
import 'package:uneconly/common/database/tables/schedule_periods.dart';
import 'package:uneconly/common/utils/date_utils.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

String scheduleCacheScope(ScheduleInfo info) => info.map(
      group: (group) => 'group:${group.shortGroupInfo.groupId}',
      professor: (professor) =>
          'professor:${professor.shortProfessorInfo.professorId}',
    );

abstract class IScheduleLocalDataProvider {
  Future<ScheduleCacheEntry?> getSchedule(
    int week,
    ScheduleInfo info,
    int? academicYearStart,
  );
  Future<ScheduleCacheEntry?> getClosestSchedule(
    DateTime date,
    ScheduleInfo info,
  );
  Future<void> saveSchedule(Schedule schedule);
}

class ScheduleLocalDataProvider implements IScheduleLocalDataProvider {
  final MyDatabase _database;

  ScheduleLocalDataProvider(this._database);

  @override
  Future<ScheduleCacheEntry?> getClosestSchedule(
    DateTime date,
    ScheduleInfo info,
  ) async {
    final periods = await (_database.select(_database.schedulePeriods)
          ..where(
            (table) =>
                table.scope.equals(scheduleCacheScope(info)) &
                table.cacheVersion.equals(currentScheduleCacheVersion),
          ))
        .get();
    final targetDate = getDate(date);

    periods.sort((left, right) {
      final distanceComparison = _distanceFromPeriod(targetDate, left)
          .compareTo(_distanceFromPeriod(targetDate, right));
      if (distanceComparison != 0) {
        return distanceComparison;
      }
      return right.academicYearStart.compareTo(left.academicYearStart);
    });

    // A period row can survive while its lessons were cleared. Try the next
    // closest complete cache entry rather than treating the first row as data.
    for (final period in periods) {
      final entry = await getSchedule(
        period.week,
        info,
        period.academicYearStart,
      );
      if (entry != null) {
        return entry;
      }
    }
    return null;
  }

  int _distanceFromPeriod(
    DateTime date,
    SchedulePeriodDatabaseEntity period,
  ) {
    final start = getDate(period.periodStart);
    final end = getDate(period.periodEnd);
    if (date.isBefore(start)) {
      return start.difference(date).inDays;
    }
    if (date.isAfter(end)) {
      return date.difference(end).inDays;
    }
    return 0;
  }

  @override
  Future<ScheduleCacheEntry?> getSchedule(
    int week,
    ScheduleInfo info,
    int? academicYearStart,
  ) async {
    final scope = scheduleCacheScope(info);
    final cachedPeriod = await (_database.select(_database.schedulePeriods)
          ..where(
              (table) => table.scope.equals(scope) & table.week.equals(week)))
        .getSingleOrNull();

    // Lessons alone don't define a schedule week. In particular, the first
    // academic week can be shorter than seven days. Reconstructing a period
    // from a UI-provided date used to expose a transient 8–14 September cache
    // state before the server returned the canonical 7–13 September period.
    if (cachedPeriod == null ||
        !isValidScheduleWeek(week) ||
        cachedPeriod.cacheVersion != currentScheduleCacheVersion ||
        (academicYearStart != null &&
            cachedPeriod.academicYearStart != academicYearStart)) {
      return null;
    }

    final startOfWeekDateTime = getDate(cachedPeriod.periodStart);
    final periodEnd = getDate(cachedPeriod.periodEnd);
    final periodDayCount = periodEnd.difference(startOfWeekDateTime).inDays + 1;
    final expectedPeriodStart = schedulePeriodStartForWeek(
      week: week,
      academicYearStart: cachedPeriod.academicYearStart,
    );
    final expectedPeriodEnd = schedulePeriodEndForWeek(
      week: week,
      academicYearStart: cachedPeriod.academicYearStart,
    );
    if (periodDayCount < 1 ||
        periodDayCount > 7 ||
        startOfWeekDateTime != expectedPeriodStart ||
        periodEnd != expectedPeriodEnd) {
      return null;
    }
    final endOfWeekDateTime = getDate(periodEnd)
        .add(
          const Duration(days: 1),
        )
        .subtract(
          const Duration(seconds: 1),
        );

    final expression = info.map(
      group: (group) {
        return ($LessonsTable tbl) => tbl.groupId.equals(
              group.shortGroupInfo.groupId,
            );
      },
      professor: (professor) {
        return ($LessonsTable tbl) =>
            tbl.professorId.equals(
              professor.shortProfessorInfo.professorId,
            ) &
            // Group-cache rows also carry the lesson's professorId. Only rows
            // without a groupId belong to a professor-schedule cache entry.
            tbl.groupId.isNull();
      },
    );

    final lessons = await (_database.select(_database.lessons)
          ..where((tbl) {
            return tbl.start.isBiggerOrEqualValue(startOfWeekDateTime) &
                tbl.start.isSmallerOrEqualValue(endOfWeekDateTime) &
                expression(tbl);
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
            location: cleanLessonLocation(e.location),
            lessonType: e.lessonType,
            professorId: e.professorId,
            group: e.group,
            roomUrl: e.roomUrl,
          ),
        )
        .where((element) =>
            (element.day.isAtSameMomentAs(startOfWeekDateTime) ||
                element.day.isAfter(startOfWeekDateTime)) &&
            (element.day.isAtSameMomentAs(endOfWeekDateTime) ||
                element.day.isBefore(endOfWeekDateTime)))
        .toList();

    // The network provider uses an empty day list as the explicit
    // "schedule is not published for this week" sentinel. A separate persisted
    // flag preserves the equally valid case where a published period contains
    // seven confirmed free days and therefore also has no lesson rows.
    // `domainLessons.isNotEmpty` keeps pre-v9 caches with real lessons usable.
    final hasScheduleDays =
        cachedPeriod.hasScheduleDays || domainLessons.isNotEmpty;
    final days = hasScheduleDays
        ? [
            for (int i = 0;
                i <=
                    getDate(periodEnd)
                        .difference(getDate(startOfWeekDateTime))
                        .inDays;
                i++)
              startOfWeekDateTime.add(Duration(days: i)),
          ]
        : const <DateTime>[];
    final daySchedules = [
      for (final day in days)
        DaySchedule(
          day: day,
          lessons:
              domainLessons.where((element) => element.day == day).toList(),
        ),
    ];

    return ScheduleCacheEntry(
      schedule: Schedule(
        week: week,
        daySchedules: daySchedules,
        info: info,
        academicYearStart: cachedPeriod.academicYearStart,
        periodStart: startOfWeekDateTime,
        periodEnd: periodEnd,
      ),
      updatedAt: cachedPeriod.updatedAt,
    );
  }

  @override
  Future<void> saveSchedule(Schedule schedule) async {
    DateTime currentDateTime = DateTime.now();
    final periodStart = getDate(schedule.periodStart);
    final periodEnd = getDate(schedule.periodEnd);
    final periodDayCount = periodEnd.difference(periodStart).inDays + 1;
    final expectedPeriodStart = schedulePeriodStartForWeek(
      week: schedule.week,
      academicYearStart: schedule.academicYearStart,
    );
    final expectedPeriodEnd = schedulePeriodEndForWeek(
      week: schedule.week,
      academicYearStart: schedule.academicYearStart,
    );

    if (!isValidScheduleWeek(schedule.week) ||
        periodDayCount < 1 ||
        periodDayCount > 7 ||
        periodStart != expectedPeriodStart ||
        periodEnd != expectedPeriodEnd) {
      throw ArgumentError.value(
        schedule,
        'schedule',
        'Invalid week, period length, or academic-year metadata',
      );
    }

    for (final daySchedule in schedule.daySchedules) {
      final day = getDate(daySchedule.day);
      if (day.isBefore(periodStart) || day.isAfter(periodEnd)) {
        throw ArgumentError.value(
          daySchedule.day,
          'schedule.daySchedules',
          'A schedule day must be inside its canonical period',
        );
      }
      for (final lesson in daySchedule.lessons) {
        final lessonDay = getDate(lesson.start);
        if (lessonDay != day ||
            getDate(lesson.end) != day ||
            getDate(lesson.day) != day) {
          throw ArgumentError.value(
            lesson.start,
            'schedule.daySchedules.lessons',
            'A lesson must belong to its containing schedule day',
          );
        }
      }
    }

    return _database.transaction(() async {
      await _database.into(_database.schedulePeriods).insertOnConflictUpdate(
            SchedulePeriodsCompanion.insert(
              scope: scheduleCacheScope(schedule.info),
              week: schedule.week,
              cacheVersion: const Value(currentScheduleCacheVersion),
              academicYearStart: schedule.academicYearStart,
              periodStart: periodStart,
              periodEnd: periodEnd,
              hasScheduleDays: Value(schedule.daySchedules.isNotEmpty),
              updatedAt: currentDateTime,
            ),
          );

      final days = [
        for (int i = 0; i < periodDayCount; i++)
          periodStart.add(Duration(days: i)),
      ];

      for (final day in days) {
        await _deleteDay(
          day,
          schedule.info,
        );
      }

      for (final daySchedule in schedule.daySchedules) {
        for (final lesson in daySchedule.lessons) {
          final lessonsCompanion = LessonsCompanion(
            name: Value(lesson.name),
            professor: Value(lesson.professor),
            location: Value(cleanLessonLocation(lesson.location)),
            start: Value(lesson.start),
            end: Value(lesson.end),
            createdAt: Value(currentDateTime),
            lessonType: Value(lesson.lessonType),
            professorId: Value(lesson.professorId),
            group: Value(lesson.group),
            roomUrl: Value(lesson.roomUrl),
          );

          final lessonsCompanionWithEntityId = schedule.info.map(
            group: (group) {
              return lessonsCompanion.copyWith(
                groupId: Value(group.shortGroupInfo.groupId),
              );
            },
            professor: (professor) {
              return lessonsCompanion.copyWith(
                professorId: Value(professor.shortProfessorInfo.professorId),
              );
            },
          );

          // save to db
          await _database.into(_database.lessons).insert(
                lessonsCompanionWithEntityId,
              );
        }
      }
    });
  }

  Future<void> _deleteDay(DateTime day, ScheduleInfo info) async {
    final Expression<bool> Function($LessonsTable) deleteCondition = info.map(
      group: (group) {
        return (tbl) =>
            tbl.start.year.equals(day.year) &
            tbl.start.month.equals(day.month) &
            tbl.start.day.equals(day.day) &
            tbl.groupId.equals(group.shortGroupInfo.groupId);
      },
      professor: (professor) {
        return (tbl) =>
            tbl.start.year.equals(day.year) &
            tbl.start.month.equals(day.month) &
            tbl.start.day.equals(day.day) &
            tbl.professorId.equals(professor.shortProfessorInfo.professorId) &
            tbl.groupId.isNull();
      },
    );

    final deleteStamement = _database.delete(_database.lessons)
      ..where(deleteCondition);

    await deleteStamement.go();

    return;
  }
}

class ScheduleCacheEntry {
  const ScheduleCacheEntry({
    required this.schedule,
    required this.updatedAt,
  });

  final Schedule schedule;
  final DateTime updatedAt;
}
