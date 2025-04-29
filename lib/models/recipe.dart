class Recipe {
  final String id;
  final String name;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? estimatedCost;
  final String? cookTime;
  final int? servings;
  final List<Map<String, dynamic>>? ingredients;
  final List<String>? instructions;
  final String? description;
  final List<String>? categories;
  final bool isSaved;

  Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.estimatedCost,
    this.cookTime,
    this.servings,
    this.ingredients,
    this.instructions,
    this.description,
    this.categories,
    this.isSaved = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      estimatedCost: json['estimated_cost'],
      cookTime: json['cook_time'],
      servings: json['servings'],
      ingredients: json['ingredients'] != null ? 
        List<Map<String, dynamic>>.from(json['ingredients']) : null,
      instructions: json['instructions'] != null ?
        List<String>.from(json['instructions']) : null,
      description: json['description'],
      categories: json['categories'] != null ?
        List<String>.from(json['categories']) : null,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'estimated_cost': estimatedCost,
      'cook_time': cookTime,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'description': description,
      'categories': categories,
      'is_saved': isSaved,
    };
  }

  // Create a copy of recipe with modifications
  Recipe copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? estimatedCost,
    String? cookTime,
    int? servings,
    List<Map<String, dynamic>>? ingredients,
    List<String>? instructions,
    String? description,
    List<String>? categories,
    bool? isSaved,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
