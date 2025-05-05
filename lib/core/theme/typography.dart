import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextTheme getTextTheme({bool isDark = false}) {
    // Select text colors based on theme mode
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondary;
    
    return TextTheme(
      // Display styles - Large titles and hero text
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.25,
      ),
      
      // Headline styles - Section headers
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      
      // Title styles - Article titles, dialog titles
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      
      // Body text styles
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      
      // Label styles for components like buttons, inputs
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textPrimary,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 11,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );
  }
}
