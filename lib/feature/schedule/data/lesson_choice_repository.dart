import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneconly/feature/schedule/model/lesson.dart';
import 'package:uneconly/feature/schedule/model/schedule_info.dart';

enum LessonChoiceScope { subject, weekday, date }

class LessonChoiceResolution {
  const LessonChoiceResolution({
    required this.alternativeId,
    required this.scope,
  });

  final String alternativeId;
  final LessonChoiceScope scope;
}

/// Stores a student's subgroup choice locally. A date exception wins over a
/// weekday rule, and a weekday rule wins over the usual subject choice.
class LessonChoiceRepository {
  LessonChoiceRepository(this._preferences);

  static const _prefix = 'lessonChoice.v1';

  final SharedPreferences _preferences;

  String scheduleScope(ScheduleInfo info) => info.map(
        group: (group) => 'group:${group.shortGroupInfo.groupId}',
        professor: (professor) =>
            'professor:${professor.shortProfessorInfo.professorId}',
      );

  LessonChoiceResolution? resolve({
    required ScheduleInfo info,
    required Lesson lesson,
  }) {
    final subject = lessonSubjectKey(lesson.name);
    final schedule = scheduleScope(info);
    final candidates = <(LessonChoiceScope, String)>[
      (
        LessonChoiceScope.date,
        _key(schedule, subject, LessonChoiceScope.date, _dateToken(lesson.day)),
      ),
      (
        LessonChoiceScope.weekday,
        _key(
          schedule,
          subject,
          LessonChoiceScope.weekday,
          lesson.day.weekday.toString(),
        ),
      ),
      (
        LessonChoiceScope.subject,
        _key(schedule, subject, LessonChoiceScope.subject, 'all'),
      ),
    ];

    for (final candidate in candidates) {
      final value = _preferences.getString(candidate.$2);
      if (value != null) {
        return LessonChoiceResolution(
          alternativeId: value,
          scope: candidate.$1,
        );
      }
    }
    return null;
  }

  Future<void> save({
    required ScheduleInfo info,
    required Lesson lesson,
    required String alternativeId,
    required LessonChoiceScope scope,
  }) async {
    final subject = lessonSubjectKey(lesson.name);
    final schedule = scheduleScope(info);

    // A newly saved broader rule should be visible immediately for the lesson
    // from which it was created, rather than being masked by an older override.
    if (scope != LessonChoiceScope.date) {
      await _preferences.remove(
        _key(schedule, subject, LessonChoiceScope.date, _dateToken(lesson.day)),
      );
    }
    if (scope == LessonChoiceScope.subject) {
      await _preferences.remove(
        _key(
          schedule,
          subject,
          LessonChoiceScope.weekday,
          lesson.day.weekday.toString(),
        ),
      );
    }

    final token = switch (scope) {
      LessonChoiceScope.subject => 'all',
      LessonChoiceScope.weekday => lesson.day.weekday.toString(),
      LessonChoiceScope.date => _dateToken(lesson.day),
    };
    await _preferences.setString(
      _key(schedule, subject, scope, token),
      alternativeId,
    );
  }

  String _key(
    String schedule,
    String subject,
    LessonChoiceScope scope,
    String token,
  ) {
    final encodedSchedule = base64Url.encode(utf8.encode(schedule));
    final encodedSubject = base64Url.encode(utf8.encode(subject));
    return '$_prefix.$encodedSchedule.$encodedSubject.${scope.name}.$token';
  }

  String _dateToken(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String lessonSubjectKey(String name) =>
    name.replaceFirst(RegExp(r'\s*\([^()]+\)\s*$'), '').trim().toLowerCase();

String lessonDisplayName(Lesson lesson) {
  final lessonType = lesson.lessonType;
  if (lessonType == null || lessonType.isEmpty) {
    return lesson.name;
  }
  return lesson.name
      .replaceFirst(RegExp('\\s*\\(${RegExp.escape(lessonType)}\\)\\s*\$'), '')
      .trim();
}

String lessonAlternativeId(Lesson lesson) {
  final professorId = lesson.professorId;
  if (professorId != null) {
    return 'professor:$professorId';
  }
  return 'name:${lesson.professor?.trim().toLowerCase() ?? ''}';
}
