import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_entity.freezed.dart';

/// SettingsEntity data class
@freezed
class SettingsEntity with _$SettingsEntity {
  const factory SettingsEntity({
    required final String themeColor,
  }) = _SettingsEntity;

  const SettingsEntity._();
}
