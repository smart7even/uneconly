import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

class Schedule {
  final List<DaySchedule> daySchedules;
  final int week;
  final ScheduleInfo info;

  const Schedule({
    required this.week,
    required this.info,
    required this.daySchedules,
  });
}
