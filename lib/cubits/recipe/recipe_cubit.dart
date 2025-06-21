import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeService _recipeService;

  RecipeCubit(this._recipeService) : super(const RecipeState());
  Future<void> initialize() async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      // Initialize the recipe service
      await _recipeService.initialize();

      // Get popular/featured recipes
      final popularRecipes = _recipeService.popularRecipes;

      // Get recommended recipes
      final recommendedRecipes =
          _recipeService.recommendedRecipes; // Get saved recipes
      final savedRecipes = _recipeService.savedRecipes;

      // Get user recipes
      final userRecipes = _recipeService.userRecipes;

      // Get all recipes: combine different sources and remove duplicates by ID
      final Map<String, Recipe> uniqueRecipes = {};

      // Add recipes from different sources, prioritizing popular recipes
      for (var recipe in _recipeService.popularRecipes) {
        uniqueRecipes[recipe.id] = recipe;
      }
      for (var recipe in _recipeService.whatsNewRecipes) {
        uniqueRecipes[recipe.id] = recipe;
      }
      for (var recipe in _recipeService.recommendedRecipes) {
        uniqueRecipes[recipe.id] = recipe;
      }
      for (var recipe in _recipeService.userRecipes) {
        uniqueRecipes[recipe.id] = recipe;
      }
      for (var recipe in _recipeService.allRecipes) {
        uniqueRecipes[recipe.id] = recipe;
      }

      final allRecipes = uniqueRecipes.values.toList();

      // Process categories with duplicate prevention
      final Map<String, Map<String, Recipe>> categoryRecipeMap = {};
      for (var recipe in allRecipes) {
        if (recipe.categories != null) {
          for (var category in recipe.categories!) {
            if (!categoryRecipeMap.containsKey(category)) {
              categoryRecipeMap[category] = {};
            }
            categoryRecipeMap[category]![recipe.id] = recipe;
          }
        }
      }

      // Convert to final format
      final Map<String, List<Recipe>> categoryRecipes = {};
      categoryRecipeMap.forEach((category, recipeMap) {
        categoryRecipes[category] = recipeMap.values.toList();
      });
      emit(
        state.copyWith(
          recipes: allRecipes,
          featuredRecipes: popularRecipes,
          recommendedRecipes: recommendedRecipes,
          savedRecipes: savedRecipes,
          userRecipes: userRecipes, // Add user recipes to state
          categoryRecipes: categoryRecipes,
          status: RecipeStatus.loaded,
        ),
      );

      // Fetch pantry-based recipes if available
      await fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleSavedRecipe(String recipeId) async {
    try {
      // Toggle save status in the service
      await _recipeService.toggleSaveRecipe(recipeId);

      // Get fresh data from the service
      final savedRecipes = _recipeService.savedRecipes;

      // Update recipes list with new saved status, avoiding duplicates
      final Map<String, Recipe> updatedRecipeMap = {};

      for (var recipe in state.recipes) {
        final isSaved = savedRecipes.any((saved) => saved.id == recipe.id);
        if (recipe.id == recipeId) {
          updatedRecipeMap[recipe.id] = Recipe(
            id: recipe.id,
            name: recipe.name,
            slug: recipe.slug,
            imageUrl: recipe.imageUrl,
            rating: recipe.rating,
            reviewCount: recipe.reviewCount,
            estimatedCost: recipe.estimatedCost,
            cookTime: recipe.cookTime,
            servings: recipe.servings,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            description: recipe.description,
            categories: recipe.categories,
            isSaved: isSaved,
          );
        } else {
          updatedRecipeMap[recipe.id] = recipe;
        }
      }

      final updatedRecipes = updatedRecipeMap.values.toList();

      emit(state.copyWith(recipes: updatedRecipes, savedRecipes: savedRecipes));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> searchRecipes(String query) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final searchResults = await _recipeService.searchRecipes(query);
      emit(state.copyWith(recipes: searchResults, status: RecipeStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> searchRecipesByImage(
    List<int> imageBytes,
    String imageName,
  ) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final searchResults = await _recipeService.searchRecipesByImage(
        imageBytes,
        imageName,
      );
      emit(state.copyWith(recipes: searchResults, status: RecipeStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Get recipe categories from database
  Future<List<String>> getCategories() async {
    try {
      return await _recipeService.getRecipeCategories();
    } catch (e) {
      return [
        'All',
        'Makanan Utama',
        'Pedas',
        'Tradisional',
        'Sup',
        'Daging',
        'Manis',
      ];
    }
  } // Filter recipes by category from database

  Future<void> filterByCategory(String category) async {
    debugPrint('🔍 RecipeCubit: Filtering by category: $category');
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final recipes = await _recipeService.getRecipesByCategory(category);
      debugPrint(
        '✅ RecipeCubit: Found ${recipes.length} recipes for category: $category',
      );
      emit(state.copyWith(status: RecipeStatus.loaded, recipes: recipes));
    } catch (e) {
      debugPrint('❌ RecipeCubit: Error filtering recipes: $e');
      emit(
        state.copyWith(
          status: RecipeStatus.error,
          errorMessage: 'Failed to filter recipes: $e',
        ),
      );
    }
  }

  /// Refreshes user recipes after creating a new recipe
  Future<void> refreshUserRecipes() async {
    try {
      emit(state.copyWith(status: RecipeStatus.loading));

      await _recipeService.fetchUserRecipes();

      emit(
        state.copyWith(
          userRecipes: _recipeService.userRecipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Refreshes all recipes including home page recipes after creating a new recipe
  Future<void> refreshAllRecipes() async {
    try {
      // Re-initialize to fetch all fresh data
      await initialize();
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Recipe? getRecipeById(String id) {
    try {
      return state.recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Recipe> getRecipesByCategory(String category) {
    final categoryRecipes = state.categoryRecipes[category] ?? [];
    // Remove duplicates by ID and sort by rating
    final Map<String, Recipe> uniqueRecipes = {};
    for (var recipe in categoryRecipes) {
      uniqueRecipes[recipe.id] = recipe;
    }
    final uniqueList = uniqueRecipes.values.toList();
    uniqueList.sort((a, b) => b.rating.compareTo(a.rating));
    return uniqueList;
  }

  void filterRecipes({
    RangeValues? priceRange,
    RangeValues? timeRange,
    String? category,
  }) {
    try {
      emit(state.copyWith(status: RecipeStatus.loading));

      List<Recipe> filteredRecipes = List.from(state.recipes);

      // Filter by category
      if (category != null && category.isNotEmpty && category != 'All') {
        filteredRecipes =
            filteredRecipes
                .where(
                  (recipe) =>
                      recipe.categories != null &&
                      recipe.categories!.any(
                        (cat) => cat.toLowerCase() == category.toLowerCase(),
                      ),
                )
                .toList();
      }

      // Filter by price range (using estimatedCost)
      if (priceRange != null) {
        filteredRecipes =
            filteredRecipes
                .where(
                  (recipe) =>
                      recipe.estimatedCost != null &&
                      recipe.estimatedCost! >= priceRange.start &&
                      recipe.estimatedCost! <= priceRange.end,
                )
                .toList();
      }

      // Filter by time range (using cookTime)
      if (timeRange != null) {
        filteredRecipes =
            filteredRecipes
                .where(
                  (recipe) =>
                      recipe.cookTime != null &&
                      recipe.cookTime! >= timeRange.start.toInt() &&
                      recipe.cookTime! <= timeRange.end.toInt(),
                )
                .toList();
      }

      emit(
        state.copyWith(recipes: filteredRecipes, status: RecipeStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipeStatus.error,
          errorMessage: 'Failed to filter recipes: ${e.toString()}',
        ),
      );
    }
  }
}
