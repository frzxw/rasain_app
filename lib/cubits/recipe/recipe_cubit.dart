import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../services/home_data_service.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeService _recipeService;

  RecipeCubit(this._recipeService) : super(const RecipeState());
  Future<void> initialize() async {
    debugPrint('🚀 RecipeCubit: Starting initialization...');
    emit(state.copyWith(status: RecipeStatus.loading));

    try {
      // Initialization is now handled in the RecipeService constructor,
      // so we can directly access the data.
      // await _recipeService.initialize(); // This is no longer needed.

      // Add a small delay to ensure data is processed
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('📊 RecipeCubit: Getting recipe data...');
      // Get popular/featured recipes
      final popularRecipes = _recipeService.popularRecipes;
      debugPrint('✅ Popular recipes: ${popularRecipes.length}');

      // Get saved recipes
      final savedRecipes = _recipeService.savedRecipes;
      debugPrint('✅ Saved recipes: ${savedRecipes.length}');

      // Get whats new recipes
      final whatsNewRecipes = _recipeService.whatsNewRecipes;
      debugPrint('✅ What\'s new recipes: ${whatsNewRecipes.length}');

      // Get all recipes: combine popular and new
      final allRecipes =
          <Recipe>{
            ...popularRecipes,
            ...whatsNewRecipes,
          }.toList(); // Use a Set to remove duplicates automatically
      debugPrint('✅ Total unique recipes: ${allRecipes.length}');

      // FALLBACK: If no recipes loaded from any source, use HomeDataService
      List<Recipe> finalRecipes = allRecipes;
      List<Recipe> finalFeatured = popularRecipes;
      // Recommended recipes are no longer a separate category in the new service
      List<Recipe> finalRecommended = [];

      if (allRecipes.isEmpty) {
        debugPrint(
          '⚠️ No recipes from database, using HomeDataService fallback',
        );
        finalRecipes = HomeDataService.getHomeRecipes();
        finalFeatured = HomeDataService.getFeaturedRecipes();
        finalRecommended = HomeDataService.getRecommendedRecipes();
        debugPrint('🔄 Fallback loaded: ${finalRecipes.length} recipes');
      } // Process categories
      final Map<String, List<Recipe>> categoryRecipes = {};
      for (var recipe in finalRecipes) {
        if (recipe.categories != null) {
          for (var category in recipe.categories!) {
            if (!categoryRecipes.containsKey(category)) {
              categoryRecipes[category] = [];
            }
            categoryRecipes[category]!.add(recipe);
          }
        }
      }

      emit(
        state.copyWith(
          recipes: finalRecipes,
          featuredRecipes: finalFeatured,
          recommendedRecipes: finalRecommended, // Pass the empty list
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
      // Toggle save status in the service
      await _recipeService.toggleSaveRecipe(recipeId);

      // Get fresh data from the service
      final savedRecipes = _recipeService.savedRecipes;

      // Update recipes list with new saved status
      final updatedRecipes =
          state.recipes.map((recipe) {
            final isSaved = savedRecipes.any((saved) => saved.id == recipe.id);
            if (recipe.id == recipeId) {
              return Recipe(
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
            }
            return recipe;
          }).toList();

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

  /*
  // This feature is not implemented in the new RecipeService.
  // Commenting it out to avoid compilation errors.
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
  */

  Recipe? getRecipeById(String id) {
    try {
      return state.recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Recipe> getRecipesByCategory(String category) {
    return state.categoryRecipes[category] ?? [];
  }
}
