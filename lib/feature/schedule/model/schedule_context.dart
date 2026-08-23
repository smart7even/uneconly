import 'package:uneconly/feature/schedule/model/academic_week.dart';

class ScheduleContext {
  final int sourceAcademicYearStart;
  final AcademicWeek calendarCurrent;
  final AcademicWeek sourceCurrent;
  final AcademicWeek upcoming;
  final bool upcomingPublished;
  final AcademicWeek recommended;

  const ScheduleContext({
    required this.sourceAcademicYearStart,
    required this.calendarCurrent,
    required this.sourceCurrent,
    required this.upcoming,
    required this.upcomingPublished,
    required this.recommended,
  });

  factory ScheduleContext.fromJson(Map<String, dynamic> json) {
    final upcomingJson = json['upcoming'] as Map<String, dynamic>;
    return ScheduleContext(
      sourceAcademicYearStart: json['source_academic_year_start'] as int,
      calendarCurrent: AcademicWeek.fromJson(
        json['calendar_current'] as Map<String, dynamic>,
      ),
      sourceCurrent: AcademicWeek.fromJson(
        json['source_current'] as Map<String, dynamic>,
      ),
      upcoming: AcademicWeek.fromJson(upcomingJson),
      upcomingPublished: upcomingJson['published'] as bool,
      recommended: AcademicWeek.fromJson(
        json['recommended'] as Map<String, dynamic>,
      ),
    );
  }
}
