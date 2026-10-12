import 'package:uneconly/common/logging/telemetry_config.dart';
import 'package:collection/collection.dart';

class AppConfig {
  const AppConfig({
    required this.roomMapButtonEnabled,
    required this.roomMapCaptionEnabled,
    this.scheduleAutoScrollToday = true,
    this.revision = 0,
    this.refreshIntervalSeconds = 300,
    this.payload = const {},
  });

  const AppConfig.safeDefaults()
    : roomMapButtonEnabled = false,
      roomMapCaptionEnabled = false,
      scheduleAutoScrollToday = true,
      revision = 0,
      refreshIntervalSeconds = 300,
      payload = const {'schedule_auto_scroll_today': true};

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final payload = rawPayload is Map
        ? Map<String, dynamic>.from(rawPayload)
        : <String, dynamic>{};
    TelemetryConfig.parse(payload['telemetry']);
    final autoScrollValue =
        json['schedule_auto_scroll_today'] ??
        payload['schedule_auto_scroll_today'];
    final scheduleAutoScrollToday = autoScrollValue is bool
        ? autoScrollValue
        : true;
    payload.putIfAbsent(
      'schedule_auto_scroll_today',
      () => scheduleAutoScrollToday,
    );
    final refreshInterval = json['refresh_interval_seconds'];

    return AppConfig(
      roomMapButtonEnabled: json['room_map_button_enabled'] is bool
          ? json['room_map_button_enabled'] as bool
          : false,
      roomMapCaptionEnabled: json['room_map_caption_enabled'] is bool
          ? json['room_map_caption_enabled'] as bool
          : false,
      scheduleAutoScrollToday: scheduleAutoScrollToday,
      revision: json['revision'] is int ? json['revision'] as int : 0,
      refreshIntervalSeconds:
          refreshInterval is int &&
              refreshInterval >= 60 &&
              refreshInterval <= 3600
          ? refreshInterval
          : 300,
      payload: payload,
    );
  }

  TelemetryConfig get telemetry => TelemetryConfig.parse(payload['telemetry']);

  final bool roomMapButtonEnabled;
  final bool roomMapCaptionEnabled;
  final bool scheduleAutoScrollToday;
  final int revision;
  final int refreshIntervalSeconds;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson({bool includeSafetyFlags = true}) => {
    'version': 2,
    'revision': revision,
    'refresh_interval_seconds': refreshIntervalSeconds,
    'room_map_button_enabled': includeSafetyFlags
        ? roomMapButtonEnabled
        : false,
    'room_map_caption_enabled': includeSafetyFlags
        ? roomMapCaptionEnabled
        : false,
    'schedule_auto_scroll_today': scheduleAutoScrollToday,
    'payload': payload,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfig &&
          roomMapButtonEnabled == other.roomMapButtonEnabled &&
          roomMapCaptionEnabled == other.roomMapCaptionEnabled &&
          scheduleAutoScrollToday == other.scheduleAutoScrollToday &&
          revision == other.revision &&
          refreshIntervalSeconds == other.refreshIntervalSeconds &&
          const DeepCollectionEquality().equals(payload, other.payload);

  @override
  int get hashCode => Object.hash(
    roomMapButtonEnabled,
    roomMapCaptionEnabled,
    scheduleAutoScrollToday,
    revision,
    refreshIntervalSeconds,
    const DeepCollectionEquality().hash(payload),
  );
}
