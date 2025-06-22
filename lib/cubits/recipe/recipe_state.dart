import 'package:equatable/equatable.dart';
import '../../models/recipe.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeState extends Equatable {
  final List<Recipe> recipes;
  final List<Recipe> featuredRecipes;
  final List<Recipe> recommendedRecipes;
  final List<Recipe> savedRecipes;
  final List<Recipe> userRecipes; // Add user recipes
  final List<Recipe> pantryBasedRecipes; // Add pantry-based recipes
  final List<Recipe> filteredRecipes; // Add filtered recipes
  final List<Recipe> likedRecipes; // Add liked recipes
  final RecipeStatus status;
  final RecipeStatus pantryBasedStatus; // Add pantry-based status
  final String? errorMessage;
  final String? pantryBasedErrorMessage; // Add pantry-based error message
  final Map<String, List<Recipe>> categoryRecipes;
  final List<String> availableDifficultyLevels; // Added difficulty levels list
  const RecipeState({
    this.recipes = const [],
    this.featuredRecipes = const [],
    this.recommendedRecipes = const [],
    this.savedRecipes = const [],
    this.userRecipes = const [], // Initialize user recipes
    this.pantryBasedRecipes = const [], // Initialize pantry-based recipes
    this.filteredRecipes = const [], // Initialize filtered recipes
    this.likedRecipes = const [], // Initialize liked recipes
    this.status = RecipeStatus.initial,
    this.pantryBasedStatus =
        RecipeStatus.initial, // Initialize pantry-based status
    this.errorMessage,
    this.pantryBasedErrorMessage, // Initialize pantry-based error message
    this.categoryRecipes = const {},
    this.availableDifficultyLevels = const [], // Default empty list
  });
  RecipeState copyWith({
    List<Recipe>? recipes,
    List<Recipe>? featuredRecipes,
    List<Recipe>? recommendedRecipes,
    List<Recipe>? savedRecipes,
    List<Recipe>? userRecipes, // Add to copyWith
    List<Recipe>? pantryBasedRecipes, // Add to copyWith
    List<Recipe>? filteredRecipes, // Add to copyWith
    List<Recipe>? likedRecipes, // Add to copyWith
    RecipeStatus? status,
    RecipeStatus? pantryBasedStatus, // Add to copyWith
    String? errorMessage,
    String? pantryBasedErrorMessage, // Add to copyWith
    Map<String, List<Recipe>>? categoryRecipes,
    List<String>?
    availableDifficultyLevels, // Added difficulty levels to copyWith
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      featuredRecipes: featuredRecipes ?? this.featuredRecipes,
      recommendedRecipes: recommendedRecipes ?? this.recommendedRecipes,
      savedRecipes: savedRecipes ?? this.savedRecipes,
      userRecipes: userRecipes ?? this.userRecipes, // Add to copyWith
      pantryBasedRecipes:
          pantryBasedRecipes ?? this.pantryBasedRecipes, // Add to copyWith
      filteredRecipes:
          filteredRecipes ?? this.filteredRecipes, // Add to copyWith
      likedRecipes: likedRecipes ?? this.likedRecipes, // Add to copyWith
      status: status ?? this.status,
      pantryBasedStatus:
          pantryBasedStatus ?? this.pantryBasedStatus, // Add to copyWith
      errorMessage: errorMessage ?? this.errorMessage,
      pantryBasedErrorMessage:
          pantryBasedErrorMessage ??
          this.pantryBasedErrorMessage, // Add to copyWith
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
    userRecipes, // Add to props
    pantryBasedRecipes, // Add to props
    filteredRecipes, // Add to props
    likedRecipes, // Add to props
    status,
    pantryBasedStatus, // Add to props
    errorMessage,
    pantryBasedErrorMessage, // Add to props
    categoryRecipes,
    availableDifficultyLevels, // Added to props
  ];
}
