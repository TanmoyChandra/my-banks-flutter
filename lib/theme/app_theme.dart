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

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF202020),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFAAEF00),
        onPrimaryContainer: Color(0xFF202020),
        secondary: Color(0xFF202020),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFF2F3F5),
        onSecondaryContainer: Color(0xFF202020),
        tertiary: Color(0xFFAAEF00),
        onTertiary: Color(0xFF202020),
        tertiaryContainer: Color(0xFFAAEF00),
        onTertiaryContainer: Color(0xFF202020),
        error: Color(0xFFFF4D4F),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF202020),
        surfaceContainerHighest: Color(0xFFFFFFFF),
        onSurfaceVariant: Color(0xFF7A7A7A),
        outline: Color(0xFFEAEAEA),
        outlineVariant: Color(0xFFEFEFEF),
      ),
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFAAEF00),
        onPrimary: Color(0xFF202020),
        primaryContainer: Color(0xFFAAEF00),
        onPrimaryContainer: Color(0xFF202020),
        secondary: Color(0xFFAAEF00),
        onSecondary: Color(0xFF202020),
        secondaryContainer: Color(0xFF202020),
        onSecondaryContainer: Color(0xFFFFFFFF),
        tertiary: Color(0xFFAAEF00),
        onTertiary: Color(0xFF202020),
        tertiaryContainer: Color(0xFF202020),
        onTertiaryContainer: Color(0xFFFFFFFF),
        error: Color(0xFFFF5A5F),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF1A1A1A),
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerHighest: Color(0xFF202020),
        onSurfaceVariant: Color(0xFFA1A1A1),
        outline: Color(0xFF2A2A2A),
        outlineVariant: Color(0xFF303030),
      ),
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
