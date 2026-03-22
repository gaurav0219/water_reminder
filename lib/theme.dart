import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Stitch Redesign Colors (Standardized across Stitch HTMLs)
  static const Color primaryBlue = Color(0xFF25AFF4);
  static const Color backgroundLight = Color(0xFFF0F4F8); // From Dashboard
  static const Color backgroundDark = Color(0xFF05070A); // From Dashboard
  
  // Custom Glass properties based on CSS
  static const Color glassBackgroundLight = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)
  static const Color glassBorderLight = Color(0x4DFFFFFF); // rgba(255, 255, 255, 0.3)
  
  static const Color glassBackgroundDark = Color(0x0825AFF4); // rgba(37, 175, 244, 0.03)
  static const Color glassBorderDark = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
  
  // Specific Beverage Colors from Stitch CSS (Beverage Selection Screen)
  static const Color waterColor = Color(0xFF38BDF8);
  static const Color coffeeColor = Color(0xFFF97316); // orange-500
  static const Color teaColor = Color(0xFF22C55E); // green-500
  static const Color juiceColor = Color(0xFFEAB308); // yellow-500
  static const Color sodaColor = Color(0xFFEF4444); // red-500

  // Text colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // slate-900
  static const Color textSecondaryLight = Color(0xFF475569); // slate-600
  
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // slate-100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // slate-400

  // Fallback properties for older screens
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color glassBorder = glassBorderLight;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: backgroundDark, 
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(color: textPrimaryDark, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.spaceGrotesk(color: textPrimaryDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.spaceGrotesk(color: textPrimaryDark, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.spaceGrotesk(color: textPrimaryDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.spaceGrotesk(color: textPrimaryDark),
        bodyMedium: GoogleFonts.spaceGrotesk(color: textSecondaryDark),
        bodySmall: GoogleFonts.spaceGrotesk(color: textSecondaryDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryBlue),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textPrimaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: glassBackgroundDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Match rounded-2xl roughly (approx 16-24)
          side: const BorderSide(color: glassBorderDark, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.spaceGrotesk(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.spaceGrotesk(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.spaceGrotesk(color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.spaceGrotesk(color: const Color(0xFF0F172A)),
        bodyMedium: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B)),
        bodySmall: GoogleFonts.spaceGrotesk(color: const Color(0xFF64748B)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryBlue),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: const Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: glassBackgroundLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorderLight, width: 1),
        ),
      ),
    );
  }
}

