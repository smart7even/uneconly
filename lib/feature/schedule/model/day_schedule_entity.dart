// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:uneconly/feature/schedule/model/day_schedule.dart';

class DayScheduleEntity {
  final DaySchedule daySchedule;
  final Map<String, dynamic>? news;

  DayScheduleEntity({
    required this.daySchedule,
    required this.news,
  });

  DayScheduleEntity copyWith({
    DaySchedule? daySchedule,
    Map<String, dynamic>? news,
  }) {
    return DayScheduleEntity(
      daySchedule: daySchedule ?? this.daySchedule,
      news: news ?? this.news,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'daySchedule': daySchedule.toMap(),
      'news': news,
    };
  }

  factory DayScheduleEntity.fromMap(Map<String, dynamic> map) {
    return DayScheduleEntity(
      daySchedule:
          DaySchedule.fromMap(map['daySchedule'] as Map<String, dynamic>),
      news: map['news'] != null
          ? Map<String, dynamic>.from(map['news'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DayScheduleEntity.fromJson(String source) =>
      DayScheduleEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DayScheduleEntity(daySchedule: $daySchedule, news: $news)';

  @override
  bool operator ==(covariant DayScheduleEntity other) {
    if (identical(this, other)) return true;

    return other.daySchedule == daySchedule && mapEquals(other.news, news);
  }

  @override
  int get hashCode => daySchedule.hashCode ^ news.hashCode;
}
