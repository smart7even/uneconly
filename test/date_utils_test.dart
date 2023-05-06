import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/utils/date_utils.dart';

final testNowTime = DateTime(2023, 2, 23, 20, 17, 0);

void main() {
  test('getStudyWeekNumber returns 1 when it is first week of september', () {
    final dateTime = DateTime(2022, 9, 1);

    expect(getStudyWeekNumber(dateTime, testNowTime), equals(1));
  });

  test('getStudyWeekNumber returns 2 when it is second week of september', () {
    final dateTime = DateTime(2022, 9, 5);

    expect(getStudyWeekNumber(dateTime, testNowTime), equals(2));
  });

  test(
    'getStudyWeekNumber returns 3 when it is middle of third week of september',
    () {
      final dateTime = DateTime(2022, 9, 14);

      expect(getStudyWeekNumber(dateTime, testNowTime), equals(3));
    },
  );

  test('getStudyWeekNumber returns 26 when it is 23 Feb 2023', () {
    final dateTime = DateTime(2023, 2, 23);

    expect(getStudyWeekNumber(dateTime, testNowTime), equals(26));
  });

  test('getDate returns date with hours, minutes and seconds set at zero', () {
    final dateTime = DateTime(2023, 2, 23, 20, 17, 0);

    expect(getDate(dateTime), equals(DateTime(2023, 2, 23)));
  });

  test('getStartOfStudyWeek returns start of study week', () {
    final nowTime = DateTime(2023, 5, 6, 21, 49, 11);

    expect(getStartOfStudyWeek(36, nowTime), equals(DateTime(2023, 5, 1)));
  });

  test('getWeekStart returns start of week', () {
    final nowTime = DateTime(2023, 5, 6, 21, 49, 11);

    expect(getWeekStart(nowTime), equals(DateTime(2023, 5, 1, 21, 49, 11)));
  });

  test(
    'getStartOfStudyYearDate returns start of study year when month number is less than September',
    () {
      final nowTime = DateTime(2023, 5, 6, 21, 49, 11);

      expect(
        getStartOfStudyYearDate(nowTime),
        equals(DateTime(2022, 8, 29)),
      );
    },
  );

  test(
    'getStartOfStudyYearDate returns start of study year when month number is bigger than September',
    () {
      final nowTime = DateTime(2022, 11, 11, 11, 11, 11);

      expect(
        getStartOfStudyYearDate(nowTime),
        equals(DateTime(2022, 8, 29)),
      );
    },
  );
}
