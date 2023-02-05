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
