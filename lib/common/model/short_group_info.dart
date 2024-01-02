import 'package:freezed_annotation/freezed_annotation.dart';

part 'short_group_info.freezed.dart';
part 'short_group_info.g.dart';

/// ShortGroupInfo data class
@freezed
class ShortGroupInfo with _$ShortGroupInfo {
  const factory ShortGroupInfo({
    required final int groupId,
    required final String? groupName,
  }) = _ShortGroupInfo;

  const ShortGroupInfo._();

  /// Generate ShortGroupInfo class from Map<String, Object?>
  factory ShortGroupInfo.fromJson(Map<String, Object?> json) =>
      _$ShortGroupInfoFromJson(json);
}
