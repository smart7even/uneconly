import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/common/utils/string_utils.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

/// The same resolved week is used for text and image sharing.
class ScheduleShareDocument {
  ScheduleShareDocument._({
    required this.title,
    required this.week,
    required this.periodStart,
    required this.periodEnd,
    required this.days,
    required this.updatedAt,
  });

  final String title;
  final int week;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<ScheduleShareDay> days;
  final DateTime? updatedAt;

  factory ScheduleShareDocument.fromSchedule(
    Schedule schedule, {
    required String title,
    LessonChoiceRepository? choiceRepository,
    DateTime? updatedAt,
  }) {
    final isGroup = schedule.info.map(
      group: (_) => true,
      professor: (_) => false,
    );
    final sourceDays = {
      for (final day in schedule.daySchedules) _dateKey(day.day): day.lessons,
    };
    final days = <ScheduleShareDay>[];
    var date = DateTime(
      schedule.periodStart.year,
      schedule.periodStart.month,
      schedule.periodStart.day,
    );
    final end = DateTime(
      schedule.periodEnd.year,
      schedule.periodEnd.month,
      schedule.periodEnd.day,
    );

    while (!date.isAfter(end)) {
      final clusters = clusterParallelLessons(
        sourceDays[_dateKey(date)] ?? const <Lesson>[],
        combineAlternatives: isGroup,
      );
      final lessons = <ScheduleShareLesson>[];
      for (final cluster in clusters) {
        final resolution = cluster.hasAlternatives && choiceRepository != null
            ? choiceRepository.resolve(
                info: schedule.info,
                lesson: cluster.lesson,
              )
            : null;
        final selected = resolution == null
            ? null
            : cluster.alternatives
                  .where(
                    (candidate) =>
                        lessonAlternativeId(candidate) ==
                        resolution.alternativeId,
                  )
                  .firstOrNull;
        final unresolved = cluster.hasAlternatives && selected == null;
        final lesson = selected ?? cluster.lesson;
        lessons.add(
          ScheduleShareLesson(
            start: lesson.start,
            end: lesson.end,
            subject: lessonDisplayName(lesson),
            type: lesson.lessonType?.trim() ?? '',
            detail: unresolved
                ? 'Подгруппа не выбрана'
                : [
                    isGroup
                        ? lesson.professor?.trim() ?? ''
                        : lesson.group?.trim() ?? '',
                    trimSeparators(cleanLessonLocation(lesson.location)),
                  ].where((part) => part.isNotEmpty).join(' · '),
            unresolvedSubgroup: unresolved,
          ),
        );
      }
      days.add(ScheduleShareDay(date: date, lessons: lessons));
      date = DateTime(date.year, date.month, date.day + 1);
    }

    return ScheduleShareDocument._(
      title: title.trim(),
      week: schedule.week,
      periodStart: schedule.periodStart,
      periodEnd: schedule.periodEnd,
      days: days,
      updatedAt: updatedAt,
    );
  }

  String get periodLabel =>
      '${formatShareDate(periodStart)}–${formatShareDate(periodEnd)}';

  String toPlainText() {
    final lines = <String>[
      if (title.isNotEmpty) title,
      'Неделя $week · $periodLabel',
    ];
    if (days.every((day) => day.lessons.isEmpty)) {
      lines.add('Нет расписания на эту неделю');
    } else {
      for (final day in days) {
        lines.add('');
        lines.add('${shareWeekday(day.date)}, ${formatShareDate(day.date)}');
        if (day.lessons.isEmpty) {
          lines.add('Нет пар');
          continue;
        }
        for (final lesson in day.lessons) {
          lines.add(
            '${formatShareTime(lesson.start)}–${formatShareTime(lesson.end)}  '
            '${lesson.subject}${lesson.type.isEmpty ? '' : ' (${lesson.type})'}',
          );
          if (lesson.detail.isNotEmpty) lines.add(lesson.detail);
        }
      }
    }
    lines.add('');
    if (updatedAt != null) {
      lines.add(
        'Данные обновлены ${formatShareDate(updatedAt!)} '
        '${formatShareTime(updatedAt!)}',
      );
    }
    lines.add('Расписание может измениться · Uneconly');
    return lines.join('\n');
  }
}

class ScheduleShareDay {
  const ScheduleShareDay({required this.date, required this.lessons});

  final DateTime date;
  final List<ScheduleShareLesson> lessons;
}

class ScheduleShareLesson {
  const ScheduleShareLesson({
    required this.start,
    required this.end,
    required this.subject,
    required this.type,
    required this.detail,
    required this.unresolvedSubgroup,
  });

  final DateTime start;
  final DateTime end;
  final String subject;
  final String type;
  final String detail;
  final bool unresolvedSubgroup;
}

String _dateKey(DateTime value) => '${value.year}-${value.month}-${value.day}';

String formatShareDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';

String formatShareTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

String shareWeekday(DateTime value) => const [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
][value.weekday - 1];
