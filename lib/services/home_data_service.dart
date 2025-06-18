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
    debugPrint('🎯 HomeDataService: Getting recommended recipes...');

    final allRecipes = getHomeRecipes();
    debugPrint('🎯 HomeDataService: Got ${allRecipes.length} total recipes');

    if (allRecipes.isEmpty) {
      debugPrint('❌ HomeDataService: No recipes available for recommendations');
      return [];
    }

    // Return resep dengan rating di atas 4.0 dan shuffle untuk variasi
    final recommendedList =
        allRecipes.where((recipe) => recipe.rating >= 4.0).toList();

    debugPrint(
      '🎯 HomeDataService: Found ${recommendedList.length} recipes with rating >= 4.0',
    );

    if (recommendedList.isEmpty) {
      debugPrint(
        '⚠️ HomeDataService: No recipes meet rating criteria, returning all recipes',
      );
      return allRecipes.take(5).toList();
    }

    // Shuffle untuk variasi setiap kali dipanggil
    recommendedList.shuffle();

    final finalList = recommendedList.take(5).toList();
    debugPrint(
      '🎯 HomeDataService: Returning ${finalList.length} recommended recipes:',
    );

    for (int i = 0; i < finalList.length; i++) {
      debugPrint(
        '   ${i + 1}. ${finalList[i].name} (Rating: ${finalList[i].rating})',
      );
    }

    return finalList;
  }
}
