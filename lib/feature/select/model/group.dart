import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

/// Group data class
@freezed
class Group with _$Group {
  const factory Group({
    @JsonKey(name: 'faculty_id', required: true, disallowNullValue: true)
        required final int facultyId,
    required final String name,
    required final int id,
    required final int course,
  }) = _Group;

  const Group._();

  /// Generate Group class from Map<String, Object?>
  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}
