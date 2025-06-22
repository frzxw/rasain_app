import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

class FavoriteService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<String> _favoriteRecipeIds = [];
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<String> get favoriteRecipeIds => _favoriteRecipeIds;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if recipe is favorite
  bool isFavorite(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }

  // Initialize and load user's favorites
  Future<void> initialize() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await loadUserFavorites();
    }
  }

  // Load user's favorite recipe IDs
  Future<void> loadUserFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _favoriteRecipeIds = [];
      _favoriteRecipes = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('📋 Loading favorite recipes for user: ${user.id}');

      // Get favorite recipe IDs
      final response = await _supabase
          .from('user_favorites')
          .select('recipe_id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _favoriteRecipeIds =
          (response as List)
              .map((item) => item['recipe_id'] as String)
              .toList();

      debugPrint('✅ Loaded ${_favoriteRecipeIds.length} favorite recipe IDs');

      // Load full recipe details
      if (_favoriteRecipeIds.isNotEmpty) {
        await _loadFavoriteRecipeDetails();
      } else {
        _favoriteRecipes = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
      _isLoading = false;
      debugPrint('❌ Error loading favorites: $e');
      notifyListeners();
    }
  }

  // Load full recipe details for favorites
  Future<void> _loadFavoriteRecipeDetails() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select('''
            id, name, slug, image_url, description, rating, review_count,
            estimated_cost, cook_time, servings, difficulty_level,
            created_by, is_featured, is_published, created_at, updated_at,
            nutrition_info, tips
          ''')
          .inFilter('id', _favoriteRecipeIds);

      _favoriteRecipes =
          (response as List).map((json) => Recipe.fromJson(json)).toList();

      debugPrint('✅ Loaded ${_favoriteRecipes.length} favorite recipe details');
    } catch (e) {
      debugPrint('❌ Error loading favorite recipe details: $e');
    }
  }

  // Add recipe to favorites
  Future<bool> addToFavorites(String recipeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _error = 'Please login to add favorites';
      notifyListeners();
      return false;
    }

    if (_favoriteRecipeIds.contains(recipeId)) {
      return true; // Already favorite
    }

    try {
      debugPrint('❤️ Adding recipe to favorites: $recipeId');

      await _supabase.from('user_favorites').insert({
        'user_id': user.id,
        'recipe_id': recipeId,
        'created_at': DateTime.now().toIso8601String(),
      });

      _favoriteRecipeIds.add(recipeId);
      _error = null;

      // Reload favorite recipes to get the full details
      await _loadFavoriteRecipeDetails();

      notifyListeners();
      debugPrint('✅ Recipe added to favorites successfully');
      return true;
    } catch (e) {
      _error = 'Failed to add to favorites: $e';
      debugPrint('❌ Error adding to favorites: $e');
      notifyListeners();
      return false;
    }
  }

  // Remove recipe from favorites
  Future<bool> removeFromFavorites(String recipeId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _error = 'Please login to manage favorites';
      notifyListeners();
      return false;
    }

    if (!_favoriteRecipeIds.contains(recipeId)) {
      return true; // Already not favorite
    }

    try {
      debugPrint('💔 Removing recipe from favorites: $recipeId');

      await _supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('recipe_id', recipeId);

      _favoriteRecipeIds.remove(recipeId);
      _favoriteRecipes.removeWhere((recipe) => recipe.id == recipeId);
      _error = null;

      notifyListeners();
      debugPrint('✅ Recipe removed from favorites successfully');
      return true;
    } catch (e) {
      _error = 'Failed to remove from favorites: $e';
      debugPrint('❌ Error removing from favorites: $e');
      notifyListeners();
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String recipeId) async {
    if (isFavorite(recipeId)) {
      return await removeFromFavorites(recipeId);
    } else {
      return await addToFavorites(recipeId);
    }
  }

  // Clear favorites (for logout)
  void clearFavorites() {
    _favoriteRecipeIds = [];
    _favoriteRecipes = [];
    _error = null;
    notifyListeners();
  }

  // Get favorite count
  int get favoriteCount => _favoriteRecipeIds.length;
}
