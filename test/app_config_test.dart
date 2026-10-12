import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';

void main() {
  test('autoscroll is disabled by default', () {
    expect(const AppConfig.safeDefaults().scheduleAutoScrollToday, isFalse);
    expect(AppConfig.fromJson({}).scheduleAutoScrollToday, isFalse);
  });
  test('app config parses explicit feature flags', () {
    final config = AppConfig.fromJson({
      'version': 1,
      'room_map_button_enabled': true,
      'room_map_caption_enabled': false,
      'revision': 7,
      'refresh_interval_seconds': 120,
      'payload': {
        'schedule_auto_scroll_today': false,
        'banner': {'title': 'Hello'},
      },
    });

    expect(config.roomMapButtonEnabled, isTrue);
    expect(config.roomMapCaptionEnabled, isFalse);
    expect(config.scheduleAutoScrollToday, isFalse);
    expect(config.revision, 7);
    expect(config.refreshIntervalSeconds, 120);
    expect(config.payload['banner'], {'title': 'Hello'});
  });

  test('missing or malformed flags fail closed', () {
    final missing = AppConfig.fromJson({});
    final malformed = AppConfig.fromJson({
      'room_map_button_enabled': 'true',
      'room_map_caption_enabled': 1,
      'schedule_auto_scroll_today': 'true',
      'refresh_interval_seconds': 1,
    });

    expect(missing, const AppConfig.safeDefaults());
    expect(malformed, const AppConfig.safeDefaults());
  });

  test('cache serialization fails safety switches closed', () {
    final config = AppConfig.fromJson({
      'revision': 2,
      'room_map_button_enabled': true,
      'room_map_caption_enabled': true,
      'schedule_auto_scroll_today': false,
      'payload': {'schedule_auto_scroll_today': false},
    });

    final cached = AppConfig.fromJson(config.toJson(includeSafetyFlags: false));

    expect(cached.roomMapButtonEnabled, isFalse);
    expect(cached.roomMapCaptionEnabled, isFalse);
    expect(cached.scheduleAutoScrollToday, isFalse);
  });
}
