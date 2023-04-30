import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_route_path.freezed.dart';
part 'app_route_path.g.dart';

/// AppRoutePath data class
@freezed
class AppRoutePath with _$AppRoutePath {
  const factory AppRoutePath.select() = SelectAppRoutePath;

  const factory AppRoutePath.schedule({
    required final int groupId,
    required final String groupName,
  }) = ScheduleAppRoutePath;

  const AppRoutePath._();

  /// Generate AppRoutePath class from Map<String, Object?>
  factory AppRoutePath.fromJson(Map<String, Object?> json) =>
      _$AppRoutePathFromJson(json);
}
