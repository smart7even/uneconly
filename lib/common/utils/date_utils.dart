DateTime getWeekStart(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

int calculateDifferenceInDays(DateTime date1, DateTime date2) {
  return DateTime(
    date1.year,
    date1.month,
    date1.day,
  )
      .difference(
        DateTime(
          date2.year,
          date2.month,
          date2.day,
        ),
      )
      .inDays;
}

const kSeptemberMonthNumber = 9;
const kNumberOfDaysInWeek = 7;

int getStudyWeekNumber(DateTime dateTime, DateTime nowTime) {
  final startOfStudyYearDate = getStartOfStudyYearDate(nowTime);

  int days = calculateDifferenceInDays(dateTime, startOfStudyYearDate);

  return (days / kNumberOfDaysInWeek + 1).floor();
}

DateTime getStartOfStudyWeek(int week, DateTime nowTime) {
  final startOfStudyYearDate = getStartOfStudyYearDate(nowTime);

  final startWeekDate = startOfStudyYearDate.add(
    Duration(
      days: (week - 1) * 7,
    ),
  );

  return startWeekDate;
}

DateTime getEndOfStudyWeek(int week, DateTime nowTime) {
  return getStartOfStudyWeek(week, nowTime).add(
    const Duration(
      days: 6,
    ),
  );
}

DateTime getStartOfStudyYearDate(DateTime nowTime) {
  final currentStudyYearStartDate = getWeekStart(
    DateTime(
      nowTime.year,
      kSeptemberMonthNumber,
      1,
    ),
  );

  if (nowTime.isAtSameMomentAs(currentStudyYearStartDate) ||
      nowTime.isAfter(currentStudyYearStartDate)) {
    return currentStudyYearStartDate;
  } else {
    return getWeekStart(
      DateTime(
        nowTime.year - 1,
        kSeptemberMonthNumber,
        1,
      ),
    );
  }
}

int getAcademicYearStartForPeriod(DateTime start, DateTime end) {
  for (int year = start.year; year <= end.year; year++) {
    final septemberFirst = DateTime(year, DateTime.september);
    if (!septemberFirst.isBefore(start) && !septemberFirst.isAfter(end)) {
      return year;
    }
  }

  return start.month >= DateTime.september ? start.year : start.year - 1;
}
