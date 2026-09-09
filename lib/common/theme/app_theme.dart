import 'package:flutter/material.dart';

enum AppAccent {
  university(
    storageName: 'university',
    label: 'Бирюза',
    lightDisplay: Color(0xFF12868A),
    lightText: Color(0xFF0E6C70),
    lightTint: Color(0xFFE6F1F1),
    dark: Color(0xFF4FC3C7),
  ),
  indigo(
    storageName: 'indigo',
    label: 'Индиго',
    lightDisplay: Color(0xFF3B4EA0),
    lightText: Color(0xFF2F3E80),
    lightTint: Color(0xFFEAECF7),
    dark: Color(0xFF8B9BE8),
  ),
  forest(
    storageName: 'forest',
    label: 'Хвоя',
    lightDisplay: Color(0xFF2F7A45),
    lightText: Color(0xFF256237),
    lightTint: Color(0xFFE7F2EA),
    dark: Color(0xFF6FC98A),
  ),
  plum(
    storageName: 'plum',
    label: 'Слива',
    lightDisplay: Color(0xFF7B3F86),
    lightText: Color(0xFF63326C),
    lightTint: Color(0xFFF2EAF4),
    dark: Color(0xFFC48FCE),
  ),
  raspberry(
    storageName: 'raspberry',
    label: 'Малина',
    lightDisplay: Color(0xFFA62A55),
    lightText: Color(0xFF862044),
    lightTint: Color(0xFFF8E9EE),
    dark: Color(0xFFE884A4),
  ),
  terracotta(
    storageName: 'terracotta',
    label: 'Терракота',
    lightDisplay: Color(0xFFB04A28),
    lightText: Color(0xFF8C3A1F),
    lightTint: Color(0xFFFAEBE4),
    dark: Color(0xFFE89B78),
  ),
  amber(
    storageName: 'amber',
    label: 'Янтарь',
    lightDisplay: Color(0xFF9A6B0F),
    lightText: Color(0xFF7A540B),
    lightTint: Color(0xFFF7EFDC),
    dark: Color(0xFFD9AE55),
  ),
  graphite(
    storageName: 'graphite',
    label: 'Графит',
    lightDisplay: Color(0xFF4A5354),
    lightText: Color(0xFF383F40),
    lightTint: Color(0xFFEDF0F0),
    dark: Color(0xFFA8B2B3),
  );

  const AppAccent({
    required this.storageName,
    required this.label,
    required this.lightDisplay,
    required this.lightText,
    required this.lightTint,
    required this.dark,
  });

  final String storageName;
  final String label;
  final Color lightDisplay;
  final Color lightText;
  final Color lightTint;
  final Color dark;
}

@immutable
class AppThemePreference {
  const AppThemePreference({
    this.mode = ThemeMode.system,
    this.accent = AppAccent.university,
  });

  final ThemeMode mode;
  final AppAccent accent;

  static const university = AppThemePreference();

  String get storageValue => '${mode.name}:${accent.storageName}';

  AppThemePreference copyWith({ThemeMode? mode, AppAccent? accent}) =>
      AppThemePreference(
        mode: mode ?? this.mode,
        accent: accent ?? this.accent,
      );

  static AppThemePreference parse(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    final parts = normalized.split(':');
    if (parts.length == 2) {
      return AppThemePreference(
        mode: _modeFromName(parts.first),
        accent: _accentFromName(parts.last),
      );
    }

    if (const {'system', 'light', 'dark'}.contains(normalized)) {
      return AppThemePreference(mode: _modeFromName(normalized));
    }

    // Builds before 2.0 stored a Material color name in the same preference.
    // Preserve the user's intent while adopting the new independent brightness
    // and accent model.
    return AppThemePreference(accent: _legacyAccent(normalized));
  }

