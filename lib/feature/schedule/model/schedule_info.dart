import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/common/model/short_group_info.dart';
import 'package:uneconly/common/model/short_professor_info.dart';

part 'schedule_info.freezed.dart';
part 'schedule_info.g.dart';

/// ScheduleInfo data class
@freezed
abstract class ScheduleInfo with _$ScheduleInfo {
  const factory ScheduleInfo.group({
    required final ShortGroupInfo shortGroupInfo,
  }) = _GroupScheduleInfo;

  const factory ScheduleInfo.professor({
    required final ShortProfessorInfo shortProfessorInfo,
  }) = _ProfessorScheduleInfo;

  const ScheduleInfo._();

  /// Generate ScheduleInfo class from Map<String, Object?>
  factory ScheduleInfo.fromJson(Map<String, Object?> json) =>
      _$ScheduleInfoFromJson(json);

  bool isComplete() {
    return maybeMap(
      group: (group) => group.shortGroupInfo.isComplete(),
      professor: (professor) => professor.shortProfessorInfo.isComplete(),
      orElse: () => false,
    );
  }

  String? get title => maybeMap(
        group: (group) => group.shortGroupInfo.groupName,
        professor: (professor) => professor.shortProfessorInfo.professorName,
        orElse: () => null,
      );
}
