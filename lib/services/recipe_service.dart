import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'supabase_service.dart';
import 'dart:typed_data';

// This class has been fully migrated to use Supabase

class RecipeService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  List<Recipe> _popularRecipes = [];
  List<Recipe> _pantryRecipes = [];
  List<Recipe> _whatsNewRecipes = [];
  List<Recipe> _savedRecipes = [];
  List<Recipe> _recommendedRecipes = [];
  
  Recipe? _currentRecipe;
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Recipe> get popularRecipes => _popularRecipes;
  List<Recipe> get pantryRecipes => _pantryRecipes;
  List<Recipe> get whatsNewRecipes => _whatsNewRecipes;
  List<Recipe> get savedRecipes => _savedRecipes;
  List<Recipe> get recommendedRecipes => _recommendedRecipes;
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
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .gte('rating', 4.0)
          .order('rating', ascending: false)
          .limit(10);
      
      _popularRecipes = response
          .map<Recipe>((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      debugPrint('✅ Fetched ${_popularRecipes.length} popular recipes');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load popular recipes: $e');
      debugPrint('❌ Error fetching popular recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch recipes based on user's pantry
  Future<void> fetchPantryRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      
      if (userId == null) {
        _pantryRecipes = [];
        notifyListeners();
        return;
      }
      
      final pantryResponse = await _supabaseService.client
          .from('pantry_items')
          .select('name')
          .eq('user_id', userId);
      
      final pantryItemNames = pantryResponse
          .map<String>((item) => item['name'].toString().toLowerCase())
          .toList();
      
      if (pantryItemNames.isEmpty) {
        _pantryRecipes = [];
        notifyListeners();
        return;
      }
      
      final recipesResponse = await _supabaseService.client
          .from('recipes')
          .select()
          .order('created_at', ascending: false);
      
      final allRecipes = recipesResponse
          .map((recipeJson) => Recipe.fromJson(recipeJson))
          .toList();
      
      // Filter recipes that have at least one ingredient from pantry
      _pantryRecipes = allRecipes.where((recipe) {
        if (recipe.ingredients == null) return false;
        
        return recipe.ingredients!.any((ingredient) {
          final ingredientName = ingredient['name'].toString().toLowerCase();
          return pantryItemNames.any((pantryItem) => ingredientName.contains(pantryItem));
        });
      }).toList();
      
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
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('created_at', ascending: false)
          .limit(20);
      
      final recipes = response.map((recipe) => Recipe.fromJson(recipe)).toList();
      
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
      final userId = _supabaseService.client.auth.currentUser?.id;
      
      if (userId == null) {
        _savedRecipes = [];
        notifyListeners();
        return;
      }
      
      final response = await _supabaseService.client
          .from('saved_recipes')
          .select('recipe_id, recipes(*)')
          .eq('user_id', userId);
      
      final recipes = response
          .map((item) => Recipe.fromJson({
                ...item['recipes'], 
                'is_saved': true
              }))
          .toList();
      
      _savedRecipes = recipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load saved recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
    // Fetch recommended recipes based on user's preferences and history
  Future<void> fetchRecommendedRecipes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      
      if (userId == null) {
        // If no user is logged in, just return some popular recipes
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .order('rating', ascending: false)
            .limit(10);
        
        _recommendedRecipes = response
            .map<Recipe>((recipe) => Recipe.fromJson(recipe))
            .toList();
        
        debugPrint('✅ Fetched ${_recommendedRecipes.length} recommended recipes (non-personalized)');
        notifyListeners();
        return;
      }
      
      // This would ideally use a Supabase function to create personalized recommendations
      // For now, we'll use a mix of user's saved recipes categories and new popular recipes
      
      // Get user's saved recipes to extract their preferred categories
      final savedResponse = await _supabaseService.client
          .from('saved_recipes')
          .select('recipes(*)')
          .eq('user_id', userId);
      
      Set<String> preferredCategories = {};
      
      if (savedResponse.isNotEmpty) {
        for (var item in savedResponse) {
          final recipe = item['recipes'];
          if (recipe != null && recipe['categories'] != null) {
            preferredCategories.addAll(
              List<String>.from(recipe['categories'])
            );
          }
        }
      }
      
      // If user has preferences, fetch recipes with those categories
      if (preferredCategories.isNotEmpty) {
        // Get recipes that match any of the preferred categories
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .not('id', 'in', savedResponse.map((item) => item['recipes']['id']).toList())  // Exclude already saved
            .filter('categories', 'cs', '{"${preferredCategories.first}"}')  // Contains any preferred category
            .order('rating', ascending: false)
            .limit(12);
        
        _recommendedRecipes = response
            .map<Recipe>((recipe) => Recipe.fromJson(recipe))
            .toList();
      } else {
        // If no preferences yet, just get popular recipes
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .gte('rating', 4.5)
            .order('rating', ascending: false)
            .limit(12);
        
        _recommendedRecipes = response
            .map<Recipe>((recipe) => Recipe.fromJson(recipe))
            .toList();
      }
      
      debugPrint('✅ Fetched ${_recommendedRecipes.length} personalized recommended recipes');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommended recipes: $e');
      debugPrint('❌ Error fetching recommended recipes: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch single recipe by ID
  Future<Recipe?> fetchRecipeById(String recipeId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();
      
      // Check if recipe is saved
      bool isSaved = false;
      final userId = _supabaseService.client.auth.currentUser?.id;
      
      if (userId != null) {
        final savedCheck = await _supabaseService.client
            .from('saved_recipes')
            .select()
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
        
        isSaved = savedCheck.isNotEmpty;
      }
      
      final recipeData = {...response, 'is_saved': isSaved};
      final recipe = Recipe.fromJson(recipeData);
      
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
      
      final userId = _supabaseService.client.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Update on backend
      if (isSaved) {
        await _supabaseService.client
            .from('saved_recipes')
            .delete()
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
      } else {
        await _supabaseService.client
            .from('saved_recipes')
            .insert({
              'user_id': userId,
              'recipe_id': recipeId,
              'saved_at': DateTime.now().toIso8601String(),
            });
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
      final userId = _supabaseService.client.auth.currentUser?.id;
      
      if (userId == null) {
        _setError('User must be logged in to rate recipes');
        return;
      }
      
      // Check if the user has already rated this recipe
      final existingRatings = await _supabaseService.client
          .from('recipe_ratings')
          .select()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);
      
      if (existingRatings.isNotEmpty) {
        // Update existing rating
        await _supabaseService.client
            .from('recipe_ratings')
            .update({
              'rating': rating,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
      } else {
        // Insert new rating
        await _supabaseService.client
            .from('recipe_ratings')
            .insert({
              'user_id': userId,
              'recipe_id': recipeId,
              'rating': rating,
              'created_at': DateTime.now().toIso8601String(),
            });
      }
      
      // Update the average rating in the recipes table (this should ideally be done with a database trigger)
      final allRatings = await _supabaseService.client
          .from('recipe_ratings')
          .select('rating')
          .eq('recipe_id', recipeId);
      
      final avgRating = allRatings.isEmpty 
          ? rating 
          : allRatings.map<num>((r) => r['rating']).reduce((a, b) => a + b) / allRatings.length;
      
      await _supabaseService.client
          .from('recipes')
          .update({
            'rating': avgRating,
            'review_count': allRatings.length,
          })
          .eq('id', recipeId);
      
      // If the current recipe is the one we're rating, update it
      if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
        _currentRecipe = Recipe(
          id: _currentRecipe!.id,
          name: _currentRecipe!.name,
          rating: avgRating.toDouble(),
          reviewCount: allRatings.length,
          slug: _currentRecipe!.slug,
          imageUrl: _currentRecipe!.imageUrl,
          estimatedCost: _currentRecipe!.estimatedCost,
          cookTime: _currentRecipe!.cookTime,
          servings: _currentRecipe!.servings,
          ingredients: _currentRecipe!.ingredients,
          instructions: _currentRecipe!.instructions,
          description: _currentRecipe!.description,
          categories: _currentRecipe!.categories,
          isSaved: _currentRecipe!.isSaved,
        );
        notifyListeners();
      }
      
      debugPrint('✅ Successfully rated recipe: $recipeId with rating: $rating');
    } catch (e) {
      _setError('Failed to submit rating: $e');
      debugPrint('❌ Error rating recipe: $e');
    }
  }
  
  // Search recipes by name using Supabase's full-text search
  Future<List<Recipe>> searchRecipes(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .textSearch('name', query, config: 'english')
          .order('rating', ascending: false);
      
      final recipes = response
          .map<Recipe>((recipe) => Recipe.fromJson(recipe))
          .toList();
      
      debugPrint('✅ Found ${recipes.length} recipes matching "$query"');
      return recipes;
    } catch (e) {
      _setError('Failed to search recipes: $e');
      debugPrint('❌ Error searching recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }  // Search recipes by image (Store in Supabase Storage and return similar recipes)
  Future<List<Recipe>> searchRecipesByImage(List<int> imageBytes, String fileName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        _setError('User must be logged in to search by image');
        return [];
      }
      
      // Upload image to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'search_images/$userId/$timestamp-$fileName';
      
      await _supabaseService.client.storage
          .from('recipe_images')
          .uploadBinary(path, Uint8List.fromList(imageBytes));
        // Get image URL
      final imageUrl = _supabaseService.client.storage
          .from('recipe_images')
          .getPublicUrl(path);
      
      debugPrint('✅ Image uploaded to Supabase Storage: $imageUrl');
      
      // For now, just return popular recipes since we don't have AI image recognition
      // In a real implementation, you'd have a Supabase Edge Function or other service for image analysis
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('rating', ascending: false)
          .limit(10);
      
      final recipes = response
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
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .contains('categories', [category])
          .order('rating', ascending: false);
      
      final recipes = response
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
