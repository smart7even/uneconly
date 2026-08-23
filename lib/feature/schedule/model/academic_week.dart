class AcademicWeek {
  final int academicYearStart;
  final int week;
  final DateTime periodStart;
  final DateTime periodEnd;

  const AcademicWeek({
    required this.academicYearStart,
    required this.week,
    required this.periodStart,
    required this.periodEnd,
  });

  factory AcademicWeek.fromJson(Map<String, dynamic> json) {
    return AcademicWeek(
      academicYearStart: json['academic_year_start'] as int,
      week: json['week'] as int,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
    );
  }
}
