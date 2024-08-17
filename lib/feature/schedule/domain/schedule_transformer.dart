import 'package:intl/intl.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

class ScheduleTransformer {
  String transformScheduleToString(
    Schedule schedule,
    ShortGroupInfo groupInfo,
  ) {
    const space = ' ';
    const newLine = '\n';
    String result = '';

    final groupName = groupInfo.groupName;

    if (groupName != null) {
      result += groupName;
      result += newLine;
    }

    result += 'Неделя ${schedule.week}';
    result += newLine;
    result += newLine;

    if (schedule.daySchedules.isEmpty) {
      result += 'Нет расписания на эту неделю';
      result += newLine;
    }

    for (final daySchedule in schedule.daySchedules) {
      result += DateFormat('dd.MM.yyyy').format(daySchedule.day);
      result += space;
      result += DateFormat('EEE', 'ru').format(daySchedule.day);
      result += newLine;

      if (daySchedule.lessons.isEmpty) {
        result += 'Нет пар';
        result += newLine;
      }

      for (final lesson in daySchedule.lessons) {
        result +=
            '${DateFormat('HH:mm').format(lesson.start)} - ${DateFormat('HH:mm').format(lesson.end)}';
        result += newLine;
        result += lesson.name;
        result += newLine;
        result += trimSeparators(lesson.location);
        result += newLine;
      }

      result += newLine;
    }

    return result;
  }
}
