import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/theme/app_theme.dart';

void main() {
  test(
    'university accent is the default and brightness remains system-owned',
    () {
      final preference = AppThemePreference.parse(null);

      expect(preference.mode, ThemeMode.system);
      expect(preference.accent, AppAccent.university);
      expect(
        AppPalette.light(preference.accent).accentDisplay,
        const Color(0xFF12868A),
      );
    },
  );

  test('new theme preference round-trips mode and accent', () {
    const preference = AppThemePreference(
      mode: ThemeMode.dark,
      accent: AppAccent.raspberry,
    );

    final restored = AppThemePreference.parse(preference.storageValue);
    expect(restored.mode, preference.mode);
    expect(restored.accent, preference.accent);
  });

  test('legacy color choices migrate to the nearest new accent', () {
    expect(AppThemePreference.parse('blue').accent, AppAccent.indigo);
    expect(AppThemePreference.parse('green').accent, AppAccent.forest);
    expect(AppThemePreference.parse('brown').accent, AppAccent.terracotta);
    expect(AppThemePreference.parse('purple').accent, AppAccent.plum);
    expect(AppThemePreference.parse('unexpected').accent, AppAccent.university);
  });

  test('accent text meets WCAG AA contrast on both app surfaces', () {
    for (final accent in AppAccent.values) {
      final light = AppPalette.light(accent);
      final dark = AppPalette.dark(accent);
      expect(
        _contrast(light.accent, light.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${accent.label} on the light surface',
      );
      expect(
        _contrast(dark.accent, dark.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${accent.label} on the dark surface',
      );
    }
  });
}

double _contrast(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final darker = first.computeLuminance() > second.computeLuminance()
      ? second.computeLuminance()
      : first.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
