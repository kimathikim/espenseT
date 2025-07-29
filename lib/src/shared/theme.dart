import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const primaryStart = Color(0xFF667eea);
  static const primaryEnd = Color(0xFF764ba2);
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  // Secondary gradient
  static const secondaryStart = Color(0xFF11998e);
  static const secondaryEnd = Color(0xFF38ef7d);
  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );

  // Accent colors
  static const accent = Color(0xFF6C63FF);
  static const success = Color(0xFF00D4AA);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF6B6B);

  // Text colors
  static const whiteText = Colors.white;
  static const whiteText70 = Color(0xB3FFFFFF); // 70% opacity white
  static const whiteText50 = Color(0x80FFFFFF); // 50% opacity white
  static const whiteText30 = Color(0x4DFFFFFF); // 30% opacity white
  static const whiteText10 = Color(0x1AFFFFFF); // 10% opacity white
  static const darkText = Color(0xFF2D3748);
  static const greyText = Color(0xFF718096);

  // Background colors
  static const cardBackground = Color(0xFFF7FAFC);
  static const surfaceColor = Colors.white;

  // Additional colors for categories and UI
  static const glassBackground = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const accentRed = Color(0xFFFF6B6B);

  // Chart colors for categories
  static const List<Color> chartColors = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFF11998e),
    Color(0xFF38ef7d),
    Color(0xFF6C63FF),
    Color(0xFF00D4AA),
    Color(0xFFFFB800),
    Color(0xFFFF6B6B),
    Color(0xFF9C88FF),
    Color(0xFF4ECDC4),
  ];
}

class AppTheme {
  static const Color primaryColor = AppColors.primaryStart;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.whiteText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.whiteText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static Widget buildGlassmorphicCard({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  static Widget buildGradientBackground({required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: child,
    );
  }
}
