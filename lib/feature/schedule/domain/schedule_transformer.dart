import 'package:intl/intl.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';

class ScheduleTransformer {
  String transformScheduleToString(
    Schedule schedule,
    String? title, {
    LessonChoiceRepository? choiceRepository,
  }) {
    const space = ' ';
    const newLine = '\n';
    String result = '';

    if (title != null) {
      result += title;
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
      result += DateFormat('EEE').format(daySchedule.day);
      result += newLine;

      if (daySchedule.lessons.isEmpty) {
        result += 'Нет пар';
        result += newLine;
      }

      final combineAlternatives = schedule.info.map(
        group: (_) => true,
        professor: (_) => false,
      );
      final clusters = clusterParallelLessons(
        daySchedule.lessons,
        combineAlternatives: combineAlternatives,
      );

      for (final cluster in clusters) {
        final lesson = _resolveLesson(
          cluster,
          schedule,
          choiceRepository,
        );
        result +=
            '${DateFormat('HH:mm').format(lesson.start)} - ${DateFormat('HH:mm').format(lesson.end)}';
        result += newLine;
        result += lessonDisplayName(lesson);
        result += newLine;
        if (cluster.hasAlternatives &&
            choiceRepository != null &&
            !_hasResolvedChoice(cluster, schedule, choiceRepository)) {
          result += 'Подгруппа не выбрана';
          result += newLine;
        } else {
          final professor = lesson.professor?.trim();
          if (professor != null && professor.isNotEmpty) {
            result += professor;
            result += newLine;
          }
          final location = trimSeparators(cleanLessonLocation(lesson.location));
          if (location.isNotEmpty) {
            result += location;
            result += newLine;
          }
        }
      }

      result += newLine;
    }

    return result;
  }

  Lesson _resolveLesson(
    LessonCluster cluster,
    Schedule schedule,
    LessonChoiceRepository? repository,
  ) {
    if (!cluster.hasAlternatives || repository == null) return cluster.lesson;
    final resolution = repository.resolve(
      info: schedule.info,
      lesson: cluster.lesson,
    );
    if (resolution == null) return cluster.lesson;
    return cluster.alternatives.firstWhere(
      (lesson) => lessonAlternativeId(lesson) == resolution.alternativeId,
      orElse: () => cluster.lesson,
    );
  }

  bool _hasResolvedChoice(
    LessonCluster cluster,
    Schedule schedule,
    LessonChoiceRepository repository,
  ) {
    final resolution = repository.resolve(
      info: schedule.info,
      lesson: cluster.lesson,
    );
    return resolution != null &&
        cluster.alternatives.any(
          (lesson) => lessonAlternativeId(lesson) == resolution.alternativeId,
        );
  }
}
