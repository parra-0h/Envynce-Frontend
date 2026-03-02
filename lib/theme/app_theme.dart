import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary (Corporate Blue)
  static const Color primaryColor = Color(0xFF0052CC);
  static const Color primaryLighter = Color(0xFF2684FF);
  static const Color primaryDarker = Color(0xFF0047B3);

  // Secondary (Dark Slate / Neutral)
  static const Color secondaryColor = Color(0xFF172B4D);
  static const Color secondaryLight = Color(0xFF6B778C);

  // Backgrounds
  static const Color backgroundColor = Color(0xFFF4F5F7);
  static const Color surfaceColor = Colors.white;
  static const Color surfaceSecondary = Color(0xFFFAFBFC);

  // Semantic Colors
  static const Color successColor = Color(0xFF36B37E);
  static const Color errorColor = Color(0xFFFF5630);
  static const Color warningColor = Color(0xFFFFAB00);
  static const Color infoColor = Color(0xFF00B8D9);

  // Text Colors
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF505F79);
  static const Color textTertiary = Color(0xFF97A0AF);

  // Borders & Dividers
  static const Color borderColor = Color(0xFFDFE1E6);
  static const Color dividerColor = Color(0xFFEBECF0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: backgroundColor,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor),
        ),
      ),
      dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hoverColor: surfaceSecondary,
        hintStyle: const TextStyle(color: textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          side: const BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
