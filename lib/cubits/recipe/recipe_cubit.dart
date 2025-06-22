import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/recipe_service.dart';
import '../../models/recipe.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeService _recipeService;

  RecipeCubit(this._recipeService) : super(const RecipeState());

  // Initialize and load trending recipes (using popular recipes as trending)
  Future<void> initialize() async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      await _recipeService.fetchPopularRecipes();
      final recipes = _recipeService.popularRecipes;
      emit(
        state.copyWith(
          recipes: recipes,
          filteredRecipes: recipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Load recipes by category
  Future<void> loadCategoryRecipes(String category) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final recipes = await _recipeService.getRecipesByCategory(category);
      emit(
        state.copyWith(
          recipes: recipes,
          filteredRecipes: recipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Search recipes
  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) {
      // Reset to all recipes if search is empty
      emit(state.copyWith(filteredRecipes: state.recipes));
      return;
    }

    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final recipes = await _recipeService.searchRecipes(query);
      emit(
        state.copyWith(filteredRecipes: recipes, status: RecipeStatus.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Filter recipes based on criteria
  Future<void> filterRecipes({
    List<String>? categories,
    List<String>? difficulties,
    RangeValues? priceRange,
    RangeValues? timeRange,
  }) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      // Use the filterRecipes method from RecipeService
      final filteredRecipes = _recipeService.filterRecipes(
        priceRange: priceRange,
        timeRange: timeRange,
        difficultyLevel:
            difficulties?.isNotEmpty == true ? difficulties!.first : null,
      );

      emit(
        state.copyWith(
          filteredRecipes: filteredRecipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Reset filters
  Future<void> resetFilters() async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      await _recipeService.fetchPopularRecipes();
      final recipes = _recipeService.popularRecipes;
      emit(
        state.copyWith(
          recipes: recipes,
          filteredRecipes: recipes,
          status: RecipeStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Fetch pantry-based recipe recommendations
  Future<void> fetchPantryBasedRecipes() async {
    emit(state.copyWith(pantryBasedStatus: RecipeStatus.loading));
    try {
      await _recipeService.fetchPantryRecipes();
      final recipes = _recipeService.pantryRecipes;
      emit(
        state.copyWith(
          pantryBasedRecipes: recipes,
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

  // Get user recipes
  Future<void> getUserRecipes() async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      await _recipeService.fetchUserRecipes();
      final recipes = _recipeService.userRecipes;
      emit(state.copyWith(userRecipes: recipes, status: RecipeStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Get liked recipes (using saved recipes as liked)
  Future<void> getLikedRecipes() async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      await _recipeService.fetchSavedRecipes();
      final recipes = _recipeService.savedRecipes;
      emit(state.copyWith(likedRecipes: recipes, status: RecipeStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: RecipeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Refresh user recipes (after uploading new recipe)
  Future<void> refreshUserRecipes() async {
    try {
      await _recipeService.fetchUserRecipes();
      final recipes = _recipeService.userRecipes;
      emit(state.copyWith(userRecipes: recipes));
    } catch (e) {
      debugPrint('Error refreshing user recipes: $e');
    }
  }

  // Refresh all recipes (after uploading new recipe)
  Future<void> refreshAllRecipes() async {
    try {
      await _recipeService.fetchPopularRecipes();
      final recipes = _recipeService.popularRecipes;
      emit(state.copyWith(recipes: recipes, filteredRecipes: recipes));
    } catch (e) {
      debugPrint('Error refreshing all recipes: $e');
    }
  }

  // Toggle like/save status
  Future<void> toggleLike(int recipeId) async {
    try {
      await _recipeService.toggleSaveRecipe(recipeId.toString());

      // Update the saved status in the current state
      final updatedRecipes =
          state.recipes.map((recipe) {
            if (recipe.id == recipeId.toString()) {
              return recipe.copyWith(isSaved: !recipe.isSaved);
            }
            return recipe;
          }).toList();

      final updatedFilteredRecipes =
          state.filteredRecipes.map((recipe) {
            if (recipe.id == recipeId.toString()) {
              return recipe.copyWith(isSaved: !recipe.isSaved);
            }
            return recipe;
          }).toList();

      final updatedPantryBasedRecipes =
          state.pantryBasedRecipes.map((recipe) {
            if (recipe.id == recipeId.toString()) {
              return recipe.copyWith(isSaved: !recipe.isSaved);
            }
            return recipe;
          }).toList();

      emit(
        state.copyWith(
          recipes: updatedRecipes,
          filteredRecipes: updatedFilteredRecipes,
          pantryBasedRecipes: updatedPantryBasedRecipes,
        ),
      );
    } catch (e) {
      debugPrint('Error toggling save: $e');
    }
  }
}
