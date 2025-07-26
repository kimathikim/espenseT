import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppColors {
  // Existing colors
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

  // Glassmorphic colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);
  static const Color darkGlassBackground = Color(0x1A000000);
  static const Color darkGlassBorder = Color(0x33000000);
  
  // Chart colors for spending categories
  static const List<Color> chartColors = [
    Color(0xFFA060FA), // Primary purple
    Color(0xFF00B2FF), // Accent blue
    Color(0xFFFF3D71), // Accent red
    Color(0xFF00C6AD), // Add button green
    Color(0xFFFFAC3A), // Icon orange
    Color(0xFF8A4DFF), // Icon purple
    Color(0xFF5B67CA), // Icon blue
    Color(0xFFFD5D5D), // Icon red
    Color(0xFF34D399), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
  ];

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassBackground, glassOverlay],
  );

  static const LinearGradient chartBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x05FFFFFF), Color(0x02000000)],
  );
}

class GlassmorphicStyles {
  static BoxDecoration get glassmorphicCard => BoxDecoration(
    gradient: AppColors.glassGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, -8),
      ),
    ],
  );

  static BoxDecoration get glassmorphicChartContainer => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x15FFFFFF),
        Color(0x08FFFFFF),
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 25,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.15),
        blurRadius: 15,
        offset: const Offset(0, -5),
      ),
    ],
  );

  static BoxDecoration get glassmorphicLegendItem => BoxDecoration(
    color: AppColors.glassBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static Widget createBlurredBackground({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: child,
      ),
    );
  }
}

class ChartTheme {
  static const double defaultRadius = 60.0;
  static const double selectedRadius = 70.0;
  static const double centerSpaceRadius = 40.0;
  
  static const TextStyle legendTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static const TextStyle chartLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteText,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 2,
        color: Colors.black26,
      ),
    ],
  );

  static const TextStyle centerTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static const TextStyle centerSubtextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );
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
          displayLarge: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: AppColors.primaryText),
          bodyMedium: TextStyle(color: AppColors.secondaryText),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
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
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.addButton,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.whiteText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return null; // Use transparent to show gradient background
            },
          ),
        ),
      ),
      useMaterial3: true,
    );
  }

  // Custom widget builders for glassmorphic components
  static Widget buildGlassmorphicCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: GlassmorphicStyles.glassmorphicCard,
      child: GlassmorphicStyles.createBlurredBackground(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  static Widget buildGlassmorphicChartContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: GlassmorphicStyles.glassmorphicChartContainer,
      child: GlassmorphicStyles.createBlurredBackground(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  static Widget buildChartLegendItem({
    required Color color,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: GlassmorphicStyles.glassmorphicLegendItem,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: ChartTheme.legendTextStyle,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: ChartTheme.legendTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGradientEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
