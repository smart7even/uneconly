import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

/// Lesson data class
@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required final String name,
    required final DateTime day,
    @JsonKey(name: 'day_of_week', required: true, disallowNullValue: true)
        required final String dayOfWeek,
    required final DateTime start,
    required final DateTime end,
    required final String? professor,
    required final String location,
  }) = _Lesson;

  const Lesson._();

  /// Generate Lesson class from Map<String, Object?>
  factory Lesson.fromJson(Map<String, Object?> json) => _$LessonFromJson(json);
}
