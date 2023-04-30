import 'package:uneconly/feature/schedule/model/day_schedule.dart';

class Schedule {
  final List<DaySchedule> daySchedules;
  final int week;
  final int groupId;

  const Schedule({
    required this.week,
    required this.groupId,
    required this.daySchedules,
  });

  const Schedule.empty()
      : daySchedules = const <DaySchedule>[],
        groupId = 0,
        week = 0;
}
