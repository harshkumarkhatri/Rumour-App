import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.limeAccent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.limeAccent,
        secondary: AppColors.limeAccent,
        surface: AppColors.cardColor,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
            ),
            titleLarge: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            bodyMedium: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.limeAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.limeAccent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.limeAccent,
        secondary: AppColors.limeAccent,
        surface: AppColors.cardLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
            ),
            titleLarge: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 16,
            ),
            bodyMedium: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 14,
            ),
            labelLarge: const TextStyle(
              color: AppColors.buttonTextLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.limeAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }

  static BoxDecoration get glowButtonDecoration => BoxDecoration(
    color: AppColors.limeAccent,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.cardBorder,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.cardBorder, width: 1),
  );
}
