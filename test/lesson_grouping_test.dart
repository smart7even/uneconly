import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/utils/lesson_utils.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';

void main() {
  Lesson lesson(String name, int professorId) => Lesson(
        name: name,
        day: DateTime(2025, 9, 3),
        dayOfWeek: 'СР',
        start: DateTime(2025, 9, 3, 14, 30),
        end: DateTime(2025, 9, 3, 16),
        professor: 'Преподаватель $professorId',
        location: '$professorId ауд.',
        lessonType: 'Практика',
        group: null,
        professorId: professorId,
      );

  test('parallel rows become one subgroup cluster for a group schedule', () {
    final clusters = clusterParallelLessons(
      [
        lesson('Иностранный язык (Практика)', 1),
        lesson('Иностранный язык (Практика)', 2),
        lesson('Математика (Практика)', 3),
      ],
      combineAlternatives: true,
    );

    expect(clusters, hasLength(2));
    expect(clusters.first.alternatives, hasLength(2));
    expect(clusters.last.alternatives, hasLength(1));
  });

  test('professor schedule keeps concurrent student groups separate', () {
    final clusters = clusterParallelLessons(
      [
        lesson('Иностранный язык (Практика)', 1),
        lesson('Иностранный язык (Практика)', 2),
      ],
      combineAlternatives: false,
    );

    expect(clusters, hasLength(2));
  });

  test('clusters remain chronological when source alternatives are separated',
      () {
    final early = lesson('Иностранный язык (Практика)', 1);
    final late = early.copyWith(
      name: 'История (Практика)',
      start: DateTime(2025, 9, 3, 16, 10),
      end: DateTime(2025, 9, 3, 17, 45),
      professorId: 3,
    );

    final clusters = clusterParallelLessons(
      [late, early, lesson('Иностранный язык (Практика)', 2)],
      combineAlternatives: true,
    );

    expect(clusters.first.lesson.name, startsWith('Иностранный язык'));
    expect(clusters.first.alternatives, hasLength(2));
    expect(clusters.last.lesson.name, startsWith('История'));
  });

  test('old backend map captions are removed from the location', () {
    expect(
      cleanLessonLocation(
        '64 ауд. НА СХЕМЕ ЛИНГВОБАШНИ Грибоедова 30/32 2 лестница',
      ),
      '64 ауд. Грибоедова 30/32 2 лестница',
    );
    expect(
      cleanLessonLocation('3035 ауд. ПОКАЗАТЬ НА СХЕМЕ Грибоедова 30/32'),
      '3035 ауд. Грибоедова 30/32',
    );
    expect(
      cleanLessonLocation('Спортклуб НА СХЕМЕ АПРАКСИН Апраксин 13'),
      'Спортклуб Апраксин 13',
    );
    expect(
      cleanLessonLocation(
        '64 ауд. НА СХЕМЕ ЛИНГВОБАШНИ Грибоедова 30/32',
        removeMapCaption: false,
      ),
      '64 ауд. НА СХЕМЕ ЛИНГВОБАШНИ Грибоедова 30/32',
    );
  });

  test('compacts professor names without losing the surname', () {
    expect(
      compactPersonName('Антонова Ксения Николаевна'),
      'Антонова К. Н.',
    );
    expect(compactPersonName('Кафедра'), 'Кафедра');
  });

  test('normalizes room and staircase wording for the week view', () {
    expect(
      compactLessonLocation(
        '64 ауд. НА СХЕМЕ ЛИНГВОБАШНИ Грибоедова 30/32 2 лестница',
      ),
      'ауд. 64 · Грибоедова 30/32, лестница 2',
    );
    expect(compactLessonLocation('Спортивный зал'), 'Спортивный зал');
  });
}
