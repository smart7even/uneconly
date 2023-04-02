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
}
