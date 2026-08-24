import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/utils/schedule_week_utils.dart';

void main() {
  test('only university schedule weeks 1 through 53 are valid', () {
    expect(isValidScheduleWeek(0), isFalse);
    expect(isValidScheduleWeek(1), isTrue);
    expect(isValidScheduleWeek(53), isTrue);
    expect(isValidScheduleWeek(54), isFalse);
  });
}
