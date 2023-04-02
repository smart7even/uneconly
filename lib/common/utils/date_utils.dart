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

DateTime getStartOfStudyYearDate(DateTime nowTime) {
  if (nowTime.month >= kSeptemberMonthNumber) {
    return getWeekStart(
      DateTime(
        nowTime.year,
        kSeptemberMonthNumber,
        1,
      ),
    );
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
