import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surface,
    required this.nestedSurface,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.accent,
    required this.currentSurface,
    required this.danger,
    required this.success,
  });

  static const light = AppPalette(
    surface: Color(0xFFFAF9F6),
    nestedSurface: Color(0xFFF2EFE8),
    ink: Color(0xFF171613),
    muted: Color(0xFF5F5B54),
    hairline: Color(0xFFE2DDD2),
    accent: Color(0xFF7C4A22),
    currentSurface: Color(0xFFF5EBE0),
    danger: Color(0xFF8C2F2A),
    success: Color(0xFF3F6B4E),
  );

  static const dark = AppPalette(
    surface: Color(0xFF121110),
    nestedSurface: Color(0xFF1B1A17),
    ink: Color(0xFFF2F0EA),
    muted: Color(0xFFA8A39A),
    hairline: Color(0xFF34312C),
    accent: Color(0xFFC98A50),
    currentSurface: Color(0xFF2B2119),
    danger: Color(0xFFD17B72),
    success: Color(0xFF77A887),
  );

  final Color surface;
  final Color nestedSurface;
  final Color ink;
  final Color muted;
  final Color hairline;
  final Color accent;
  final Color currentSurface;
  final Color danger;
  final Color success;

  @override
  AppPalette copyWith({
    Color? surface,
    Color? nestedSurface,
    Color? ink,
    Color? muted,
    Color? hairline,
    Color? accent,
    Color? currentSurface,
    Color? danger,
    Color? success,
  }) =>
      AppPalette(
        surface: surface ?? this.surface,
        nestedSurface: nestedSurface ?? this.nestedSurface,
        ink: ink ?? this.ink,
        muted: muted ?? this.muted,
        hairline: hairline ?? this.hairline,
        accent: accent ?? this.accent,
        currentSurface: currentSurface ?? this.currentSurface,
        danger: danger ?? this.danger,
        success: success ?? this.success,
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
      currentSurface: Color.lerp(currentSurface, other.currentSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppPalette.light);
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      surface: palette.surface,
      error: palette.danger,
    ).copyWith(
      primary: palette.ink,
      onPrimary: palette.surface,
      secondary: palette.accent,
      onSecondary: palette.surface,
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
        actionTextColor: brightness == Brightness.light
            ? const Color(0xFFE7B98E)
            : palette.accent,
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
              ? palette.success
              : palette.hairline,
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: palette.ink,
        iconColor: palette.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: palette.ink,
            displayColor: palette.ink,
          ),
    );
  }
}

ThemeMode themeModeFromSetting(String value) => switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
