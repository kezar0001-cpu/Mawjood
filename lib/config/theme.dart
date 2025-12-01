import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF00897B);
  static const Color background = Colors.white;
  static const Color textDark = Color(0xFF333333);

  static ThemeData get lightTheme {
    // 1. Define a base TextTheme with explicitly non-null styles
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
      bodyLarge: TextStyle(fontSize: 16, color: textDark),
      bodyMedium: TextStyle(fontSize: 14, color: textDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark),
    );

    // 2. Safely apply Google Fonts
    TextTheme themeText = baseTextTheme;
    try {
      themeText = GoogleFonts.cairoTextTheme(baseTextTheme);
    } catch (_) {
      // If font fails, stick to baseTextTheme
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      textTheme: themeText,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // Explicitly define IconTheme to prevent null crashes
      iconTheme: const IconThemeData(color: textDark, size: 24),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: themeText.labelLarge, // Safe usage
        ),
      ),
    );
  }
}