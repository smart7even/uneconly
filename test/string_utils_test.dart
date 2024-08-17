import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/utils/string_utils.dart';

void main() {
  test(
    'trim separators trims all spaces and newlines between words in string',
    () {
      expect(
        trimSeparators('Room 75. \nCentral Bank street 23'),
        equals('Room 75. Central Bank street 23'),
      );
    },
  );
}
