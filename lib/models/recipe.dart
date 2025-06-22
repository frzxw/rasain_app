import '../core/utils/difficulty_level_mapper.dart';

class Recipe {
  final String id;
  final String name;
  final String? slug; // Added slug field for SEO-friendly URLs
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? estimatedCost; // Changed to String to match database
  final String? cookTime; // Changed to String to match database
  final int? servings;
  final String? difficultyLevel; // easy, medium, hard
  final Map<String, dynamic>? nutritionInfo; // JSON format nutrition data
  final String? tips; // Cooking tips
  final List<Map<String, dynamic>>? ingredients;
  final List<Map<String, dynamic>>?
  instructions; // Changed to Map to support videos per step
  final String? description;
  final List<String>? categories;
  final bool isSaved;

  Recipe({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.estimatedCost,
    this.cookTime,
    this.servings,
    this.difficultyLevel,
    this.nutritionInfo,
    this.tips,
    this.ingredients,
    this.instructions,
    this.description,
    this.categories,
    this.isSaved = false,
  });

  // Generate slug from name for SEO-friendly URLs
  static String generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      slug:
          json['slug'] != null && json['slug'].toString().isNotEmpty
              ? json['slug']
              : generateSlug(json['name'] ?? ''), // Auto-generate if missing
      imageUrl: json['image_url'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      estimatedCost: json['estimated_cost']?.toString(),
      cookTime: json['cook_time']?.toString(),
      servings: json['servings'],
      difficultyLevel: DifficultyLevelMapper.toUI(json['difficulty_level'] as String?),
      nutritionInfo: json['nutrition_info'] as Map<String, dynamic>?,
      tips: json['tips'] as String?,
      ingredients:
          json['ingredients'] != null
              ? List<Map<String, dynamic>>.from(json['ingredients'])
              : null,
      instructions:
          json['instructions'] != null
              ? (json['instructions'] is List<String>
                  ?
                  // Convert string instructions to map format with only 'text' field
                  List<Map<String, dynamic>>.from(
                    (json['instructions'] as List).map(
                      (step) => {'text': step, 'videoUrl': null},
                    ),
                  )
                  : List<Map<String, dynamic>>.from(json['instructions']))
              : null,
      description: json['description'],
      categories:
          json['categories'] != null
              ? List<String>.from(json['categories'])
              : null,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug ?? generateSlug(name),
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'estimated_cost': estimatedCost,
      'cook_time': cookTime,
      'servings': servings,
      'difficulty_level': DifficultyLevelMapper.toDatabase(difficultyLevel),
      'nutrition_info': nutritionInfo,
      'tips': tips,
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
    String? slug,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? estimatedCost,
    String? cookTime,
    int? servings,
    String? difficultyLevel,
    Map<String, dynamic>? nutritionInfo,
    String? tips,
    List<Map<String, dynamic>>? ingredients,
    List<Map<String, dynamic>>? instructions,
    String? description,
    List<String>? categories,
    bool? isSaved,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      tips: tips ?? this.tips,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, slug: $slug, rating: $rating, reviewCount: $reviewCount, isSaved: $isSaved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
