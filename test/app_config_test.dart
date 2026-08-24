import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';

void main() {
  test('app config parses explicit feature flags', () {
    final config = AppConfig.fromJson({
      'version': 1,
      'room_map_button_enabled': true,
      'room_map_caption_enabled': false,
    });

    expect(config.roomMapButtonEnabled, isTrue);
    expect(config.roomMapCaptionEnabled, isFalse);
  });

  test('missing or malformed flags fail closed', () {
    final missing = AppConfig.fromJson({});
    final malformed = AppConfig.fromJson({
      'room_map_button_enabled': 'true',
      'room_map_caption_enabled': 1,
    });

    expect(missing, const AppConfig.safeDefaults());
    expect(malformed, const AppConfig.safeDefaults());
  });
}
