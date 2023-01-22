DateTime getWeekStart(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);
