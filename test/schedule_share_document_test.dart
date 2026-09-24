import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/model/short_professor_info.dart';
import 'package:uneconly/feature/schedule/data/lesson_choice_repository.dart';
import 'package:uneconly/feature/schedule/domain/schedule_share_document.dart';
import 'package:uneconly/feature/schedule/domain/schedule_share_image_renderer.dart';
import 'package:uneconly/feature/schedule/model/day_schedule.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

void main() {
  const groupInfo = ScheduleInfo.group(
    shortGroupInfo: ShortGroupInfo(groupId: 1, groupName: 'БИ-2604'),
  );
  final firstDay = DateTime(2026, 9, 1);

  Lesson lesson({
    required String name,
    String? professor = 'Иванов Иван Иванович',
    String? group,
    int? professorId,
    String room = '211 ауд.',
    String type = 'Практика',
    int hour = 9,
  }) => Lesson(
    name: name,
    day: firstDay,
    dayOfWeek: 'ВТ',
    start: DateTime(2026, 9, 1, hour),
    end: DateTime(2026, 9, 1, hour + 1, 35),
    professor: professor,
    location: '$room НА СХЕМЕ ЛИНГВОБАШНИ',
    lessonType: type,
    group: group,
    professorId: professorId,
  );

  Schedule schedule(List<Lesson> lessons, {ScheduleInfo info = groupInfo}) =>
      Schedule(
        week: 1,
        info: info,
        academicYearStart: 2026,
        periodStart: firstDay,
        periodEnd: DateTime(2026, 9, 6),
        daySchedules: [DaySchedule(day: firstDay, lessons: lessons)],
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('text covers the canonical period and resolves subgroup once', () async {
    final choices = LessonChoiceRepository(
      await SharedPreferences.getInstance(),
    );
    final first = lesson(
      name: 'Иностранный язык (Практика)',
      professor: 'Первый',
      professorId: 1,
      room: '101 ауд.',
    );
    final chosen = lesson(
      name: 'Иностранный язык (Практика)',
      professor: 'Вторая',
      professorId: 2,
      room: '202 ауд.',
    );
    await choices.save(
      info: groupInfo,
      lesson: chosen,
      alternativeId: lessonAlternativeId(chosen),
      scope: LessonChoiceScope.subject,
    );

    final document = ScheduleShareDocument.fromSchedule(
      schedule([first, chosen]),
      title: 'БИ-2604',
      choiceRepository: choices,
      updatedAt: DateTime(2026, 9, 1, 12, 30),
    );
    final text = document.toPlainText();

    expect(document.days, hasLength(6));
    expect(text, contains('Неделя 1 · 01.09.2026–06.09.2026'));
    expect(text, contains('Вторая · 202 ауд.'));
    expect(text, contains('Иностранный язык (Практика)'));
    expect(text, isNot(contains('Первый')));
    expect(text, isNot(contains('101 ауд.')));
    expect(text, isNot(contains('НА СХЕМЕ')));
    expect(text, contains('Воскресенье, 06.09.2026\nНет пар'));
    expect(text, contains('Данные обновлены 01.09.2026 12:30'));
  });

  test('unresolved alternative does not leak another subgroup', () async {
    final choices = LessonChoiceRepository(
      await SharedPreferences.getInstance(),
    );
    final document = ScheduleShareDocument.fromSchedule(
      schedule([
        lesson(name: 'Язык', professor: 'Первый', professorId: 1),
        lesson(name: 'Язык', professor: 'Второй', professorId: 2),
      ]),
      title: 'БИ-2604',
      choiceRepository: choices,
    );

    expect(document.days.first.lessons, hasLength(1));
    expect(document.days.first.lessons.single.unresolvedSubgroup, isTrue);
    expect(document.toPlainText(), contains('Подгруппа не выбрана'));
    expect(document.toPlainText(), isNot(contains('Первый')));
    expect(document.toPlainText(), isNot(contains('Второй')));
  });

  test('professor share keeps simultaneous groups distinct', () async {
    const professorInfo = ScheduleInfo.professor(
      shortProfessorInfo: ShortProfessorInfo(
        professorId: 10,
        professorName: 'Иванов',
      ),
    );
    final choices = LessonChoiceRepository(
      await SharedPreferences.getInstance(),
    );
    final document = ScheduleShareDocument.fromSchedule(
      schedule([
        lesson(name: 'Математика', group: 'БИ-2601'),
        lesson(name: 'Математика', group: 'БИ-2602'),
      ], info: professorInfo),
      title: 'Иванов',
      choiceRepository: choices,
    );

    expect(document.days.first.lessons, hasLength(2));
    expect(document.toPlainText(), contains('БИ-2601'));
    expect(document.toPlainText(), contains('БИ-2602'));
  });

  testWidgets('image encodes the whole period at a bounded size', (
    tester,
  ) async {
    final choices = LessonChoiceRepository(
      await SharedPreferences.getInstance(),
    );
    final document = ScheduleShareDocument.fromSchedule(
      schedule([
        lesson(
          name:
              'Очень длинное название дисциплины с несколькими важными '
              'уточнениями, которое переносится на несколько строк',
        ),
      ]),
      title: 'БИ-2604',
      choiceRepository: choices,
    );
    await tester.runAsync(() async {
      final png = await ScheduleShareImageRenderer().render(document);
      final codec = await ui.instantiateImageCodec(png);
      final image = (await codec.getNextFrame()).image;

      expect(png.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(image.width, greaterThan(500));
      expect(image.height, greaterThan(1000));
      expect(image.height, lessThanOrEqualTo(14000));
      image.dispose();
      codec.dispose();
    });
  });
}
