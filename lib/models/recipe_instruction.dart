class RecipeInstruction {
  final String? id;
  final String? recipeId;
  final int stepNumber;
  final String instructionText;
  final String? imageUrl;
  final int? timerMinutes;

  const RecipeInstruction({
    this.id,
    this.recipeId,
    required this.stepNumber,
    required this.instructionText,
    this.imageUrl,
    this.timerMinutes,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) {
    return RecipeInstruction(
      id: json['id'] as String?,
      recipeId: json['recipe_id'] as String?,
      stepNumber: json['step_number'] as int? ?? 1,
      instructionText: json['instruction_text'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      timerMinutes: json['timer_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      'step_number': stepNumber,
      'instruction_text': instructionText,
      if (imageUrl != null) 'image_url': imageUrl,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'step_number': stepNumber,
      'instruction_text': instructionText,
      if (imageUrl != null) 'image_url': imageUrl,
      if (timerMinutes != null) 'timer_minutes': timerMinutes,
    };
  }

  RecipeInstruction copyWith({
    String? id,
    String? recipeId,
    int? stepNumber,
    String? instructionText,
    String? imageUrl,
    int? timerMinutes,
  }) {
    return RecipeInstruction(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      stepNumber: stepNumber ?? this.stepNumber,
      instructionText: instructionText ?? this.instructionText,
      imageUrl: imageUrl ?? this.imageUrl,
      timerMinutes: timerMinutes ?? this.timerMinutes,
    );
  }

  @override
  String toString() {
    return 'Langkah $stepNumber: $instructionText';
  }
}
