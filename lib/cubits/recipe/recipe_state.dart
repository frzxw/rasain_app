import 'package:equatable/equatable.dart';
import '../../models/recipe.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeState extends Equatable {
  final List<Recipe> recipes;
  final List<Recipe> featuredRecipes;
  final List<Recipe> recommendedRecipes;
  final List<Recipe> savedRecipes;
  final RecipeStatus status;
  final String? errorMessage;
  final Map<String, List<Recipe>> categoryRecipes;

  const RecipeState({
    this.recipes = const [],
    this.featuredRecipes = const [],
    this.recommendedRecipes = const [],
    this.savedRecipes = const [],
    this.status = RecipeStatus.initial,
    this.errorMessage,
    this.categoryRecipes = const {},
  });

  RecipeState copyWith({
    List<Recipe>? recipes,
    List<Recipe>? featuredRecipes,
    List<Recipe>? recommendedRecipes,
    List<Recipe>? savedRecipes,
    RecipeStatus? status,
    String? errorMessage,
    Map<String, List<Recipe>>? categoryRecipes,
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      featuredRecipes: featuredRecipes ?? this.featuredRecipes,
      recommendedRecipes: recommendedRecipes ?? this.recommendedRecipes,
      savedRecipes: savedRecipes ?? this.savedRecipes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      categoryRecipes: categoryRecipes ?? this.categoryRecipes,
    );
  }

  @override
  List<Object?> get props => [
    recipes,
    featuredRecipes,
    recommendedRecipes,
    savedRecipes,
    status,
    errorMessage,
    categoryRecipes,
  ];
}
