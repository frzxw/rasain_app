import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme_service.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeService _themeService;

  ThemeCubit(this._themeService) : super(const ThemeState());

  // Initialize theme mode
  void initialize() {
    try {
      final themeMode = _themeService.themeMode;

      emit(state.copyWith(themeMode: themeMode, status: ThemeStatus.loaded));

      _updateSystemUIOverlay();
    } catch (e) {
      emit(
        state.copyWith(status: ThemeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Update system UI overlay style based on theme mode
  void _updateSystemUIOverlay() {
    // Always use light theme for the app
    final uiStyle = SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    SystemChrome.setSystemUIOverlayStyle(uiStyle);
  }
}
