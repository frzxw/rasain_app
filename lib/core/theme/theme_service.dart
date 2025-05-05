import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

class ThemeService extends ChangeNotifier {
  // Remove dark mode and dynamic colors preferences
  static const String _themePreferenceKey = 'app_theme_mode';

  // Always use light theme
  ThemeMode _themeMode = ThemeMode.light;

  ThemeService() {
    _updateSystemUIOverlay();
  }

  ThemeMode get themeMode => ThemeMode.light;

  // Update system UI based on light theme
  void _updateSystemUIOverlay() {
    final uiStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
    
    SystemChrome.setSystemUIOverlayStyle(uiStyle);
  }
}