// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Lesson _$$_LessonFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['day_of_week'],
    disallowNullValues: const ['day_of_week'],
  );
  return _$_Lesson(
    name: json['name'] as String,
    day: DateTime.parse(json['day'] as String),
    dayOfWeek: json['day_of_week'] as String,
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
    professor: json['professor'] as String,
    location: json['location'] as String,
  );
}

Map<String, dynamic> _$$_LessonToJson(_$_Lesson instance) => <String, dynamic>{
      'name': instance.name,
      'day': instance.day.toIso8601String(),
      'day_of_week': instance.dayOfWeek,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'professor': instance.professor,
      'location': instance.location,
    };
