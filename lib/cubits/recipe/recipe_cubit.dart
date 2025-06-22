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
      final recommendedRecipes = _recipeService.recommendedRecipes;

      // Get saved recipes
      final savedRecipes = _recipeService.savedRecipes;

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
          categoryRecipes: categoryRecipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleSavedRecipe(String recipeId) async {
    try {
      debugPrint('🔄 RecipeCubit: Toggling saved status for recipe: $recipeId');

      // Toggle save status in the service
      await _recipeService.toggleSaveRecipe(recipeId);

      // Force refresh saved recipes from database to ensure latest data
      debugPrint('🔄 RecipeCubit: Refreshing saved recipes after toggle...');
      await _recipeService.fetchSavedRecipes();
      final savedRecipes = _recipeService.savedRecipes;

      debugPrint(
        '✅ RecipeCubit: Updated saved recipes count: ${savedRecipes.length}',
      );
      for (final recipe in savedRecipes) {
        debugPrint('   - Saved: ${recipe.name} (ID: ${recipe.id})');
      }

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

      final updatedRecipes =
          updatedRecipeMap.values
              .toList(); // Also update currentRecipe if it's the one being toggled
      if (_recipeService.currentRecipe?.id == recipeId) {
        await _recipeService.fetchRecipeById(
          recipeId,
        ); // Refresh current recipe
      }

      emit(state.copyWith(recipes: updatedRecipes, savedRecipes: savedRecipes));
      debugPrint(
        '🔄 RecipeCubit: State updated with ${savedRecipes.length} saved recipes',
      );
    } catch (e) {
      debugPrint('❌ RecipeCubit: Error toggling saved recipe: $e');
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

  // Filter recipes by price and time
  Future<void> filterRecipes({
    RangeValues? priceRange,
    RangeValues? timeRange,
    List<String>? categories,
    List<String>? difficulties,
  }) async {
    debugPrint(
      '🔍 RecipeCubit: Filtering recipes with price: $priceRange, time: $timeRange, categories: $categories, difficulties: $difficulties',
    );
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      // Call the synchronous filterRecipes method from RecipeService
      final filteredRecipes = _recipeService.filterRecipes(
        priceRange: priceRange,
        timeRange: timeRange,
        difficultyLevel:
            difficulties?.isNotEmpty == true ? difficulties!.first : null,
      );

      debugPrint(
        '✅ RecipeCubit: Found ${filteredRecipes.length} filtered recipes',
      );

      emit(
        state.copyWith(
          filteredRecipes: filteredRecipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('❌ RecipeCubit: Error filtering recipes: $e');
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

  // Fetch pantry-based recipes
  Future<void> fetchPantryBasedRecipes() async {
    try {
      emit(state.copyWith(pantryBasedStatus: RecipeStatus.loading));

      // Fetch pantry recipes from the service
      await _recipeService.fetchPantryRecipes();
      final pantryBasedRecipes = _recipeService.pantryRecipes;

      emit(
        state.copyWith(
          pantryBasedRecipes: pantryBasedRecipes,
          pantryBasedStatus: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          pantryBasedStatus: RecipeStatus.error,
          pantryBasedErrorMessage: e.toString(),
        ),
      );
    }
  }

  // Refresh user recipes
  Future<void> refreshUserRecipes() async {
    try {
      await _recipeService.fetchUserRecipes();
      final userRecipes = _recipeService.userRecipes;

      emit(state.copyWith(userRecipes: userRecipes));
    } catch (e) {
      debugPrint('❌ Error refreshing user recipes: $e');
    }
  }

  // Refresh all recipes
  Future<void> refreshAllRecipes() async {
    try {
      await initialize();
    } catch (e) {
      debugPrint('❌ Error refreshing all recipes: $e');
    }
  }

  // Load recipes by category
  Future<void> loadCategoryRecipes(String category) async {
    debugPrint('🔍 RecipeCubit: Loading recipes for category: $category');
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      if (category == 'All') {
        await initialize();
      } else {
        final recipes = await _recipeService.getRecipesByCategory(category);
        debugPrint(
          '✅ RecipeCubit: Found ${recipes.length} recipes for category: $category',
        );
        emit(
          state.copyWith(filteredRecipes: recipes, status: RecipeStatus.loaded),
        );
      }
    } catch (e) {
      debugPrint('❌ RecipeCubit: Error loading category recipes: $e');
      emit(
        state.copyWith(
          status: RecipeStatus.error,
          errorMessage: 'Failed to load category recipes: $e',
        ),
      );
    }
  }

  // Reset filters
  Future<void> resetFilters() async {
    debugPrint('🔄 RecipeCubit: Resetting filters');
    emit(state.copyWith(filteredRecipes: [], status: RecipeStatus.loaded));
    await initialize();
  }

  // Get liked/saved recipes
  Future<void> getLikedRecipes() async {
    try {
      debugPrint('🔄 RecipeCubit: Fetching liked/saved recipes...');
      await _recipeService.fetchSavedRecipes();
      final savedRecipes = _recipeService.savedRecipes;
      debugPrint('✅ RecipeCubit: Found ${savedRecipes.length} saved recipes');
      emit(state.copyWith(savedRecipes: savedRecipes));
    } catch (e) {
      debugPrint('❌ Error fetching liked recipes: $e');
    }
  }
}
