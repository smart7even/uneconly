import 'package:uneconly/feature/schedule/model/day_schedule.dart';

class Schedule {
  final List<DaySchedule> daySchedules;
  final int week;

  const Schedule({
    required this.week,
    required this.daySchedules,
  });

  const Schedule.empty()
      : daySchedules = const <DaySchedule>[],
        week = 0;
}
