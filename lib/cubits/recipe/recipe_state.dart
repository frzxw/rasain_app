import 'package:equatable/equatable.dart';
import '../../models/recipe.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeState extends Equatable {
  final List<Recipe> recipes;
  final List<Recipe> featuredRecipes;
  final List<Recipe> recommendedRecipes;
  final List<Recipe> savedRecipes;
  final List<Recipe> pantryBasedRecipes;
  final RecipeStatus status;
  final String? errorMessage;
  final Map<String, List<Recipe>> categoryRecipes;
  final List<String> availableDifficultyLevels; // Added difficulty levels list

  const RecipeState({
    this.recipes = const [],
    this.featuredRecipes = const [],
    this.recommendedRecipes = const [],
    this.savedRecipes = const [],
    this.pantryBasedRecipes = const [],
    this.status = RecipeStatus.initial,
    this.errorMessage,
    this.categoryRecipes = const {},
    this.availableDifficultyLevels = const [], // Default empty list
  });

  RecipeState copyWith({
    List<Recipe>? recipes,
    List<Recipe>? featuredRecipes,
    List<Recipe>? recommendedRecipes,
    List<Recipe>? savedRecipes,
    List<Recipe>? pantryBasedRecipes,
    RecipeStatus? status,
    String? errorMessage,
    Map<String, List<Recipe>>? categoryRecipes,
    List<String>?
    availableDifficultyLevels, // Added difficulty levels to copyWith
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      featuredRecipes: featuredRecipes ?? this.featuredRecipes,
      recommendedRecipes: recommendedRecipes ?? this.recommendedRecipes,
      savedRecipes: savedRecipes ?? this.savedRecipes,
      pantryBasedRecipes: pantryBasedRecipes ?? this.pantryBasedRecipes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      categoryRecipes: categoryRecipes ?? this.categoryRecipes,
      availableDifficultyLevels:
          availableDifficultyLevels ??
          this.availableDifficultyLevels, // Handle difficulty levels
    );
  }

  @override
  List<Object?> get props => [
    recipes,
    featuredRecipes,
    recommendedRecipes,
    savedRecipes,
    pantryBasedRecipes,
    status,
    errorMessage,
    categoryRecipes,
    availableDifficultyLevels, // Added to props
  ];
}
