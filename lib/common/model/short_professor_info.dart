import 'package:freezed_annotation/freezed_annotation.dart';

part 'short_professor_info.freezed.dart';
part 'short_professor_info.g.dart';

/// ShortProfessorInfo data class
@freezed
class ShortProfessorInfo with _$ShortProfessorInfo {
  const factory ShortProfessorInfo({
    required final int professorId,
    required final String? professorName,
  }) = _ShortProfessorInfo;

  const ShortProfessorInfo._();

  /// Generate ShortProfessorInfo class from Map<String, Object?>
  factory ShortProfessorInfo.fromJson(Map<String, Object?> json) =>
      _$ShortProfessorInfoFromJson(json);

  bool isComplete() {
    return professorName != null;
  }
}
