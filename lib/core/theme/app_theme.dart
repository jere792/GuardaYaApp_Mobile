import 'package:flutter/material.dart';
import 'package:guardaya_app/core/theme/app_colors.dart';

class AppTheme {
  static final Color _surfaceLight = AppColors.surface;

  // Dark mode: fondo azulado para home/módulos (login usa AppColors.darkBg)
  static final Color _bgDark = const Color(0xFF1A1A2E);
  static final Color _surfaceDark = const Color(0xFF2E2E2E);
  static final Color _appbarDark = const Color(0xFF15152A);

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    surface: _surfaceDark,
    onSurface: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
  );

  static ThemeData _baseTheme({
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkScheme : _lightScheme;
    final surfaceColor = isDark ? _surfaceDark : _surfaceLight;
    final bgColor = isDark ? _bgDark : _surfaceLight;
    final appbarColor = isDark ? _appbarDark : _surfaceLight;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: appbarColor,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 4 : 2,
        color: surfaceColor,
        shadowColor: isDark ? Colors.black26 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData lightTheme() {
    return _baseTheme(brightness: Brightness.light);
  }

  static ThemeData darkTheme() {
    return _baseTheme(brightness: Brightness.dark);
  }
}
