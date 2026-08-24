import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/domain/schedule_transformer.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

void main() {
  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 1, groupName: 'БИ-2501'),
  );
  final day = DateTime(2026, 9, 1);

  Lesson language(int id, String professor, String room) => Lesson(
        name: 'Иностранный язык (Практика)',
        day: day,
        dayOfWeek: 'ВТ',
        start: DateTime(2026, 9, 1, 9),
        end: DateTime(2026, 9, 1, 10, 35),
        professor: professor,
        location: '$room ауд. НА СХЕМЕ ЛИНГВОБАШНИ',
        lessonType: 'Практика',
        group: null,
        professorId: id,
      );

  Schedule schedule(List<Lesson> lessons) => Schedule(
        week: 1,
        info: info,
        daySchedules: [DaySchedule(day: day, lessons: lessons)],
        academicYearStart: 2026,
        periodStart: day,
        periodEnd: day.add(const Duration(days: 6)),
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('share contains only the selected subgroup', () async {
    final repository = LessonChoiceRepository(
      await SharedPreferences.getInstance(),
    );
    final josh = language(1, 'Джош', '64');
    final helen = language(2, 'Хелен', '88');
    await repository.save(
      info: info,
      lesson: helen,
      alternativeId: lessonAlternativeId(helen),
      scope: LessonChoiceScope.subject,
    );

    final text = ScheduleTransformer().transformScheduleToString(
      schedule([josh, helen]),
      'БИ-2501',
      choiceRepository: repository,
    );

    expect(text, contains('Хелен'));
    expect(text, contains('88 ауд.'));
    expect(text, isNot(contains('Джош')));
    expect(text, isNot(contains('64 ауд.')));
    expect('Иностранный язык'.allMatches(text), hasLength(1));
    expect(text, isNot(contains('НА СХЕМЕ')));
  });

  test('unresolved subgroup is compact and does not guess a professor',
      () async {
    final repository = LessonChoiceRepository(
      await SharedPreferences.getInstance(),
    );
    final text = ScheduleTransformer().transformScheduleToString(
      schedule([language(1, 'Джош', '64'), language(2, 'Хелен', '88')]),
      'БИ-2501',
      choiceRepository: repository,
    );

    expect(text, contains('Подгруппа не выбрана'));
    expect(text, isNot(contains('Джош')));
    expect(text, isNot(contains('Хелен')));
    expect('Иностранный язык'.allMatches(text), hasLength(1));
  });
}
