import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

class Schedule {
  final List<DaySchedule> daySchedules;
  final int week;
  final ScheduleInfo info;
  final int academicYearStart;
  final DateTime periodStart;
  final DateTime periodEnd;

  const Schedule({
    required this.week,
    required this.info,
    required this.daySchedules,
    required this.academicYearStart,
    required this.periodStart,
    required this.periodEnd,
  });
}
