import 'package:freezed_annotation/freezed_annotation.dart';

part 'faculty.freezed.dart';
part 'faculty.g.dart';

/// Faculty data class
@freezed
class Faculty with _$Faculty {
  const factory Faculty({
    required final int id,
    required final String name,
  }) = _Faculty;

  const Faculty._();

  /// Generate Faculty class from Map<String, Object?>
  factory Faculty.fromJson(Map<String, Object?> json) =>
      _$FacultyFromJson(json);
}
