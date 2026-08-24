class AppConfig {
  const AppConfig({
    required this.roomMapButtonEnabled,
    required this.roomMapCaptionEnabled,
  });

  const AppConfig.safeDefaults()
      : roomMapButtonEnabled = false,
        roomMapCaptionEnabled = false;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        roomMapButtonEnabled: json['room_map_button_enabled'] is bool
            ? json['room_map_button_enabled'] as bool
            : false,
        roomMapCaptionEnabled: json['room_map_caption_enabled'] is bool
            ? json['room_map_caption_enabled'] as bool
            : false,
      );

  final bool roomMapButtonEnabled;
  final bool roomMapCaptionEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfig &&
          roomMapButtonEnabled == other.roomMapButtonEnabled &&
          roomMapCaptionEnabled == other.roomMapCaptionEnabled;

  @override
  int get hashCode => Object.hash(
        roomMapButtonEnabled,
        roomMapCaptionEnabled,
      );
}
