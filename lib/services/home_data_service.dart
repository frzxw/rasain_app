import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'fallback_data_service.dart';

/// Service khusus untuk memastikan home screen selalu punya data
class HomeDataService {
  static List<Recipe> getHomeRecipes() {
    debugPrint('🏠 HomeDataService: Getting home recipes...');

    // Selalu return fallback data untuk memastikan UI ada content
    final recipes = FallbackDataService.getMockRecipes();
    debugPrint('🏠 HomeDataService: Returning ${recipes.length} recipes');

    // Log detail recipes
    for (int i = 0; i < recipes.length; i++) {
      final recipe = recipes[i];
      debugPrint(
        '   Recipe ${i + 1}: ${recipe.name} (Rating: ${recipe.rating})',
      );
    }

    return recipes;
  }

  static List<Recipe> getFeaturedRecipes() {
    final allRecipes = getHomeRecipes();
    // Return resep dengan rating tertinggi
    allRecipes.sort((a, b) => b.rating.compareTo(a.rating));
    return allRecipes.take(3).toList();
  }

  static List<Recipe> getPopularRecipes() {
    return getHomeRecipes();
  }

  static List<Recipe> getRecommendedRecipes() {
    final allRecipes = getHomeRecipes();
    // Return resep yang tidak termasuk featured
    return allRecipes.skip(1).toList();
  }
}
