import 'package:uneconly/feature/schedule/model/lesson.dart';

List<List<Lesson>> groupLessonsByTime(List<Lesson> lessons) {
  final groupedLessons = <List<Lesson>>[];

  for (final lesson in lessons) {
    final index = groupedLessons.indexWhere(
      (groupedLesson) => groupedLesson.first.start == lesson.start,
    );

    if (index == -1) {
      groupedLessons.add([lesson]);
    } else {
      groupedLessons[index].add(lesson);
    }
  }

  return groupedLessons;
}
