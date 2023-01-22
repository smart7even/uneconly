import 'package:uneconly/feature/schedule/model/day_schedule.dart';

class Schedule {
  final List<DaySchedule> daySchedules;

  const Schedule({
    required this.daySchedules,
  });

  const Schedule.empty() : daySchedules = const <DaySchedule>[];
}
