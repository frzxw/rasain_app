import 'package:flutter/material.dart';

class AppColors {
  // Main colors (Light Mode)
  static const Color primary = Color(0xFFDD4A48);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE0E0E0);
  
  // Text colors (Light Mode)
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF757575);
  
  // Accent colors
  static const Color highlight = Color(0xFFFFD93D);
  static const Color success = Color(0xFF55A630);
  static const Color error = Color(0xFFFF6B6B);

  // Additional utility colors (Light Mode)
  static const Color cardBackground = Color(0xFFFCFCFC);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);
  static const Color iconColor = Color(0xFF1E1E1E);
  static const Color disabledColor = Color(0xFFE0E0E0);

  // Dark Mode Colors
  static const Color primaryDark = Color(0xFFFF6B6B); // Brighter red for better visibility in dark mode
  static const Color onPrimaryDark = Color(0xFF1A1A1A);
  static const Color backgroundDark = Color(0xFF121212); // Deep dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color borderDark = Color(0xFF2C2C2C); // Subtle dark borders
  
  // Text colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // Light text for dark background
  static const Color textSecondaryDark = Color(0xFFB3B3B3); // Subtle gray text
  
  // Additional utility colors (Dark Mode)
  static const Color cardBackgroundDark = Color(0xFF252525); // Slightly lighter than surface
  static const Color dividerDark = Color(0xFF323232);
  static const Color shadowDark = Color(0x40000000); // Darker shadow for depth
  static const Color iconColorDark = Color(0xFFE0E0E0);
  static const Color disabledColorDark = Color(0xFF505050);
  
  // Accent colors (modified for dark mode)
  static const Color highlightDark = Color(0xFFFFEB3B); // Brighter yellow for dark background
  static const Color successDark = Color(0xFF76FF03); // Brighter green for dark background
  static const Color errorDark = Color(0xFFFF5252); // Adjusted error for dark background
  
  // Additional accent colors for dark mode
  static const Color accentBlueDark = Color(0xFF64B5F6); // Blue accent
  static const Color accentPurpleDark = Color(0xFFB388FF); // Purple accent
  static const Color accentTealDark = Color(0xFF4DB6AC); // Teal accent
  static const Color accentAmberDark = Color(0xFFFFD54F); // Amber accent
}
