import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/domain/schedule_share_document.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';

class ScheduleTransformer {
  String transformScheduleToString(
    Schedule schedule,
    String? title, {
    LessonChoiceRepository? choiceRepository,
  }) => ScheduleShareDocument.fromSchedule(
    schedule,
    title: title ?? '',
    choiceRepository: choiceRepository,
  ).toPlainText();
}
