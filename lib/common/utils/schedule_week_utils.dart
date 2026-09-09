const minScheduleWeek = 1;
const maxScheduleWeek = 53;

bool isValidScheduleWeek(int week) =>
    week >= minScheduleWeek && week <= maxScheduleWeek;

DateTime schedulePeriodStartForWeek({
  required int week,
  required int academicYearStart,
}) {
  if (!isValidScheduleWeek(week)) {
    throw ArgumentError.value(week, 'week', 'must be between 1 and 53');
  }

  final septemberFirst = DateTime(academicYearStart, DateTime.september);
  if (week == 1) {
    return septemberFirst;
  }

  final firstMonday = septemberFirst.add(
    Duration(days: DateTime.daysPerWeek - septemberFirst.weekday + 1),
  );
  return firstMonday.add(Duration(days: (week - 2) * DateTime.daysPerWeek));
}

DateTime schedulePeriodEndForWeek({
  required int week,
  required int academicYearStart,
}) {
  final start = schedulePeriodStartForWeek(
    week: week,
    academicYearStart: academicYearStart,
  );
  if (week == 1) {
    return start.add(Duration(days: DateTime.sunday - start.weekday));
  }
  return start.add(const Duration(days: DateTime.daysPerWeek - 1));
}

int scheduleWeekForPageIndex({
  required int pageIndex,
  required int basePageIndex,
  required int baseWeek,
}) =>
    baseWeek + pageIndex - basePageIndex;

int pageIndexForScheduleWeek({
  required int week,
  required int basePageIndex,
  required int baseWeek,
}) =>
    basePageIndex + week - baseWeek;
