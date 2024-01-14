class ScheduleRule {
  final int id;
  final int groupId;
  final String lesson;
  final String? lessonType;
  final String professor;

  ScheduleRule({
    required this.id,
    required this.groupId,
    required this.lesson,
    required this.lessonType,
    required this.professor,
  });
}
