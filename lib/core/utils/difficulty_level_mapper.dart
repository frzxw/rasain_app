class DifficultyLevelMapper {
  static const Map<String, String> _uiToDatabase = {
    'Mudah': 'mudah',
    'Sedang': 'sedang',
    'Sulit': 'sulit',
  };

  static const Map<String, String> _databaseToUi = {
    'mudah': 'Mudah',
    'sedang': 'Sedang',
    'sulit': 'Sulit',
  };

  /// Convert UI difficulty level to database format
  static String? toDatabase(String? uiLevel) {
    if (uiLevel == null) return null;
    return _uiToDatabase[uiLevel] ?? 'sedang';
  }

  /// Convert database difficulty level to UI format
  static String toUI(String? databaseLevel) {
    if (databaseLevel == null) return 'Sedang';
    return _databaseToUi[databaseLevel] ?? 'Sedang';
  }

  /// Get all UI difficulty levels
  static List<String> get uiLevels => _uiToDatabase.keys.toList();

  /// Get all database difficulty levels
  static List<String> get databaseLevels => _databaseToUi.keys.toList();
}
