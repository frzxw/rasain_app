import 'package:bloc/bloc.dart';
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
      final savedRecipes =
          _recipeService
              .savedRecipes; // Get all recipes: combine popular, new, and recommended
      final allRecipes =
          [
            ..._recipeService.popularRecipes,
            ..._recipeService.whatsNewRecipes,
            ..._recipeService.recommendedRecipes,
          ].toSet().toList(); // Remove duplicates

      // Process categories
      final Map<String, List<Recipe>> categoryRecipes = {};
      for (var recipe in allRecipes) {
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
          recipes: allRecipes,
          featuredRecipes: _recipeService.popularRecipes,
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

  Future<void> searchRecipesByImage(List<int> imageBytes, String imageName) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final searchResults = await _recipeService.searchRecipesByImage(imageBytes, imageName);
      emit(state.copyWith(recipes: searchResults, status: RecipeStatus.loaded));
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
    return state.categoryRecipes[category] ?? [];
  }
}
