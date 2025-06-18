import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String name;
  final String? slug; // Added slug field for SEO-friendly URLs
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? estimatedCost;
  final String? cookTime;
  final int? servings;
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
    this.ingredients,
    this.instructions,
    this.description,
    this.categories,
    this.isSaved = false,
  });
  factory Recipe.fromJson(Map<String, dynamic> json) {
    debugPrint('Recipe fromJson: ${json['id']}');
    debugPrint('Recipe instructions raw data: ${json['instructions']}');

    // Handle instructions data with care to avoid errors
    List<Map<String, dynamic>>? instructions;
    if (json['instructions'] != null) {
      try {
        if (json['instructions'] is List<String>) {
          instructions =
              (json['instructions'] as List)
                  .map<Map<String, dynamic>>(
                    (step) => {'text': step.toString(), 'videoUrl': null},
                  )
                  .toList();
        } else if (json['instructions'] is List) {
          instructions =
              (json['instructions'] as List)
                  .map<Map<String, dynamic>>(
                    (item) =>
                        item is Map<String, dynamic>
                            ? item
                            : {'text': item.toString(), 'videoUrl': null},
                  )
                  .toList();
        }
      } catch (e) {
        debugPrint('Error processing instructions: $e');
        instructions = null;
      }
    }

    debugPrint('Recipe instructions processed: $instructions');

    return Recipe(
      id: json['id'].toString(), // Convert to string since DB might return int8
      name:
          json['title'] ??
          json['name'], // Try 'title' first, then fallback to 'name'
      slug:
          json['slug'] ??
          (json['title'] ?? json['name'])?.toString().toLowerCase().replaceAll(
            ' ',
            '-',
          ) ??
          '',
      imageUrl: json['image_url'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      estimatedCost: json['estimated_cost'],
      cookTime: json['cook_time'],
      servings: json['servings'],
      ingredients:
          json['ingredients'] != null
              ? List<Map<String, dynamic>>.from(json['ingredients'])
              : null,
      instructions: instructions,
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
      'slug': slug ?? name.toLowerCase().replaceAll(' ', '-'),
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
    String? slug,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? estimatedCost,
    String? cookTime,
    int? servings,
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
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
