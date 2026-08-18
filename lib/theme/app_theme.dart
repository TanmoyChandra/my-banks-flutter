import 'package:flutter/material.dart';
class AppTheme {
  static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
    return _buildTheme(Brightness.light, dynamicColorScheme);
  }

  static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
    return _buildTheme(Brightness.dark, dynamicColorScheme);
  }

  static ThemeData _buildTheme(Brightness brightness, ColorScheme? colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // Minimal customizations to ensure correct colors, but relying heavily on Material 3 defaults.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
