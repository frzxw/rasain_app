import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ThemeStatus { initial, loading, loaded, error }

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final ThemeStatus status;
  final String? errorMessage;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.status = ThemeStatus.initial,
    this.errorMessage,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    ThemeStatus? status,
    String? errorMessage,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [themeMode, status, errorMessage];
}
