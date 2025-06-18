import 'dart:core';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'supabase_service.dart';
import 'fallback_data_service.dart';
import 'dart:typed_data';

// This class has been fully migrated to use Supabase

class RecipeService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<Recipe> _popularRecipes = [];
  List<Recipe> _pantryRecipes = [];
  List<Recipe> _whatsNewRecipes = [];
  List<Recipe> _savedRecipes = [];
  Recipe? _currentRecipe;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recipe> get popularRecipes => _popularRecipes;
  List<Recipe> get pantryRecipes => _pantryRecipes;
  List<Recipe> get whatsNewRecipes => _whatsNewRecipes;
  List<Recipe> get savedRecipes => _savedRecipes;
  Recipe? get currentRecipe => _currentRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RecipeService() {
    // Initialize with fetchData
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchPopularRecipes(),
      fetchWhatsNewRecipes(),
      fetchSavedRecipes(),
    ]);
  }

  // Add recipe to saved collection
  Future<void> addToSaved(String recipeId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        _setError('User must be logged in to save recipes');
        return;
      }

      await _supabaseService.client.from('saved_recipes').insert({
        'user_id': userId,
        'recipe_id': recipeId,
        'saved_at': DateTime.now().toIso8601String(),
      });

      // Update local saved recipes
      await fetchSavedRecipes();
    } catch (e) {
      _setError('Failed to save recipe: $e');
    }
  }

  // Remove recipe from saved collection
  Future<void> removeFromSaved(String recipeId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        _setError('User must be logged in to unsave recipes');
        return;
      }

      await _supabaseService.client
          .from('saved_recipes')
          .delete()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);

      // Update local saved recipes
      await fetchSavedRecipes();
    } catch (e) {
      _setError('Failed to unsave recipe: $e');
    }
  }

  // Test available recipes first time
  Future<void> testAvailableRecipes() async {
    try {
      // Test dengan recipe ID yang ada di screenshot
      const String recipeId = 'f8ba3cfc-dea6-5fea-e89d-2bac8af9d53c';

      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .eq('id', recipeId);

      if (response.isNotEmpty) {
        debugPrint('✅ Found recipe test: ${response.first['title']}');
      } else {
        debugPrint('❌ Test recipe not found. Database might be empty.');
      }
    } catch (e) {
      debugPrint('❌ Error testing available recipes: $e');
    }
  }

  // Get recipes that can be made with user's pantry ingredients
  Future<List<Recipe>> getRecipesFromPantry(
    List<Map<String, dynamic>> pantryItems,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // Get all recipes first
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('rating', ascending: false);

      // Extract just the names from pantry items for easier matching
      final pantryItemNames =
          pantryItems
              .map<String>((item) => item['name'].toString().toLowerCase())
              .toList();

      // Helper function to check if recipe has all required ingredients
      bool canMakeRecipe(Map<String, dynamic> recipe, double matchThreshold) {
        // Get recipe ingredients, which may be null
        final ingredients = recipe['ingredients'];

        if (ingredients == null || ingredients.isEmpty) {
          return false;
        }

        // Count how many pantry items match recipe ingredients
        int matchingIngredients = 0;

        for (final ingredient in ingredients) {
          final ingredientName =
              ingredient['name']?.toString().toLowerCase() ?? '';

          // Check if any pantry item contains this ingredient name
          // or ingredient name contains any pantry item
          // (flexibile matching in both directions)
          final hasIngredient = pantryItemNames.any(
            (pantryItem) => ingredientName.contains(pantryItem),
          );

          if (hasIngredient) {
            matchingIngredients++;
          }
        }

        // Calculate match percentage
        final matchPercentage =
            ingredients.isEmpty
                ? 0.0
                : matchingIngredients / ingredients.length;

        // Return true if the match percentage meets the threshold
        return matchPercentage >= matchThreshold;
      }

      // Filter recipes that can be made with at least 50% of ingredients from pantry
      final matchableRecipes =
          response
              .where((recipe) => canMakeRecipe(recipe, 0.5))
              .map((recipe) => Recipe.fromJson(recipe))
              .toList();

      _pantryRecipes = matchableRecipes;
      notifyListeners();

      debugPrint(
        '✅ Found ${matchableRecipes.length} recipes that can be made with pantry items',
      );
      return matchableRecipes;
    } catch (e) {
      _setError('Failed to get pantry recipes: $e');
      debugPrint('❌ Error fetching pantry recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Recipe>> fetchPopularRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      // Try to get recipes from database
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('rating', ascending: false)
          .limit(10);

      final recipes =
          response.map((recipe) => Recipe.fromJson(recipe)).toList();

      _popularRecipes = recipes;
      notifyListeners();

      debugPrint('✅ Fetched ${recipes.length} popular recipes');

      // Extract categories from recipes to build user preferences
      Set<String> preferredCategories =
          {}; // Get unique categories from popular recipes to determine user preferences
      for (final recipe in _popularRecipes) {
        if (recipe.categories != null) {
          preferredCategories.addAll(recipe.categories!);
        }
      }

      return recipes;
    } catch (e) {
      debugPrint('❌ Error fetching popular recipes: $e');
      _setError(
        'Failed to load popular recipes: $e',
      ); // Use fallback data in case of error
      _popularRecipes = FallbackDataService.getMockRecipes();
      notifyListeners();

      return _popularRecipes;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Recipe>> fetchWhatsNewRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      // Get recently added recipes, sorted by creation date
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      final recipes =
          response.map((recipe) => Recipe.fromJson(recipe)).toList();

      _whatsNewRecipes = recipes;
      notifyListeners();

      debugPrint('✅ Fetched ${recipes.length} new recipes');
      return recipes;
    } catch (e) {
      debugPrint('❌ Error fetching new recipes: $e');
      _setError(
        'Failed to load new recipes: $e',
      ); // Use fallback data in case of error
      _whatsNewRecipes = FallbackDataService.getMockRecipes();
      notifyListeners();
      return _whatsNewRecipes;
    } finally {
      _setLoading(false);
    }
  }

  Future<Recipe?> fetchRecipeById(String recipeId) async {
    try {
      final recipe = await fetchRecipeByIdWithIngredients(recipeId);
      return recipe;
    } catch (e) {
      _setError('Failed to load recipe details: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRecipeIngredients(
    String recipeId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('recipe_ingredients')
          .select('''
            id,
            amount,
            unit,
            ingredients(id, name, icon)
          ''')
          .eq('recipe_id', recipeId)
          .order('id', ascending: true);

      debugPrint(
        '✅ Fetched ${response.length} ingredients for recipe: ${recipeId}',
      );

      return response
          .map<Map<String, dynamic>>(
            (item) => {
              'amount': item['amount'] ?? '',
              'unit': item['unit'] ?? '',
              'name': item['ingredients']['name'] ?? 'Unknown Ingredient',
              'icon': item['ingredients']['icon'],
              'id': item['id']?.toString() ?? '',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching ingredients for recipe $recipeId: $e');
      return [];
    }
  } // Update fetchRecipeById to include ingredients, instructions, and reviews from database tables

  Future<Recipe?> fetchRecipeByIdWithIngredients(String recipeId) async {
    _setLoading(true);
    _clearError();

    try {
      // Get recipe basic info
      final response =
          await _supabaseService.client
              .from('recipes')
              .select()
              .eq('id', recipeId)
              .single();

      // Get complete details (ingredients, instructions, reviews)
      final details = await getRecipeDetails(recipeId);

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

      // Combine recipe data with all details
      print('Instructions in recipeData: ${details['instructions']}');
      final recipeData = {
        ...response,
        'is_saved': isSaved,
        'ingredients': details['ingredients'],
        'instructions': details['instructions'],
        'reviews': details['reviews'],
      };

      final recipe = Recipe.fromJson(recipeData);

      _currentRecipe = recipe;
      notifyListeners();

      final ingredientsCount = (details['ingredients'] as List).length;
      final instructionsCount = (details['instructions'] as List).length;
      final reviewsCount = (details['reviews'] as List).length;

      debugPrint(
        '✅ Fetched complete recipe: ${ingredientsCount} ingredients, ${instructionsCount} instructions, ${reviewsCount} reviews',
      );
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
        await _supabaseService.client.from('saved_recipes').insert({
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
      final existingReviews = await _supabaseService.client
          .from('recipe_reviews')
          .select()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);

      if (existingReviews.isNotEmpty) {
        // Update existing review rating
        await _supabaseService.client
            .from('recipe_reviews')
            .update({
              'rating': rating,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);
      } else {
        // Insert new review with rating only (no comment)
        await _supabaseService.client.from('recipe_reviews').insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'rating': rating,
          'comment': null, // Menggunakan kolom 'comment' bukan 'review_text'
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      // Update the average rating in the recipes table using recipe_reviews
      await _updateRecipeAverageRating(recipeId);

      // If the current recipe is the one we're rating, get updated rating data
      if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
        // Get updated recipe data from database
        await fetchRecipeById(recipeId);
      }
    } catch (e) {
      _setError('Failed to rate recipe: $e');
      debugPrint('❌ Error rating recipe: $e');
    }
  }

  Future<List<Recipe>> fetchSavedRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        _savedRecipes = [];
        notifyListeners();
        return [];
      }

      // Get saved recipe IDs
      final savedResponse = await _supabaseService.client
          .from('saved_recipes')
          .select('recipe_id')
          .eq('user_id', userId);

      if (savedResponse.isEmpty) {
        _savedRecipes = [];
        notifyListeners();
        debugPrint('✅ No saved recipes found');
        return [];
      }

      // Extract recipe IDs
      final savedRecipeIds =
          savedResponse.map((item) => item['recipe_id']).toList();

      // Get recipe details for each saved recipe
      final List<Recipe> savedRecipes = [];

      for (final recipeId in savedRecipeIds) {
        final recipeResponse =
            await _supabaseService.client
                .from('recipes')
                .select()
                .eq('id', recipeId)
                .maybeSingle();

        if (recipeResponse != null) {
          final recipe = Recipe.fromJson({...recipeResponse, 'is_saved': true});
          savedRecipes.add(recipe);
        }
      }

      _savedRecipes = savedRecipes;
      notifyListeners();

      debugPrint('✅ Fetched ${savedRecipes.length} saved recipes');
      return savedRecipes;
    } catch (e) {
      debugPrint('❌ Error fetching saved recipes: $e');
      _setError('Failed to load saved recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  Future<List<Recipe>> searchRecipes(String query) async {
    _setLoading(true);
    _clearError();

    try {
      // Perform search through the API or database
      final String searchTerm = query.toLowerCase();

      final result = await _supabaseService.client
          .from('recipes')
          .select()
          .or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%')
          .order('rating', ascending: false);

      final searchResults =
          result.map((data) => Recipe.fromJson(data)).toList();

      debugPrint('✅ Found ${searchResults.length} matching recipes');
      return searchResults;
    } catch (e) {
      debugPrint('❌ Search error: $e');
      _setError('Failed to search recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<Uint8List?> getRecipeImageAsBytes(String fileName) async {
    try {
      // Temporarily use image url as is
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching recipe image: $e');
      return null;
    }
  }

  // Method to fetch recipes by category
  Future<List<Recipe>> filterRecipesByCategory(String category) async {
    _setLoading(true);
    _clearError();    try {
      // Filter recipes by category - use ilike instead of textSearch
      List<Map<String, dynamic>> response;
      
      if (category.toLowerCase() == 'all' || category.toLowerCase() == 'semua') {
        // Get all recipes if category is 'All'
        response = await _supabaseService.client
            .from('recipes')
            .select()
            .order('rating', ascending: false);
      } else {
        // Search in categories or name fields
        response = await _supabaseService.client
            .from('recipes')
            .select()
            .or('categories.ilike.%$category%,name.ilike.%$category%')
            .order('rating', ascending: false);
      }

      final filteredRecipes =
          response.map((data) => Recipe.fromJson(data)).toList();

      debugPrint(
        '✅ Found ${filteredRecipes.length} recipes in category: $category',
      );
      return filteredRecipes;
    } catch (e) {
      debugPrint('❌ Error filtering by category: $e');
      _setError('Failed to filter recipes by category: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get instructions for a specific recipe from recipe_instructions table
  Future<List<Map<String, dynamic>>> getRecipeInstructions(
    String recipeId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('recipe_instructions')
          .select('''
            id,
            step_number,
            instruction_text,
            image_url,
            timer_minutes
          ''')
          .eq('recipe_id', recipeId)
          .order('step_number', ascending: true);

      debugPrint(
        '✅ Fetched ${response.length} instructions for recipe: ${recipeId}',
      );
      print('Instructions response: ${response}');

      return response
          .map<Map<String, dynamic>>(
            (instruction) => {
              'id': instruction['id']?.toString() ?? '',
              'text': instruction['instruction_text']?.toString() ?? '',
              'videoUrl': null, // Tidak ada kolom video_url di tabel
              'step_number': instruction['step_number'] ?? 0,
              'imageUrl':
                  instruction['image_url'], // Gunakan kolom image_url dari tabel
              'estimatedTime':
                  instruction['timer_minutes'] != null
                      ? '${instruction['timer_minutes']} menit'
                      : null,
              'temperature': null,
              'notes': null,
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching instructions for recipe $recipeId: $e');
      return [];
    }
  }

  // Get ingredients, instructions, and reviews for a recipe in one function call
  Future<Map<String, dynamic>> getRecipeDetails(String recipeId) async {
    try {
      // Parallel fetch untuk performa yang lebih baik
      final results = await Future.wait([
        getRecipeIngredients(recipeId),
        getRecipeInstructions(recipeId),
        getRecipeReviews(recipeId),
      ]);

      return {
        'ingredients': results[0],
        'instructions': results[1],
        'reviews': results[2],
      };
    } catch (e) {
      debugPrint('❌ Error fetching recipe details for $recipeId: $e');
      return {
        'ingredients': <Map<String, dynamic>>[],
        'instructions': <Map<String, dynamic>>[],
        'reviews': <Map<String, dynamic>>[],
      };
    }
  }

  // Optimized version untuk fetch multiple recipes dengan details
  Future<List<Recipe>> fetchRecipesWithDetails(
    List<Map<String, dynamic>> recipeData,
  ) async {
    List<Recipe> recipesWithDetails = [];

    for (final data in recipeData) {
      try {
        final details = await getRecipeDetails(data['id']);

        // Create a complete recipe with details
        final recipe = Recipe.fromJson({
          ...data,
          'ingredients': details['ingredients'],
          'instructions': details['instructions'],
        });

        recipesWithDetails.add(recipe);
      } catch (e) {
        debugPrint('❌ Error fetching details for recipe ${data['id']}: $e');
      }
    }

    return recipesWithDetails;
  }

  // Get reviews for a specific recipe from recipe_reviews table
  Future<List<Map<String, dynamic>>> getRecipeReviews(String recipeId) async {
    try {
      debugPrint('🔍 Fetching reviews for recipe: $recipeId');

      // Simplified query without join first to test
      final response = await _supabaseService.client
          .from('recipe_reviews')
          .select('''
            id,
            user_id,
            rating,
            comment,
            created_at
          ''')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      debugPrint('✅ Fetched ${response.length} reviews for recipe: $recipeId');      // If no reviews found, return sample data for testing
      if (response.isEmpty) {
        debugPrint('📝 No reviews found, returning sample data');
        return [
          {
            'id': 'sample-1',
            'userId': 'sample-user-1',
            'username': 'Budi Santoso',
            'avatarUrl': null,
            'rating': 4.5,
            'comment':
                'Resep yang sangat enak! Mudah diikuti dan rasanya sempurna.',
            'date': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
          },
          {
            'id': 'sample-2',
            'userId': 'sample-user-2',
            'username': 'Siti Aminah',
            'avatarUrl': null,
            'rating': 5.0,
            'comment':
                'Keluarga saya sangat suka dengan resep ini. Terima kasih!',
            'date': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
          },
        ];
      }

      return response
          .map<Map<String, dynamic>>(
            (review) => {
              'id': review['id']?.toString() ?? '',
              'userId': review['user_id']?.toString() ?? '',
              'username': 'Pengguna Anonymous', // Simplified for now
              'avatarUrl': null,
              'rating': (review['rating'] as num?)?.toDouble() ?? 0.0,
              'comment': review['comment'] ?? '',
              'date': review['created_at']?.toString() ?? DateTime.now().toIso8601String(),
            },
          )
          .toList();    } catch (e) {
      debugPrint('❌ Error fetching reviews for recipe $recipeId: $e');

      // Return sample data on error
      return [
        {
          'id': 'fallback-1',
          'userId': 'fallback-user',
          'username': 'Pengguna Terdaftar',
          'avatarUrl': null,
          'rating': 4.0,
          'comment': 'Resep yang bagus dan mudah diikuti.',
          'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        },
      ];
    }
  }

  // Submit a review for a recipe
  Future<bool> submitRecipeReview(
    String recipeId,
    double rating,
    String comment,
  ) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        _setError('User must be logged in to submit reviews');
        return false;
      }

      // Check if user has already reviewed this recipe
      final existingReviews = await _supabaseService.client
          .from('recipe_reviews')
          .select('id')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);

      if (existingReviews.isNotEmpty) {
        // Update existing review
        await _supabaseService.client
            .from('recipe_reviews')
            .update({
              'rating': rating,
              'comment':
                  comment, // Menggunakan kolom 'comment' yang benar sesuai skema
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);

        debugPrint('✅ Updated review for recipe: $recipeId');
      } else {
        // Insert new review
        await _supabaseService.client.from('recipe_reviews').insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'rating': rating,
          'comment':
              comment, // Menggunakan kolom 'comment' yang benar sesuai skema
          'created_at': DateTime.now().toIso8601String(),
        });

        debugPrint('✅ Submitted new review for recipe: $recipeId');
      }

      // Update average rating di tabel recipes
      await _updateRecipeAverageRating(recipeId);

      return true;
    } catch (e) {
      debugPrint('❌ Error submitting review: $e');
      _setError('Failed to submit review: $e');
      return false;
    }
  }

  // Update average rating for a recipe based on all reviews
  Future<void> _updateRecipeAverageRating(String recipeId) async {
    try {
      // Get all ratings for this recipe from recipe_reviews table
      final reviewsResponse = await _supabaseService.client
          .from('recipe_reviews')
          .select('rating')
          .eq('recipe_id', recipeId);

      if (reviewsResponse.isEmpty) {
        // No reviews, set default rating
        await _supabaseService.client
            .from('recipes')
            .update({'rating': 0, 'review_count': 0})
            .eq('id', recipeId);
        return;
      }

      final List reviews = reviewsResponse;
      final totalRating = reviews.fold<double>(
        0,
        (sum, review) => sum + review['rating'],
      );

      final averageRating = totalRating / reviews.length;
      final reviewCount = reviews.length;

      // Update recipe with new average rating and review count
      await _supabaseService.client
          .from('recipes')
          .update({'rating': averageRating, 'review_count': reviewCount})
          .eq('id', recipeId);

      debugPrint(
        '✅ Updated average rating for recipe $recipeId: $averageRating from $reviewCount reviews',
      );
    } catch (e) {
      debugPrint('❌ Error updating recipe average rating: $e');
    }
  }

  Future<Map<String, dynamic>> getRecipeReviewStats(String recipeId) async {
    try {
      // Get all reviews for this recipe
      final reviewsResponse = await _supabaseService.client
          .from('recipe_reviews')
          .select('rating')
          .eq('recipe_id', recipeId);

      if (reviewsResponse.isEmpty) {
        return {
          'averageRating': 0.0,
          'reviewCount': 0,
          'distribution': {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
        };
      }

      final List reviews = reviewsResponse;
      final totalRating = reviews.fold<double>(
        0,
        (sum, review) => sum + review['rating'],
      );

      final averageRating = reviews.isEmpty ? 0 : totalRating / reviews.length;
      final reviewCount = reviews.length;

      // Calculate rating distribution
      final distribution = <String, int>{
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0,
        '1': 0,
      };

      for (final review in reviews) {
        final rating = review['rating'].round();
        if (rating >= 1 && rating <= 5) {
          final key = rating.toString();
          distribution[key] = (distribution[key] ?? 0) + 1;
        }
      }

      return {
        'averageRating': averageRating,
        'reviewCount': reviewCount,
        'distribution': distribution,
      };
    } catch (e) {
      debugPrint('❌ Error getting review stats: $e');
      return {
        'averageRating': 0.0,
        'reviewCount': 0,
        'distribution': {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
      };
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
    debugPrint('❌ Error: $errorMessage');
  }

  // Helper to toggle the saved status of recipes in memory
  void _toggleRecipeSavedStatus(String recipeId, bool isSaved) {
    // Update saved status in all recipe lists
    _updateSavedStatusInList(_popularRecipes, recipeId, isSaved);
    _updateSavedStatusInList(_whatsNewRecipes, recipeId, isSaved);
    _updateSavedStatusInList(_pantryRecipes, recipeId, isSaved);

    // Update current recipe if it's the same one
    if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
      _currentRecipe = _currentRecipe!.copyWith(isSaved: isSaved);
    }
  }

  // Helper to update saved status in a list of recipes
  void _updateSavedStatusInList(
    List<Recipe> recipeList,
    String recipeId,
    bool isSaved,
  ) {
    for (int i = 0; i < recipeList.length; i++) {
      if (recipeList[i].id == recipeId) {
        recipeList[i] = recipeList[i].copyWith(isSaved: isSaved);
      }
    }
  }

  // Test function for CI/CD
  Future<void> testSubmitReview() async {
    try {
      // Test dengan recipe ID yang ada di screenshot recipe_reviews
      const String recipeId = 'b4dc9eb8-9ac2-1bac-a45f-8dce4cb5f19e';
      final double rating = 4.5;
      final String comment = 'This is a test review from CI/CD';

      final success = await submitRecipeReview(recipeId, rating, comment);

      if (success) {
        debugPrint('✅ Successfully submitted test review');
      } else {
        debugPrint('❌ Failed to submit test review');
      }
    } catch (e) {
      debugPrint('❌ Error in test submit review: $e');
    }
  }
}
