class RecipeFavorite {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime createdAt;

  const RecipeFavorite({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.createdAt,
  });

  factory RecipeFavorite.fromJson(Map<String, dynamic> json) {
    return RecipeFavorite(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      recipeId: json['recipe_id'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RecipeFavorite copyWith({
    String? id,
    String? userId,
    String? recipeId,
    DateTime? createdAt,
  }) {
    return RecipeFavorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeFavorite &&
        other.id == id &&
        other.userId == userId &&
        other.recipeId == recipeId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ recipeId.hashCode;
  }

  @override
  String toString() {
    return 'RecipeFavorite(id: $id, userId: $userId, recipeId: $recipeId, createdAt: $createdAt)';
  }
}
