// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:uneconly/feature/schedule/model/lesson.dart';

class DaySchedule {
  final DateTime day;
  final List<Lesson> lessons;

  DaySchedule({
    required this.day,
    required this.lessons,
  });

  DaySchedule.empty(this.day) : lessons = const <Lesson>[];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'day': day.millisecondsSinceEpoch,
      'lessons': lessons.map((x) => x.toJson()).toList(),
    };
  }

  factory DaySchedule.fromMap(Map<String, dynamic> map) {
    return DaySchedule(
      day: DateTime.fromMillisecondsSinceEpoch(map['day'] as int),
      lessons: List<Lesson>.from(
        (map['lessons'] as List<int>).map<Lesson>(
          (x) => Lesson.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DaySchedule.fromJson(String source) =>
      DaySchedule.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant DaySchedule other) {
    if (identical(this, other)) return true;

    return other.day == day && listEquals(other.lessons, lessons);
  }

  @override
  int get hashCode => day.hashCode ^ lessons.hashCode;

  DaySchedule copyWith({
    DateTime? day,
    List<Lesson>? lessons,
  }) {
    return DaySchedule(
      day: day ?? this.day,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  String toString() => 'DaySchedule(day: $day, lessons: $lessons)';
}
