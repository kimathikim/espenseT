import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryGradientStart = Color(0xFFA060FA);
  static const Color primaryGradientEnd = Color(0xFF6A30D8);
  static const Color accentBlue = Color(0xFF00B2FF);
  static const Color accentRed = Color(0xFFFF3D71);
  static const Color iconBlue = Color(0xFF5B67CA);
  static const Color iconRed = Color(0xFFFD5D5D);
  static const Color iconOrange = Color(0xFFFFAC3A);
  static const Color iconPurple = Color(0xFF8A4DFF);
  static const Color addButton = Color(0xFF00C6AD);
  static const Color primaryText = Color(0xFF1C1C1E);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color mainBackground = Color(0xFFF2F2F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryGradientEnd,
      scaffoldBackgroundColor: AppColors.mainBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGradientEnd,
        secondary: AppColors.accentBlue,
        error: AppColors.accentRed,
        background: AppColors.mainBackground,
        surface: AppColors.cardBackground,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.primaryText),
          bodyMedium: TextStyle(color: AppColors.secondaryText),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryGradientEnd,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.whiteText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.whiteText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.addButton,
      ),
      useMaterial3: true,
    );
  }
}
