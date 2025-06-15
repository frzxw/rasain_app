import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  // Generate light theme with enhanced minimalist styling
  static ThemeData getLightTheme() {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.highlight,
      surface: AppColors.surface,
      error: AppColors.error,
      background: AppColors.background,
    );
    
    return _buildModernLightTheme(colorScheme);
  }

  // Build a modern, minimalist light theme
  static ThemeData _buildModernLightTheme(ColorScheme colorScheme) {
    // Colors
    const Color borderColor = AppColors.border;
    const Color cardColor = AppColors.cardBackground;
    const Color textPrimary = AppColors.textPrimary;
    const Color textSecondary = AppColors.textSecondary;
    
    return ThemeData(
      // Material 3 features
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      
      // Colors
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      
      // Typography
      textTheme: AppTypography.getTextTheme(isDark: false),
      
      // AppBar Theme with more refined styling
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: AppColors.iconColor,
          size: 22,
        ),
      ),
      
      // Card Theme with refined styling
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: borderColor,
            width: 0.5, // Thinner border for more refined look
          ),
        ),
        color: cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      
      // Input Decoration Theme with cleaner styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        hintStyle: TextStyle(
          color: textSecondary.withOpacity(0.7),
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: textSecondary, 
          fontSize: 14,
        ),
      ),
      
      // Button Themes with more refined styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 24,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      
      // FloatingActionButton with refined styling
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Chip Theme with modern styling
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: colorScheme.primary.withOpacity(0.15),
        disabledColor: AppColors.disabledColor,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: borderColor.withOpacity(0.5)),
        checkmarkColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 0.5, // Thinner dividers for modern look
        color: AppColors.divider,
      ),
      
      // BottomNavigationBar with modern styling
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 4, // Reduced elevation
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),

      // Switch with modern styling
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return AppColors.disabledColor;
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
      ),
      
      // Dialog with modern styling
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
      ),
      
      // Modern scroll physics
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(4), // Thinner scrollbar
        thumbColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.3)),
      ),
      
      // Sheet themes with modern styling
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        modalBackgroundColor: AppColors.background,
        modalElevation: 8,
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Snackbar with modern styling
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Modern progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.primary.withOpacity(0.15),
        linearTrackColor: colorScheme.primary.withOpacity(0.15),
        refreshBackgroundColor: AppColors.surface,
      ),
      
      // Tooltip with modern styling
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF616161),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      
      // List tile with more defined styling
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        iconColor: AppColors.iconColor,
      ),
    );
  }
}
