import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // 1. Define the base TextTheme with explicitly defined styles for ALL standard Material types.
    // This ensures that even if GoogleFonts fails, we have a fallback.
    const baseTextTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.darkText),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.darkText),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.darkText),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.darkText),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.darkText),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.darkText),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.darkText),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkText),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkText),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.darkText),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.darkText),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.darkText),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkText),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkText),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkText),
    );

    // 2. Apply the Cairo font family safely.
    // We create a copy of the base theme with the font applied.
    // This ensures that we start with a fully populated theme.
    TextTheme safeTextTheme = baseTextTheme;
    try {
      // GoogleFonts.cairoTextTheme returns a NEW TextTheme.
      // We must ensure it doesn't have nulls where we expect values.
      final googleTheme = GoogleFonts.cairoTextTheme(baseTextTheme);
      
      // Manually copy the non-null values from googleTheme back to baseTextTheme
      // This is safer than just assigning it.
      safeTextTheme = baseTextTheme.copyWith(
        displayLarge: googleTheme.displayLarge,
        displayMedium: googleTheme.displayMedium,
        displaySmall: googleTheme.displaySmall,
        headlineLarge: googleTheme.headlineLarge,
        headlineMedium: googleTheme.headlineMedium,
        headlineSmall: googleTheme.headlineSmall,
        titleLarge: googleTheme.titleLarge,
        titleMedium: googleTheme.titleMedium,
        titleSmall: googleTheme.titleSmall,
        bodyLarge: googleTheme.bodyLarge,
        bodyMedium: googleTheme.bodyMedium,
        bodySmall: googleTheme.bodySmall,
        labelLarge: googleTheme.labelLarge,
        labelMedium: googleTheme.labelMedium,
        labelSmall: googleTheme.labelSmall,
      );
    } catch (e) {
      debugPrint('⚠️ [THEME] GoogleFonts failed to load: $e. Using default font.');
      // safeTextTheme remains baseTextTheme (Arial fallback implicitly via style)
    }

    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accentGold,
        error: AppColors.error,
        background: Colors.white,
        surface: AppColors.neutral,
      ),
      textTheme: safeTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: (safeTextTheme.labelLarge ?? baseTextTheme.labelLarge)?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