  static ThemeMode _modeFromName(String value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static AppAccent _accentFromName(String value) {
    for (final accent in AppAccent.values) {
      if (accent.storageName == value) return accent;
    }
    return AppAccent.university;
  }

  static AppAccent _legacyAccent(String value) => switch (value) {
    'blue' || 'indigo' || 'cyan' => AppAccent.indigo,
    'green' => AppAccent.forest,
    'purple' => AppAccent.plum,
    'red' || 'pink' => AppAccent.raspberry,
    'orange' || 'brown' => AppAccent.terracotta,
    'yellow' => AppAccent.amber,
    'grey' => AppAccent.graphite,
    'teal' => AppAccent.university,
    _ => AppAccent.university,
  };
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surface,
    required this.nestedSurface,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.accent,
    required this.accentDisplay,
    required this.currentSurface,
    required this.danger,
    required this.success,
    required this.change,
    required this.note,
  });

  factory AppPalette.light(AppAccent accent) => AppPalette(
    surface: const Color(0xFFFFFFFF),
    nestedSurface: const Color(0xFFF4F6F6),
    ink: const Color(0xFF2E3132),
    muted: const Color(0xFF6E7677),
    hairline: const Color(0xFFE3E9E9),
    accent: accent.lightText,
    accentDisplay: accent.lightDisplay,
    currentSurface: accent.lightTint,
    danger: const Color(0xFFB3261E),
    success: const Color(0xFF256237),
    change: const Color(0xFF7B3F86),
    note: const Color(0xFFC3D42D),
  );

  factory AppPalette.dark(AppAccent accent) {
    const surface = Color(0xFF17191A);
    return AppPalette(
      surface: surface,
      nestedSurface: const Color(0xFF222526),
      ink: const Color(0xFFF4F6F6),
      muted: const Color(0xFFA8B2B3),
      hairline: const Color(0xFF343A3B),
      accent: accent.dark,
      accentDisplay: accent.dark,
      currentSurface: Color.alphaBlend(
        accent.dark.withValues(alpha: 0.14),
        surface,
      ),
      danger: const Color(0xFFFF8A80),
      success: const Color(0xFF6FC98A),
      change: const Color(0xFFC48FCE),
      note: const Color(0xFFD9E45E),
    );
  }

  final Color surface;
  final Color nestedSurface;
  final Color ink;
  final Color muted;
  final Color hairline;
  final Color accent;
  final Color accentDisplay;
  final Color currentSurface;
  final Color danger;
  final Color success;
  final Color change;
  final Color note;

  @override
  AppPalette copyWith({
    Color? surface,
    Color? nestedSurface,
    Color? ink,
    Color? muted,
    Color? hairline,
    Color? accent,
    Color? accentDisplay,
    Color? currentSurface,
    Color? danger,
    Color? success,
    Color? change,
    Color? note,
  }) => AppPalette(
    surface: surface ?? this.surface,
    nestedSurface: nestedSurface ?? this.nestedSurface,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    hairline: hairline ?? this.hairline,
    accent: accent ?? this.accent,
    accentDisplay: accentDisplay ?? this.accentDisplay,
    currentSurface: currentSurface ?? this.currentSurface,
    danger: danger ?? this.danger,
    success: success ?? this.success,
    change: change ?? this.change,
    note: note ?? this.note,
  );

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      nestedSurface: Color.lerp(nestedSurface, other.nestedSurface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDisplay: Color.lerp(accentDisplay, other.accentDisplay, t)!,
      currentSurface: Color.lerp(currentSurface, other.currentSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      change: Color.lerp(change, other.change, t)!,
      note: Color.lerp(note, other.note, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      AppPalette.light(AppAccent.university);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light([AppAccent accent = AppAccent.university]) =>
      _build(Brightness.light, AppPalette.light(accent));
  static ThemeData dark([AppAccent accent = AppAccent.university]) =>
      _build(Brightness.dark, AppPalette.dark(accent));

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.accentDisplay,
          brightness: brightness,
          surface: palette.surface,
          error: palette.danger,
        ).copyWith(
          primary: palette.ink,
          onPrimary: palette.surface,
          secondary: palette.accent,
          onSecondary: palette.surface,
          tertiary: palette.note,
          outline: palette.hairline,
          surfaceContainerHighest: palette.nestedSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.surface,
      canvasColor: palette.surface,
      dividerColor: palette.hairline,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: palette.surface,
        foregroundColor: palette.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: palette.ink,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.hairline,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: TextStyle(color: palette.surface),
        actionTextColor: palette.accentDisplay,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.nestedSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.accent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: palette.ink,
          foregroundColor: palette.surface,
          disabledBackgroundColor: palette.hairline,
          disabledForegroundColor: palette.muted,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.accent),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          side: BorderSide(color: palette.hairline),
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.surface
              : palette.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accentDisplay
              : palette.hairline,
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: palette.ink,
        iconColor: palette.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(bodyColor: palette.ink, displayColor: palette.ink),
    );
  }
}

ThemeMode themeModeFromSetting(String value) =>
    AppThemePreference.parse(value).mode;
