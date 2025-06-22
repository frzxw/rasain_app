/// Utility class for mapping between English and Indonesian difficulty levels
class DifficultyLevelMapper {
  // English to Indonesian mapping (for database storage)
  static const Map<String, String> _englishToIndonesian = {
    'easy': 'mudah',
    'medium': 'sedang',
    'hard': 'sulit',
  };

  // Indonesian to English mapping (for UI display)
  static const Map<String, String> _indonesianToEnglish = {
    'mudah': 'easy',
    'sedang': 'medium',
    'sulit': 'hard',
  };

  /// Convert English difficulty level to Indonesian for database storage
  static String? toDatabase(String? englishLevel) {
    if (englishLevel == null) return null;
    return _englishToIndonesian[englishLevel.toLowerCase()];
  }

  /// Convert Indonesian difficulty level to English for UI display
  static String? toUI(String? indonesianLevel) {
    if (indonesianLevel == null) return null;
    return _indonesianToEnglish[indonesianLevel.toLowerCase()];
  }

  /// Get all available difficulty levels in English for UI
  static List<String> get availableUILevels => _englishToIndonesian.keys.toList();

  /// Get all available difficulty levels in Indonesian for database
  static List<String> get availableDatabaseLevels => _englishToIndonesian.values.toList();

  /// Get display name for difficulty level (capitalizes first letter)
  static String getDisplayName(String level) {
    return level[0].toUpperCase() + level.substring(1).toLowerCase();
  }

  /// Check if a difficulty level is valid (either English or Indonesian)
  static bool isValid(String level) {
    final lowerLevel = level.toLowerCase();
    return _englishToIndonesian.containsKey(lowerLevel) ||
           _indonesianToEnglish.containsKey(lowerLevel);
  }
}
