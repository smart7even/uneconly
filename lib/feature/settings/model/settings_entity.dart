import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uneconly/feature/settings/model/calendar_settings_entity.dart';

part 'settings_entity.freezed.dart';

/// SettingsEntity data class
@freezed
class SettingsEntity with _$SettingsEntity {
  const factory SettingsEntity({
    required final String themeColor,
    required final CalendarSettingsEntity calendarSettings,
  }) = _SettingsEntity;

  const SettingsEntity._();
}
