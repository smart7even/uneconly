import 'package:uneconly/feature/schedule/model/lesson.dart';

class DaySchedule {
  final DateTime day;
  final List<Lesson> lessons;

  DaySchedule({
    required this.day,
    required this.lessons,
  });

  DaySchedule.empty(this.day) : lessons = const <Lesson>[];
}
