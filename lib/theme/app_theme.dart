// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor =
      Color.fromARGB(255, 175, 20, 12); // Dark red
  static const Color secondaryColor = Color(0xFFF0BE28); // Gold/yellow
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color.fromARGB(255, 247, 247, 247);
  static const Color backgroundColor =
      Color.fromARGB(255, 245, 248, 255); // Green background

  // Custom colors
  static const Color accentColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color infoColor = Color(0xFF2196F3); // Blue
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color customPurple = Color(0xFF9C27B0); // Purple
  static const Color customTeal = Color(0xFF009688); // Teal
  static const Color whiteColor = Colors.white;
  static const Color grayColor = Color.fromARGB(255, 46, 46, 46);
  static const Color redTextColor = Color(0xFFD32F2F); // Red for light theme
  static const Color redTextColorDark = Color(0xFFEF5350); // Red for dark theme

  // Helper method to get custom colors
  static Map<String, Color> get customColors => {
        'accent': accentColor,
        'warning': warningColor,
        'info': infoColor,
        'success': successColor,
        'purple': customPurple,
        'teal': customTeal,
        'white': whiteColor,
        'gray': grayColor,
        'redText': redTextColor,
        'redTextDark': redTextColorDark,
      };

  // Helper method to get a custom color by name
  static Color? getCustomColor(final String colorName) {
    return customColors[colorName.toLowerCase()];
  }

  // Helper method to get red text color based on theme
  static Color getRedTextColor(final BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? redTextColorDark
        : redTextColor;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: const Color(0xFFF0BE28),
        surface: const Color.fromARGB(255, 246, 251, 255),
        error: errorColor,
        onBackground: Colors.white,
        // Custom colors can be added as extensions
      ).copyWith(
        // You can add custom colors using copyWith
        tertiary: whiteColor,
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        surfaceContainerHighest: const Color(0xFF2D2D2D),
        onBackground: const Color(0xFF2D2D2D),
        onSurface: Colors.white,
        onSurfaceVariant: Colors.grey[300]!,
        outline: Colors.grey[600]!,
        outlineVariant: Colors.grey[700]!,
        error: errorColor,
      ).copyWith(
        // Custom colors for dark theme
        tertiary: grayColor,
      ),
      textTheme:
          GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.roboto(color: Colors.white),
        bodyMedium: GoogleFonts.roboto(color: Colors.grey[300]),
        bodySmall: GoogleFonts.roboto(color: Colors.grey[400]),
        titleLarge: GoogleFonts.roboto(color: Colors.white),
        titleMedium: GoogleFonts.roboto(color: Colors.white),
        titleSmall: GoogleFonts.roboto(color: Colors.grey[300]),
        labelLarge: GoogleFonts.roboto(color: Colors.grey[300]),
        labelMedium: GoogleFonts.roboto(color: Colors.grey[400]),
        labelSmall: GoogleFonts.roboto(color: Colors.grey[500]),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: TextStyle(color: Colors.grey[300]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
      ),
    );
  }
}
