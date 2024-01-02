import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/common/model/short_group_info.dart';

part 'app_route_path.freezed.dart';
part 'app_route_path.g.dart';

/// AppRoutePath data class
@freezed
class AppRoutePath with _$AppRoutePath {
  const factory AppRoutePath.select({
    final ShortGroupInfo? shortGroupInfo,
  }) = SelectAppRoutePath;

  const factory AppRoutePath.schedule({
    required final ShortGroupInfo shortGroupInfo,
  }) = ScheduleAppRoutePath;

  const factory AppRoutePath.loading() = LoadingAppRoutePath;

  const factory AppRoutePath.settings() = SettingsAppRoutePath;

  const AppRoutePath._();

  /// Generate AppRoutePath class from Map<String, Object?>
  factory AppRoutePath.fromJson(Map<String, Object?> json) =>
      _$AppRoutePathFromJson(json);
}
