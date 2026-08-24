import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

void main() {
  const info = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 13872, groupName: 'БИ-2501'),
  );

  Lesson lesson({
    required DateTime day,
    required int professorId,
    required String professor,
    required String location,
  }) =>
      Lesson(
        name: 'Иностранный язык (Практика)',
        day: day,
        dayOfWeek: '',
        start: DateTime(day.year, day.month, day.day, 14, 30),
        end: DateTime(day.year, day.month, day.day, 16),
        professor: professor,
        location: location,
        lessonType: 'Практика',
        group: null,
        professorId: professorId,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('subject choice follows professor while the current room can change',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = LessonChoiceRepository(preferences);
    final first = lesson(
      day: DateTime(2025, 9, 3),
      professorId: 113246,
      professor: 'Кленова Екатерина Андреевна',
      location: '88 ауд.',
    );
    final later = lesson(
      day: DateTime(2025, 9, 5),
      professorId: 113246,
      professor: 'Кленова Екатерина Андреевна',
      location: '79 ауд.',
    );

    await repository.save(
      info: info,
      lesson: first,
      alternativeId: lessonAlternativeId(first),
      scope: LessonChoiceScope.subject,
    );

    final resolved = repository.resolve(info: info, lesson: later);
    expect(resolved?.alternativeId, 'professor:113246');
    expect(resolved?.scope, LessonChoiceScope.subject);
    expect(later.location, '79 ауд.');
  });

  test('date exception takes precedence over weekday and subject', () async {
    final preferences = await SharedPreferences.getInstance();
    final repository = LessonChoiceRepository(preferences);
    final wednesday = lesson(
      day: DateTime(2025, 9, 3),
      professorId: 1,
      professor: 'Основной преподаватель',
      location: '1 ауд.',
    );

    await repository.save(
      info: info,
      lesson: wednesday,
      alternativeId: 'professor:1',
      scope: LessonChoiceScope.subject,
    );
    await repository.save(
      info: info,
      lesson: wednesday,
      alternativeId: 'professor:2',
      scope: LessonChoiceScope.weekday,
    );
    await repository.save(
      info: info,
      lesson: wednesday,
      alternativeId: 'professor:3',
      scope: LessonChoiceScope.date,
    );

    final resolved = repository.resolve(info: info, lesson: wednesday);
    expect(resolved?.alternativeId, 'professor:3');
    expect(resolved?.scope, LessonChoiceScope.date);
  });

  test('lesson subject key shares preference across lesson types', () {
    expect(
      lessonSubjectKey('Иностранный язык (Экзамен)'),
      lessonSubjectKey('Иностранный язык (Практика)'),
    );
  });
}
