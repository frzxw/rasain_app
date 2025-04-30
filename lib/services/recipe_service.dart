import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'mock_api_service.dart';

class RecipeService extends ChangeNotifier {
  // Use MockApiService instead of ApiService
  final MockApiService _apiService = MockApiService();
  
  List<Recipe> _popularRecipes = [];
  List<Recipe> _pantryRecipes = [];
  List<Recipe> _whatsNewRecipes = [];
  List<Recipe> _savedRecipes = [];
  List<Recipe> _recommendedRecipes = []; // Added this line for recommended recipes
  
  Recipe? _currentRecipe;
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Recipe> get popularRecipes => _popularRecipes;
  List<Recipe> get pantryRecipes => _pantryRecipes;
  List<Recipe> get whatsNewRecipes => _whatsNewRecipes;
  List<Recipe> get savedRecipes => _savedRecipes;
  List<Recipe> get recommendedRecipes => _recommendedRecipes; // Added this getter
  
  Recipe? get currentRecipe => _currentRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize and load initial data
  Future<void> initialize() async {
    await Future.wait([
      fetchPopularRecipes(),
      fetchWhatsNewRecipes(),
      fetchSavedRecipes(),
      fetchRecommendedRecipes(),
      fetchPantryRecipes(), // Added this call to initialize pantry recipes
    ]);
  }
  
  // Fetch popular recipes
  Future<void> fetchPopularRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('recipes/popular');
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      _popularRecipes = recipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load popular recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch recipes based on user's pantry
  Future<void> fetchPantryRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('recipes/pantry');
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      _pantryRecipes = recipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pantry recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch latest recipes (what's new stream)
  Future<void> fetchWhatsNewRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('recipes/latest');
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      _whatsNewRecipes = recipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load latest recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch saved recipes
  Future<void> fetchSavedRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('recipes/saved');
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      _savedRecipes = recipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load saved recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch recommended recipes (new method)
  Future<void> fetchRecommendedRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('recipes/recommendations');
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      _recommendedRecipes = recipes;
      
      // Debug print to verify recipes are loaded
      debugPrint('🍲 Loaded ${recipes.length} recommended recipes');
      for (final recipe in recipes) {
        debugPrint('Recipe: ${recipe.name}, Image URL: ${recipe.imageUrl}');
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommended recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch single recipe by ID
  Future<Recipe?> fetchRecipeById(String recipeId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('recipes/$recipeId');
      
      final recipe = Recipe.fromJson(response['recipe']);
      
      _currentRecipe = recipe;
      notifyListeners();
      
      return recipe;
    } catch (e) {
      _setError('Failed to load recipe details: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Save recipe
  Future<void> toggleSaveRecipe(String recipeId) async {
    // Find if recipe is already saved
    final isSaved = _savedRecipes.any((r) => r.id == recipeId);
    
    try {
      // Toggle saved status on all instances of this recipe
      _toggleRecipeSavedStatus(recipeId, !isSaved);
      notifyListeners();
      
      // Update on backend
      if (isSaved) {
        await _apiService.delete('recipes/$recipeId/save');
      } else {
        await _apiService.post('recipes/$recipeId/save');
      }
      
      // Refresh saved recipes list
      await fetchSavedRecipes();
    } catch (e) {
      _setError('Failed to ${isSaved ? 'unsave' : 'save'} recipe: $e');
      
      // Revert the local change if API call failed
      _toggleRecipeSavedStatus(recipeId, isSaved);
      notifyListeners();
    }
  }
  
  // Submit a rating for a recipe
  Future<void> rateRecipe(String recipeId, double rating) async {
    try {
      await _apiService.post(
        'recipes/$recipeId/rate',
        body: {'rating': rating},
      );
      
      // If the current recipe is the one we're rating, update it
      if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
        _currentRecipe = _currentRecipe!.copyWith(
          rating: rating,
          reviewCount: _currentRecipe!.reviewCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to submit rating: $e');
    }
  }
  
  // Search recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get(
        'recipes/search',
        queryParams: {'query': query},
      );
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      return recipes;
    } catch (e) {
      _setError('Failed to search recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Search recipes by image (AI detection)
  Future<List<Recipe>> searchRecipesByImage(List<int> imageBytes, String fileName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.uploadFile(
        'recipes/search/image',
        imageBytes,
        fileName,
        'image',
      );
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      return recipes;
    } catch (e) {
      _setError('Failed to search recipes by image: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Filter recipes by category
  Future<List<Recipe>> filterRecipesByCategory(String category) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get(
        'recipes/filter',
        queryParams: {'category': category},
      );
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      return recipes;
    } catch (e) {
      _setError('Failed to filter recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String errorMessage) {
    debugPrint(errorMessage);
    _error = errorMessage;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Helper to toggle saved status across all recipe lists
  void _toggleRecipeSavedStatus(String recipeId, bool isSaved) {
    void updateList(List<Recipe> list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == recipeId) {
          list[i] = list[i].copyWith(isSaved: isSaved);
        }
      }
    }
    
    updateList(_popularRecipes);
    updateList(_pantryRecipes);
    updateList(_whatsNewRecipes);
    updateList(_recommendedRecipes); // Added this line
    
    if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
      _currentRecipe = _currentRecipe!.copyWith(isSaved: isSaved);
    }
    
    if (isSaved) {
      // If we're saving a recipe, check if it exists in any list and add to saved
      Recipe? recipe;
      
      for (final list in [_popularRecipes, _pantryRecipes, _whatsNewRecipes]) {
        final found = list.firstWhere(
          (r) => r.id == recipeId,
          orElse: () => recipe!,
        );
        
        if (found.id == recipeId) {
          recipe = found;
          break;
        }
      }
      
      if (recipe != null && !_savedRecipes.any((r) => r.id == recipeId)) {
        _savedRecipes.add(recipe.copyWith(isSaved: true));
      }
    } else {
      // If we're unsaving, remove from saved list
      _savedRecipes.removeWhere((r) => r.id == recipeId);
    }
  }
}
