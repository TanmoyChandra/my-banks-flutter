import 'package:flutter/material.dart';
class AppTheme {
  static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
    return _buildTheme(Brightness.light, dynamicColorScheme);
  }

  static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
    return _buildTheme(Brightness.dark, dynamicColorScheme);
  }

  static ThemeData _buildTheme(Brightness brightness, ColorScheme? colorScheme) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        color: base.colorScheme.surfaceContainerHighest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        tileColor: base.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: base.colorScheme.surfaceContainerHighest,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: base.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.colorScheme.primaryContainer,
          foregroundColor: base.colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
