import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.spaceGroteskTextTheme(base).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        letterSpacing: 0,
        height: 64 / 57,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        letterSpacing: 0,
        height: 52 / 45,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        letterSpacing: 0,
        height: 44 / 36,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        letterSpacing: 0,
        height: 40 / 32,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        letterSpacing: 0,
        height: 36 / 28,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        letterSpacing: 0,
        height: 32 / 24,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        letterSpacing: 0,
        height: 28 / 22,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        letterSpacing: 0.15,
        height: 24 / 16,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        letterSpacing: 0.1,
        height: 20 / 14,
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        letterSpacing: 0.1,
        height: 20 / 14,
      ),
      labelMedium: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        letterSpacing: 0.5,
        height: 16 / 12,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        letterSpacing: 0.5,
        height: 16 / 11,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        letterSpacing: 0.15,
        height: 24 / 16,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        letterSpacing: 0.25,
        height: 20 / 14,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        letterSpacing: 0.4,
        height: 16 / 12,
      ),
    );
  }

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
      textTheme: _buildTextTheme(base.textTheme),
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
