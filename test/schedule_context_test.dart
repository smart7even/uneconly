import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/feature/schedule/model/schedule_context.dart';

void main() {
  test('parses an early-published new academic year recommendation', () {
    final context = ScheduleContext.fromJson({
      'source_academic_year_start': 2026,
      'calendar_current': {
        'academic_year_start': 2025,
        'week': 52,
        'period_start': '2026-08-24',
        'period_end': '2026-08-30',
      },
      'source_current': {
        'academic_year_start': 2025,
        'week': 52,
        'period_start': '2026-08-24',
        'period_end': '2026-08-30',
      },
      'upcoming': {
        'academic_year_start': 2026,
        'week': 1,
        'period_start': '2026-08-31',
        'period_end': '2026-09-06',
        'published': true,
      },
      'recommended': {
        'academic_year_start': 2026,
        'week': 1,
        'period_start': '2026-08-31',
        'period_end': '2026-09-06',
      },
    });

    expect(context.upcomingPublished, isTrue);
    expect(context.recommended.week, equals(1));
    expect(context.recommended.academicYearStart, equals(2026));
    expect(context.recommended.periodStart, equals(DateTime(2026, 8, 31)));
  });
}
