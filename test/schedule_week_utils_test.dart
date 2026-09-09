import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';

void main() {
  test('only university schedule weeks 1 through 53 are valid', () {
    expect(isValidScheduleWeek(0), isFalse);
    expect(isValidScheduleWeek(1), isTrue);
    expect(isValidScheduleWeek(53), isTrue);
    expect(isValidScheduleWeek(54), isFalse);
  });

  test('page position maps back to week independently of selected state', () {
    const basePageIndex = 4242;

    final nextWeekPage = pageIndexForScheduleWeek(
      week: 2,
      basePageIndex: basePageIndex,
      baseWeek: 1,
    );
    expect(nextWeekPage, 4243);
    expect(
      scheduleWeekForPageIndex(
        pageIndex: nextWeekPage - 1,
        basePageIndex: basePageIndex,
        baseWeek: 1,
      ),
      1,
    );
  });

  test('canonical periods handle a shortened first academic week', () {
    expect(
      schedulePeriodStartForWeek(week: 1, academicYearStart: 2026),
      DateTime(2026, 9, 1),
    );
    expect(
      schedulePeriodEndForWeek(week: 1, academicYearStart: 2026),
      DateTime(2026, 9, 6),
    );
    expect(
      schedulePeriodStartForWeek(week: 2, academicYearStart: 2026),
      DateTime(2026, 9, 7),
    );
    expect(
      schedulePeriodEndForWeek(week: 2, academicYearStart: 2026),
      DateTime(2026, 9, 13),
    );
  });

  test(
      'canonical periods retain a full first week when September starts Monday',
      () {
    expect(
      schedulePeriodStartForWeek(week: 1, academicYearStart: 2025),
      DateTime(2025, 9, 1),
    );
    expect(
      schedulePeriodEndForWeek(week: 1, academicYearStart: 2025),
      DateTime(2025, 9, 7),
    );
    expect(
      schedulePeriodStartForWeek(week: 2, academicYearStart: 2025),
      DateTime(2025, 9, 8),
    );
  });
}
