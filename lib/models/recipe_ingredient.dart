class RecipeIngredient {
  final String? id;
  final String? recipeId;
  final String ingredientName;
  final String? quantity;
  final String? unit;
  final int orderIndex;
  final String? notes;
  final String? ingredientId;
  final String? amount;

  const RecipeIngredient({
    this.id,
    this.recipeId,
    required this.ingredientName,
    this.quantity,
    this.unit,
    required this.orderIndex,
    this.notes,
    this.ingredientId,
    this.amount,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as String?,
      recipeId: json['recipe_id'] as String?,
      ingredientName: json['ingredient_name'] as String? ?? '',
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      notes: json['notes'] as String?,
      ingredientId: json['ingredient_id'] as String?,
      amount: json['amount'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      'ingredient_name': ingredientName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      'order_index': orderIndex,
      if (notes != null) 'notes': notes,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (amount != null) 'amount': amount,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'ingredient_name': ingredientName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      'order_index': orderIndex,
      if (notes != null) 'notes': notes,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (amount != null) 'amount': amount,
    };
  }

  RecipeIngredient copyWith({
    String? id,
    String? recipeId,
    String? ingredientName,
    String? quantity,
    String? unit,
    int? orderIndex,
    String? notes,
    String? ingredientId,
    String? amount,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
      ingredientId: ingredientId ?? this.ingredientId,
      amount: amount ?? this.amount,
    );
  }

  @override
  String toString() {
    String result = ingredientName;
    if (quantity != null && quantity!.isNotEmpty) {
      result = '$quantity $result';
      if (unit != null && unit!.isNotEmpty) {
        result = '$quantity $unit $ingredientName';
      }
    }
    return result;
  }
}
