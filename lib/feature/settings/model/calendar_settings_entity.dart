import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_settings_entity.freezed.dart';

@freezed
class CalendarSettingsEntity with _$CalendarSettingsEntity {
  const CalendarSettingsEntity._();

  const factory CalendarSettingsEntity({
    required bool isCalendarSyncingEnabled,
  }) = _CalendarSettingsEntity;
}
