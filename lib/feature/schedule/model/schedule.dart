import 'package:uneconly/feature/schedule/model/lesson.dart';

class Schedule {
  final List<Lesson> lessons;

  const Schedule({
    required this.lessons,
  });

  const Schedule.empty() : lessons = const <Lesson>[];
}
