import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_instruction.dart';
import '../core/utils/difficulty_level_mapper.dart';
import 'supabase_service.dart';

// This class has been fully migrated to use Supabase

class RecipeService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<Recipe> _popularRecipes = [];
  List<Recipe> _pantryRecipes = [];
  List<Recipe> _whatsNewRecipes = [];
  List<Recipe> _savedRecipes = [];
  List<Recipe> _recommendedRecipes = [];
  List<Recipe> _userRecipes = []; // Add user recipes
  List<Recipe> _allRecipes = [];

  Recipe? _currentRecipe;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recipe> get popularRecipes => _popularRecipes;
  List<Recipe> get pantryRecipes => _pantryRecipes;
  List<Recipe> get whatsNewRecipes => _whatsNewRecipes;
  List<Recipe> get savedRecipes => _savedRecipes;
  List<Recipe> get recommendedRecipes => _recommendedRecipes;
  List<Recipe> get userRecipes => _userRecipes; // Add getter
  List<Recipe> get allRecipes => _allRecipes;
  Recipe? get currentRecipe => _currentRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Initialize and load initial data
  Future<void> initialize() async {
    // Test koneksi dengan recipe yang ada di database
    await testRecipeConnection();

    await Future.wait([
      fetchPopularRecipes(),
      fetchWhatsNewRecipes(),
      fetchSavedRecipes(),
      fetchRecommendedRecipes(),
      fetchPantryRecipes(), // Added this call to initialize pantry recipes
      fetchUserRecipes(), // Add user recipes fetch
      fetchAllRecipes(),
    ]);
  }

  // Initialize service (call this on app startup)
  Future<void> initializeService() async {
    try {
      print('🚀 Initializing Recipe Service...');

      // Update any recipes that don't have slugs
      await updateRecipeSlugs();

      print('✅ Recipe Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Recipe Service: $e');
    }
  }

  // Add a recipe to saved recipes
  Future<void> addToSaved(String recipeId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update locally
      _toggleRecipeSavedStatus(recipeId, true);
      notifyListeners();

      // Insert into saved_recipes table
      await _supabaseService.client.from('saved_recipes').insert({
        'user_id': userId,
        'recipe_id': recipeId,
      });

      // Refresh saved recipes list
      await fetchSavedRecipes();
    } catch (e) {
      _setError('Failed to save recipe: $e');
      // Revert the local change if API call failed
      _toggleRecipeSavedStatus(recipeId, false);
      notifyListeners();
    }
  }

  // Remove a recipe from saved recipes
  Future<void> removeFromSaved(String recipeId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Update locally
      _toggleRecipeSavedStatus(recipeId, false);
      notifyListeners();

      // Delete from saved_recipes table
      await _supabaseService.client
          .from('saved_recipes')
          .delete()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);

      // Refresh saved recipes list
      await fetchSavedRecipes();
    } catch (e) {
      _setError('Failed to unsave recipe: $e');
      // Revert the local change if API call failed
      _toggleRecipeSavedStatus(recipeId, true);
      notifyListeners();
    }
  }

  // Simple test untuk koneksi recipe dengan reviews
  Future<void> testRecipeConnection() async {
    try {
      print('🧪 Testing recipe connection...');

      // Gunakan recipe ID yang ada di screenshot dari attachment
      const String recipeId =
          'b4dc9eb8-9ac2-1bac-a45f-8dce47ecf62a'; // salah satu ID dari gambar

      // Test ambil instructions dulu
      print('🔍 Testing instructions for recipe: $recipeId');
      final instructions = await getRecipeInstructions(recipeId);
      print('📋 Instructions count: ${instructions.length}');

      if (instructions.isNotEmpty) {
        print('✅ Found instructions:');
        for (var i = 0; i < instructions.length; i++) {
          print('   Step ${i + 1}: ${instructions[i]['text']}');
        }
      } else {
        print('❌ No instructions found for recipe');
      }

      // Test ambil reviews
      final reviews = await getRecipeReviews(recipeId);
      print('✅ Found ${reviews.length} reviews for recipe');

      if (reviews.isNotEmpty) {
        final firstReview = reviews.first;
        print(
          '   Sample review: ${firstReview['rating']}/5 - ${firstReview['comment']}',
        );
      }

      // Test review stats
      final stats = await getRecipeReviewStats(recipeId);
      print(
        '📊 Review stats: ${stats['average_rating']}/5 (${stats['total_reviews']} total)',
      );
    } catch (e) {
      print('❌ Error testing recipe connection: $e');
    }
  }

  // Fetch all recipes
  Future<void> fetchAllRecipes() async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('created_at', ascending: false);

      List<Recipe> recipesWithDetails = [];
      for (final recipeData in response) {
        final ingredients = await getRecipeIngredients(recipeData['id']);
        final instructions = await getRecipeInstructions(recipeData['id']);
        final recipeWithDetails = Recipe.fromJson({
          ...recipeData,
          'ingredients': ingredients,
          'instructions': instructions,
        });
        recipesWithDetails.add(recipeWithDetails);
      }

      _allRecipes = recipesWithDetails;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load all recipes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch popular recipes
  Future<void> fetchPopularRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 Fetching popular recipes from main recipes table...');

      // Use main recipes table instead of popular_recipes view
      // Sort by rating and review_count to get popular recipes
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .gte('rating', 4.0) // Minimum rating of 4.0
          .order('rating', ascending: false)
          .order('review_count', ascending: false)
          .limit(10);

      print('📋 Raw popular recipes response: $response');

      // Get recipes with ingredients from recipe_ingredients table
      List<Recipe> popularRecipesWithIngredients = [];
      for (final recipeData in response) {
        final ingredients = await getRecipeIngredients(recipeData['id']);
        final recipeWithIngredients = Recipe.fromJson({
          ...recipeData,
          'ingredients': ingredients,
        });
        popularRecipesWithIngredients.add(recipeWithIngredients);
      }

      _popularRecipes = popularRecipesWithIngredients;

      print(
        '✅ Fetched ${_popularRecipes.length} popular recipes with complete details',
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load popular recipes: $e');
      print('❌ Error fetching popular recipes: $e');

      // Fallback: Get any recipes if no highly rated ones exist
      try {
        print('🔄 Trying fallback: fetching any available recipes...');
        final fallbackResponse = await _supabaseService.client
            .from('recipes')
            .select()
            .order('review_count', ascending: false)
            .order('created_at', ascending: false)
            .limit(10);

        List<Recipe> fallbackRecipesWithIngredients = [];
        for (final recipeData in fallbackResponse) {
          final ingredients = await getRecipeIngredients(recipeData['id']);
          final recipeWithIngredients = Recipe.fromJson({
            ...recipeData,
            'ingredients': ingredients,
          });
          fallbackRecipesWithIngredients.add(recipeWithIngredients);
        }

        _popularRecipes = fallbackRecipesWithIngredients;
        print(
          '✅ Fallback successful: ${_popularRecipes.length} recipes loaded',
        );
        notifyListeners();
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
        _popularRecipes = [];
        notifyListeners();
      }
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

      final pantryItemNames =
          pantryResponse
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

      // Get recipes with ingredients from recipe_ingredients table
      List<Recipe> allRecipesWithIngredients = [];
      for (final recipeData in recipesResponse) {
        final ingredients = await getRecipeIngredients(recipeData['id']);
        final recipeWithIngredients = Recipe.fromJson({
          ...recipeData,
          'ingredients': ingredients,
        });
        allRecipesWithIngredients.add(recipeWithIngredients);
      }

      // Filter recipes that have at least one ingredient from pantry
      _pantryRecipes =
          allRecipesWithIngredients.where((recipe) {
            if (recipe.ingredients == null) return false;

            return recipe.ingredients!.any((ingredient) {
              final ingredientName =
                  ingredient['name'].toString().toLowerCase();
              return pantryItemNames.any(
                (pantryItem) => ingredientName.contains(pantryItem),
              );
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

      // Get recipes with ingredients from recipe_ingredients table
      List<Recipe> recipesWithIngredients = [];
      for (final recipeData in response) {
        final ingredients = await getRecipeIngredients(recipeData['id']);
        final recipeWithIngredients = Recipe.fromJson({
          ...recipeData,
          'ingredients': ingredients,
        });
        recipesWithIngredients.add(recipeWithIngredients);
      }

      _whatsNewRecipes = recipesWithIngredients;
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

      // Get saved recipes with ingredients from recipe_ingredients table
      List<Recipe> savedRecipesWithIngredients = [];
      for (final item in response) {
        final recipeData = item['recipes'];
        final ingredients = await getRecipeIngredients(recipeData['id']);
        final recipeWithIngredients = Recipe.fromJson({
          ...recipeData,
          'is_saved': true,
          'ingredients': ingredients,
        });
        savedRecipesWithIngredients.add(recipeWithIngredients);
      }

      _savedRecipes = savedRecipesWithIngredients;
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

        _recommendedRecipes =
            response.map<Recipe>((recipe) => Recipe.fromJson(recipe)).toList();

        print(
          '✅ Fetched ${_recommendedRecipes.length} recommended recipes (non-personalized)',
        );
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
            preferredCategories.addAll(List<String>.from(recipe['categories']));
          }
        }
      }

      // If user has preferences, fetch recipes with those categories
      if (preferredCategories.isNotEmpty) {
        // Get recipes that match any of the preferred categories
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .not(
              'id',
              'in',
              savedResponse.map((item) => item['recipes']['id']).toList(),
            ) // Exclude already saved
            .filter(
              'categories',
              'cs',
              '{"${preferredCategories.first}"}',
            ) // Contains any preferred category
            .order('rating', ascending: false)
            .limit(12);

        _recommendedRecipes =
            response.map<Recipe>((recipe) => Recipe.fromJson(recipe)).toList();
      } else {
        // If no preferences yet, just get popular recipes
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .gte('rating', 4.5)
            .order('rating', ascending: false)
            .limit(12);

        _recommendedRecipes =
            response.map<Recipe>((recipe) => Recipe.fromJson(recipe)).toList();
      }

      print(
        '✅ Fetched ${_recommendedRecipes.length} personalized recommended recipes',
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommended recipes: $e');
      print('❌ Error fetching recommended recipes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch single recipe by ID (menggunakan function baru dengan ingredients)
  Future<Recipe?> fetchRecipeById(String recipeId) async {
    return await fetchRecipeByIdWithIngredients(recipeId);
  } // Fetch single recipe by slug or ID (tries slug first, fallback to ID)

  Future<Recipe?> fetchRecipeBySlug(String identifier) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 Fetching recipe by identifier: $identifier');

      Map<String, dynamic> response;

      // First try to fetch by slug
      try {
        response =
            await _supabaseService.client
                .from('recipes')
                .select()
                .eq('slug', identifier)
                .single();
        print('✅ Found recipe by slug: $identifier');
      } catch (e) {
        print('❌ No recipe found by slug: $identifier, trying ID...');

        // If slug fails, try by ID
        response =
            await _supabaseService.client
                .from('recipes')
                .select()
                .eq('id', identifier)
                .single();
        print('✅ Found recipe by ID: $identifier');
      }

      final recipeId = response['id'];

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

      print(
        '✅ Fetched complete recipe: $ingredientsCount ingredients, $instructionsCount instructions, $reviewsCount reviews',
      );
      return recipe;
    } catch (e) {
      print('❌ Error fetching recipe by identifier: $e');
      _setError('Failed to load recipe details: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get ingredients for a specific recipe from recipe_ingredients table
  Future<List<Map<String, dynamic>>> getRecipeIngredients(
    String recipeId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('recipe_ingredients')
          .select('''
            id,
            ingredient_name,
            quantity,
            unit
          ''')
          .eq('recipe_id', recipeId)
          .order('id', ascending: true);

      print('✅ Fetched ${response.length} ingredients for recipe: $recipeId');

      return response
          .map<Map<String, dynamic>>(
            (ingredient) => {
              'id': ingredient['id']?.toString() ?? '',
              'name': ingredient['ingredient_name']?.toString() ?? '',
              'quantity': ingredient['quantity']?.toString() ?? '',
              'unit': ingredient['unit']?.toString() ?? '',
              'price': '', // Set empty karena tidak ada di tabel
              'image_url': null,
              'is_optional': false,
              'notes': null,
              'order_index': 0,
            },
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching ingredients for recipe $recipeId: $e');
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

      print(
        '✅ Fetched complete recipe: $ingredientsCount ingredients, $instructionsCount instructions, $reviewsCount reviews',
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
          .select('id, comment')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);
      if (existingReviews.isNotEmpty) {
        // Update existing review rating only, preserve comment
        final existingComment = existingReviews.first['comment'];
        final updateData = <String, dynamic>{
          'rating': rating,
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Preserve existing comment if it exists
        if (existingComment != null) {
          updateData['comment'] = existingComment;
        }
        await _supabaseService.client
            .from('recipe_reviews')
            .update(updateData)
            .eq('user_id', userId)
            .eq('recipe_id', recipeId);

        print(
          '✅ Updated rating for existing review. Comment preserved: ${existingComment != null ? "Yes" : "No"}',
        );
      } else {
        // Insert new review with rating only (no review text)
        await _supabaseService.client.from('recipe_reviews').insert({
          'user_id': userId,
          'recipe_id': recipeId,
          'rating': rating,
          'comment': null, // No comment when only rating
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      // Update the average rating in the recipes table using recipe_reviews
      await _updateRecipeAverageRating(recipeId);

      // If the current recipe is the one we're rating, get updated rating data
      if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
        // Get updated recipe data from database
        final updatedRecipe =
            await _supabaseService.client
                .from('recipes')
                .select('rating, review_count')
                .eq('id', recipeId)
                .single();

        _currentRecipe = Recipe(
          id: _currentRecipe!.id,
          name: _currentRecipe!.name,
          rating:
              (updatedRecipe['rating'] as num?)?.toDouble() ??
              _currentRecipe!.rating,
          reviewCount:
              updatedRecipe['review_count'] ?? _currentRecipe!.reviewCount,
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

      // Verify the review was updated correctly (debug)
      final verifyReview =
          await _supabaseService.client
              .from('recipe_reviews')
              .select('rating, comment')
              .eq('user_id', userId)
              .eq('recipe_id', recipeId)
              .single();

      print('✅ Successfully rated recipe: $recipeId with rating: $rating');
      print(
        '📋 Verification - Rating: ${verifyReview['rating']}, Comment: ${verifyReview['comment'] ?? 'No comment'}',
      );
    } catch (e) {
      _setError('Failed to submit rating: $e');
      print('❌ Error rating recipe: $e');
    }
  }

  // Search recipes by name using improved search algorithm
  Future<List<Recipe>> searchRecipes(String query) async {
    _setLoading(true);
    _clearError();

    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final searchTerm = query.trim().toLowerCase();

      // Search hanya berdasarkan nama resep saja
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .ilike('name', '%$searchTerm%')
          .order('rating', ascending: false)
          .limit(20);

      // Convert to Recipe objects
      final recipes =
          response.map<Recipe>((recipe) => Recipe.fromJson(recipe)).toList();

      print('✅ Found ${recipes.length} recipes matching "$query" by name');
      return recipes;
    } catch (e) {
      _setError('Failed to search recipes: $e');
      print('❌ Error searching recipes: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Search recipes by image (Store in Supabase Storage and return similar recipes)

  Future<List<Recipe>> searchRecipesByImage(
    List<int> imageBytes,
    String fileName,
  ) async {
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

      print('✅ Image uploaded to Supabase Storage: $imageUrl');

      // For now, just return popular recipes since we don't have AI image recognition
      // In a real implementation, you'd have a Supabase Edge Function or other service for image analysis
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .order('rating', ascending: false)
          .limit(10);

      final recipes =
          response.map((recipe) => Recipe.fromJson(recipe)).toList();

      return recipes;
    } catch (e) {
      _setError('Failed to search recipes by image: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Filter recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      print('🔍 Fetching recipes for category: $category');

      if (category == 'All') {
        // Return all recipes sorted by rating
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .order('rating', ascending: false)
            .limit(50);

        print('✅ Found ${response.length} recipes for "All" category');
        return response.map((recipe) => Recipe.fromJson(recipe)).toList();
      } else {
        // Filter by specific category using junction table with explicit join
        print('🔗 Using explicit join query for category: $category');

        // First, get the category ID
        final categoryResponse =
            await _supabaseService.client
                .from('recipe_categories')
                .select('id')
                .eq('name', category)
                .single();

        final categoryId = categoryResponse['id'];
        print('📋 Category ID for "$category": $categoryId');
        // Then get recipe IDs that belong to this category
        final mappingResponse = await _supabaseService.client
            .from('recipe_categories_recipes')
            .select('recipe_id')
            .eq('category_id', categoryId);

        final recipeIds =
            mappingResponse
                .map((mapping) => mapping['recipe_id'] as String)
                .toList();

        print(
          '📋 Found ${recipeIds.length} recipe IDs for category: $category',
        );

        if (recipeIds.isEmpty) {
          print('⚠️ No recipes found for category: $category');
          return [];
        } // Finally, get the actual recipes
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .filter('id', 'in', '(${recipeIds.join(',')})')
            .order('rating', ascending: false)
            .limit(50);

        print('✅ Found ${response.length} recipes for category: $category');
        if (response.isNotEmpty) {
          print('📋 Sample recipe: ${response.first['name']}');
        }
        return response.map((recipe) => Recipe.fromJson(recipe)).toList();
      }
    } catch (e) {
      print('❌ Error fetching recipes by category: $e');
      print('🔧 Error type: ${e.runtimeType}');
      print('🔧 Error details: ${e.toString()}');
      return [];
    }
  } // Get instructions for a specific recipe from recipe_instructions table

  Future<List<Map<String, dynamic>>> getRecipeInstructions(
    String recipeId,
  ) async {
    try {
      print('🔍 Fetching instructions for recipe: $recipeId');

      // Cek apakah table ada dan isinya
      final checkTable = await _supabaseService.client
          .from('recipe_instructions')
          .select('*')
          .limit(5);
      print('🔍 Sample data from recipe_instructions table: $checkTable');
      final response = await _supabaseService.client
          .from('recipe_instructions')
          .select('''
            id,
            step_number,
            instruction_text,
            image_url,
            recipe_id,
            timer_minutes
          ''')
          .eq('recipe_id', recipeId)
          .order('step_number', ascending: true);

      print('📋 Raw instructions response: $response');
      print('📋 Response type: ${response.runtimeType}');
      print('✅ Fetched ${response.length} instructions for recipe: $recipeId');
      final instructions =
          response
              .map<Map<String, dynamic>>(
                (instruction) => {
                  'id': instruction['id']?.toString() ?? '',
                  'text': instruction['instruction_text']?.toString() ?? '',
                  'description':
                      instruction['instruction_text']?.toString() ?? '',
                  'image_url': instruction['image_url']?.toString(),
                  'imageUrl': instruction['image_url']?.toString(),
                  'step_number': instruction['step_number'] ?? 0,
                  'timer_minutes': instruction['timer_minutes'],
                  'duration': instruction['timer_minutes'],
                  'estimatedTime': instruction['timer_minutes'],
                  'temperature': null,
                  'notes': null,
                },
              )
              .toList();

      print('📝 Processed instructions: $instructions');
      return instructions;
    } catch (e) {
      print('❌ Error fetching instructions for recipe $recipeId: $e');
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
      print('❌ Error fetching recipe details for $recipeId: $e');
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
        final recipeWithDetails = Recipe.fromJson({
          ...data,
          'ingredients': details['ingredients'],
          'instructions': details['instructions'],
          'reviews': details['reviews'],
        });
        recipesWithDetails.add(recipeWithDetails);
      } catch (e) {
        print('❌ Error processing recipe ${data['id']}: $e');
        // Tambahkan recipe tanpa details sebagai fallback
        recipesWithDetails.add(Recipe.fromJson(data));
      }
    }

    return recipesWithDetails;
  }

  // Get reviews for a specific recipe from recipe_reviews table
  Future<List<Map<String, dynamic>>> getRecipeReviews(String recipeId) async {
    try {
      // Use LEFT JOIN to include all reviews, even if user has no profile
      final response = await _supabaseService.client
          .from('recipe_reviews')
          .select('''
            id,
            user_id,
            rating,
            comment,
            created_at,
            recipe_id,
            user_profiles(
              name,
              image_url
            )
          ''')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} reviews for recipe: $recipeId');
      
      // Safety check: filter out any reviews that don't belong to this recipe
      final validReviews = response.where((review) => 
        review['recipe_id'] == recipeId
      ).toList();
      
      if (validReviews.length != response.length) {
        print('⚠️ Filtered out ${response.length - validReviews.length} reviews with wrong recipe_id');
      }

      return validReviews
          .map<Map<String, dynamic>>(
            (review) {
              // Extract user profile data from the JOIN
              final userProfile = review['user_profiles'];
              final userName = userProfile != null && userProfile['name'] != null
                  ? userProfile['name'].toString()
                  : 'User ${(review['user_id']?.toString() ?? '').length > 8 ? (review['user_id']?.toString() ?? '').substring(0, 8) : review['user_id']?.toString() ?? ''}';
              final userImage = userProfile != null ? userProfile['image_url'] : null;

              return {
                'id': review['id']?.toString() ?? '',
                'user_id': review['user_id']?.toString() ?? '',
                'rating': (review['rating'] as num?)?.toDouble() ?? 0.0,
                'comment': review['comment']?.toString() ?? '',
                'date': review['created_at']?.toString() ?? '',
                'user_name': userName,
                'user_image': userImage,
              };
            },
          )
          .toList();
    } catch (e) {
      print('❌ Error fetching reviews for recipe $recipeId: $e');
      return [];
    }
  }
  // Submit a review for a recipe
  Future<bool> submitRecipeReview(
    String recipeId,
    double rating,
    String comment,
  ) async {
    try {
      print('🔄 Starting review submission for recipe: $recipeId');
      print('📊 Rating: $rating, Comment: "$comment"');
      
      final userId = _supabaseService.client.auth.currentUser?.id;

      if (userId == null) {
        _setError('User must be logged in to submit reviews');
        return false;
      }

      print('👤 Submitting review as user: $userId');

      // Check if user has already reviewed this recipe
      final existingReviews = await _supabaseService.client
          .from('recipe_reviews')
          .select('id')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);
          
      print('📋 Found ${existingReviews.length} existing reviews from this user');
      
      if (existingReviews.isNotEmpty) {
        // Update existing review, preserve created_at
        print('🔄 Updating existing review...');
        final updateResult = await _supabaseService.client
            .from('recipe_reviews')
            .update({
              'rating': rating,
              'comment': comment,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingReviews.first['id'])
            .select();
            
        print('📊 Update result: $updateResult');
        print(
          '✅ Review updated successfully for recipe: $recipeId (preserved created_at)',
        );
      } else {
        // Insert new review
        print('➕ Inserting new review...');
        final insertResult = await _supabaseService.client.from('recipe_reviews').insert({
          'recipe_id': recipeId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        }).select();
        
        print('📊 Insert result: $insertResult');
        print('✅ New review submitted successfully for recipe: $recipeId');
      }

      // Update average rating in the recipes table
      print('🔄 Updating recipe average rating...');
      await _updateRecipeAverageRating(recipeId);

      return true;
    } catch (e) {
      print('❌ Error submitting review: $e');
      _setError('Failed to submit review: $e');
      return false;
    }
  }  // Update average rating for a recipe
  Future<void> _updateRecipeAverageRating(String recipeId) async {
    try {
      print('🔄 Starting rating update for recipe: $recipeId');
      
      // Get all ratings for this recipe from recipe_reviews table
      final allRatings = await _supabaseService.client
          .from('recipe_reviews')
          .select('rating')
          .eq('recipe_id', recipeId);

      print('📊 Found ${allRatings.length} ratings for recipe $recipeId');
      print('📊 Raw ratings data: $allRatings');

      if (allRatings.isNotEmpty) {
        final avgRating =
            allRatings.map<num>((r) => r['rating']).reduce((a, b) => a + b) /
            allRatings.length;

        print('📊 Calculated average: $avgRating');
        print('📊 Total review count: ${allRatings.length}');

        // Use RPC function to bypass RLS for rating updates
        try {
          final rpcResult = await _supabaseService.client.rpc(
            'update_recipe_rating',
            params: {
              'recipe_id': recipeId,
              'new_rating': avgRating,
              'new_review_count': allRatings.length,
            },
          );
          print('📊 RPC update result: $rpcResult');
          print('✅ Updated via RPC function');
        } catch (rpcError) {
          print('⚠️ RPC function not available, using direct update: $rpcError');
          
          // Fallback: Direct update (might fail due to RLS)
          final updateResult = await _supabaseService.client
              .from('recipes')
              .update({'rating': avgRating, 'review_count': allRatings.length})
              .eq('id', recipeId)
              .select('rating, review_count');

          print('📊 Direct update result: $updateResult');
          
          if (updateResult.isEmpty) {
            print('❌ Update failed - likely due to RLS policy. Recipe may not be owned by current user.');
            print('🔧 Solution: Create RPC function or adjust RLS policy for rating updates.');
          }
        }

        print(
          '✅ Updated average rating for recipe $recipeId: $avgRating (${allRatings.length} reviews)',
        );
      } else {
        print('⚠️ No ratings found for recipe $recipeId');
        // Update to 0 if no reviews exist
        try {
          await _supabaseService.client.rpc(
            'update_recipe_rating',
            params: {
              'recipe_id': recipeId,
              'new_rating': 0.0,
              'new_review_count': 0,
            },
          );
          print('✅ Reset to zero via RPC function');
        } catch (rpcError) {
          final updateResult = await _supabaseService.client
              .from('recipes')
              .update({'rating': 0.0, 'review_count': 0})
              .eq('id', recipeId)
              .select('rating, review_count');
          
          print('📊 Reset to zero - Direct update result: $updateResult');
        }
      }
    } catch (e) {
      print('❌ Error updating average rating: $e');
      print('🔍 Error details: ${e.toString()}');
      print('🔍 Error type: ${e.runtimeType}');
    }
  }

  // Get review statistics for a recipe
  Future<Map<String, dynamic>> getRecipeReviewStats(String recipeId) async {
    try {
      final reviews = await getRecipeReviews(recipeId);

      if (reviews.isEmpty) {
        return {
          'total_reviews': 0,
          'average_rating': 0.0,
          'rating_distribution': {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
        };
      }

      final totalReviews = reviews.length;
      final totalRating = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review['rating'],
      );
      final averageRating = totalRating / totalReviews;

      // Hitung distribusi rating
      final distribution = <String, int>{
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0,
        '1': 0,
      };

      for (final review in reviews) {
        final rating = review['rating'].round().toString();
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      return {
        'total_reviews': totalReviews,
        'average_rating': averageRating,
        'rating_distribution': distribution,
      };
    } catch (e) {
      print('❌ Error getting review stats: $e');
      return {
        'total_reviews': 0,
        'average_rating': 0.0,
        'rating_distribution': {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
      };
    }
  }

  // Utility function to generate URL-friendly slug from recipe name
  String generateSlug(String recipeName) {
    return recipeName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple hyphens with single
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing hyphens
  }

  // Updated function to ensure all recipes have proper slugs
  Future<void> updateRecipeSlugs() async {
    try {
      print('🔧 Updating recipe slugs...');

      // Get all recipes without slugs or with empty slugs
      final recipes = await _supabaseService.client
          .from('recipes')
          .select('id, name, slug')
          .or('slug.is.null,slug.eq.');

      print('📋 Found ${recipes.length} recipes needing slug updates');

      for (final recipe in recipes) {
        final recipeId = recipe['id'];
        final recipeName = recipe['name'];
        final newSlug = generateSlug(recipeName);

        print('🔄 Updating recipe: $recipeName -> $newSlug');

        await _supabaseService.client
            .from('recipes')
            .update({'slug': newSlug})
            .eq('id', recipeId);
      }

      print('✅ Recipe slugs updated successfully');
    } catch (e) {
      print('❌ Error updating recipe slugs: $e');
    }
  }

  /// Creates a new user recipe and uploads it to the database
  Future<String?> createUserRecipe({
    required String name,
    required String description,
    required int servings,
    required int cookingTime,
    required String category,
    required List<String> ingredients,
    required List<String> instructions,
    List<dynamic>? images,
    String? estimatedCost,
    String? difficultyLevel,
    Map<String, dynamic>? nutritionInfo,
    String? tips,
    List<RecipeIngredient>? detailedIngredients,
    List<RecipeInstruction>? detailedInstructions,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      // Get current user ID from Supabase auth
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      String? imageUrl;

      // Upload image to Supabase Storage if provided
      if (images != null && images.isNotEmpty) {
        imageUrl = await _uploadRecipeImage(images.first, name);
      } // Create recipe data matching database schema
      final recipeData = {
        'name': name,
        'slug': await _generateUniqueSlug(name),
        'image_url': imageUrl,
        'rating': 0.00,
        'review_count': 0,
        'estimated_cost': estimatedCost,
        'cook_time': cookingTime.toString(), // Convert to string without "min"
        'servings': servings,
        'description': description,
        'difficulty_level':
            DifficultyLevelMapper.toDatabase(difficultyLevel) ?? 'sedang',
        'nutrition_info': nutritionInfo ?? {},
        'tips': tips,
        'created_by': userId,
      };

      // Debug log
      print('📋 Recipe data to insert: $recipeData');

      // Insert recipe into database
      final response =
          await _supabaseService.client
              .from('recipes')
              .insert(recipeData)
              .select()
              .single();
      final recipeId = response['id'] as String;
      print('✅ Recipe created with ID: $recipeId');

      // Skip category insertion for now due to schema issue
      // Will be handled in a future update
      if (category.isNotEmpty) {
        print('📋 Category "$category" will be added in future update');
      } // Add ingredients with detailed information if available
      if (detailedIngredients != null && detailedIngredients.isNotEmpty) {
        final ingredientData =
            detailedIngredients.map((ingredient) {
              return {
                'recipe_id': recipeId,
                'ingredient_name': ingredient.ingredientName,
                'quantity': ingredient.quantity,
                'unit': ingredient.unit,
                'order_index': ingredient.orderIndex,
                'notes': ingredient.notes,
                'ingredient_id': ingredient.ingredientId,
                'amount': ingredient.amount,
              };
            }).toList();

        await _supabaseService.client
            .from('recipe_ingredients')
            .insert(ingredientData);

        print('✅ ${detailedIngredients.length} detailed ingredients added');
      } else if (ingredients.isNotEmpty) {
        // Fallback to simple ingredients
        final ingredientData =
            ingredients.asMap().entries.map((entry) {
              return {
                'recipe_id': recipeId,
                'ingredient_name': entry.value,
                'order_index': entry.key,
              };
            }).toList();

        await _supabaseService.client
            .from('recipe_ingredients')
            .insert(ingredientData);

        print('✅ ${ingredients.length} simple ingredients added');
      }

      // Add instructions with detailed information if available
      if (detailedInstructions != null && detailedInstructions.isNotEmpty) {
        final instructionData =
            detailedInstructions.map((instruction) {
              return {
                'recipe_id': recipeId,
                'step_number': instruction.stepNumber,
                'instruction_text': instruction.instructionText,
                'image_url': instruction.imageUrl,
                'timer_minutes': instruction.timerMinutes,
              };
            }).toList();

        await _supabaseService.client
            .from('recipe_instructions')
            .insert(instructionData);

        print('✅ ${detailedInstructions.length} detailed instructions added');
      } else if (instructions.isNotEmpty) {
        // Fallback to simple instructions
        final instructionData =
            instructions.asMap().entries.map((entry) {
              return {
                'recipe_id': recipeId,
                'step_number': entry.key + 1,
                'instruction_text': entry.value,
              };
            }).toList();

        await _supabaseService.client
            .from('recipe_instructions')
            .insert(instructionData);

        print('✅ ${instructions.length} simple instructions added');
      }

      print('🎉 Recipe "$name" created successfully!');

      // Refresh user recipes to include the new recipe
      await fetchUserRecipes();

      // Refresh all recipes to update home screen
      await initialize();

      return recipeId;
    } catch (e) {
      _error = 'Failed to create recipe: ${e.toString()}';
      print('❌ Error creating recipe: $e');
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Upload recipe image to Supabase Storage
  Future<String?> _uploadRecipeImage(dynamic image, String recipeName) async {
    try {
      final fileName =
          '${_generateSlug(recipeName)}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      late final Uint8List imageBytes;

      // Handle different image types
      if (image is XFile) {
        imageBytes = await image.readAsBytes();
      } else if (image is Uint8List) {
        imageBytes = image;
      } else {
        throw Exception('Unsupported image type');
      }

      // Upload to recipes bucket
      final response = await _supabaseService.client.storage
          .from('recipes')
          .uploadBinary(fileName, imageBytes);

      if (response.isNotEmpty) {
        // Get public URL
        final imageUrl = _supabaseService.client.storage
            .from('recipes')
            .getPublicUrl(fileName);

        print('✅ Recipe image uploaded: $imageUrl');
        return imageUrl;
      }

      return null;
    } catch (e) {
      print('❌ Error uploading recipe image: $e');
      return null;
    }
  }

  /// Generates a unique URL-friendly slug from recipe name
  Future<String> _generateUniqueSlug(String name) async {
    final baseSlug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    String slug = baseSlug;
    int counter = 1;

    // Keep checking until we find a unique slug
    while (await _slugExists(slug)) {
      slug = '$baseSlug-$counter';
      counter++;
    }

    return slug;
  }

  /// Check if a slug already exists in the database
  Future<bool> _slugExists(String slug) async {
    try {
      final response =
          await _supabaseService.client
              .from('recipes')
              .select('id')
              .eq('slug', slug)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error checking slug existence: $e');
      // If there's an error, assume it doesn't exist and add timestamp for safety
      return false;
    }
  }

  /// Generates a URL-friendly slug from recipe name (legacy method for compatibility)
  String _generateSlug(String name) {
    final baseSlug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    // Add timestamp to ensure uniqueness as fallback
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseSlug-$timestamp';
  }

  // Get available difficulty levels from database
  Future<List<String>> getAvailableDifficultyLevels() async {
    try {
      final response = await _supabaseService.client
          .from('recipes')
          .select('difficulty_level')
          .not('difficulty_level', 'is', null);

      final difficultyLevels =
          response
              .map((row) => row['difficulty_level'] as String?)
              .where((level) => level != null && level.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList();

      difficultyLevels.sort(); // Sort alphabetically
      debugPrint('✅ Found difficulty levels: $difficultyLevels');
      return difficultyLevels;
    } catch (e) {
      debugPrint('❌ Error fetching difficulty levels: $e');
      return ['Mudah', 'Sedang', 'Sulit']; // Default fallback
    }
  }

  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    print(errorMessage);
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
  // Helper to toggle saved status across all recipe lists
  void _toggleRecipeSavedStatus(String recipeId, bool isSaved) {
    debugPrint('🔄 _toggleRecipeSavedStatus: $recipeId, isSaved: $isSaved');
    
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
    updateList(_recommendedRecipes);

    if (_currentRecipe != null && _currentRecipe!.id == recipeId) {
      _currentRecipe = _currentRecipe!.copyWith(isSaved: isSaved);
    }

    if (isSaved) {
      // If we're saving a recipe, check if it exists in any list and add to saved
      Recipe? recipe;

      // Search through all lists to find the recipe
      for (final list in [_popularRecipes, _pantryRecipes, _whatsNewRecipes, _recommendedRecipes]) {
        try {
          final found = list.firstWhere((r) => r.id == recipeId);
          recipe = found;
          debugPrint('   Found recipe in list: ${found.name}');
          break;
        } catch (e) {
          // Recipe not found in this list, continue searching
        }
      }

      // If not found in any list, check current recipe
      if (recipe == null && _currentRecipe != null && _currentRecipe!.id == recipeId) {
        recipe = _currentRecipe;
        debugPrint('   Found recipe as current recipe: ${recipe!.name}');
      }

      // Add to saved list if we found the recipe and it's not already saved
      if (recipe != null && !_savedRecipes.any((r) => r.id == recipeId)) {
        _savedRecipes.add(recipe.copyWith(isSaved: true));
        debugPrint('   Added to saved recipes: ${recipe.name}');
      } else if (recipe == null) {
        debugPrint('❌ Recipe not found in any list for ID: $recipeId');
      }
    } else {
      // If we're unsaving, remove from saved list
      _savedRecipes.removeWhere((r) => r.id == recipeId);
      debugPrint('   Removed from saved recipes');
    }
  }

  // Filter recipes by price, time, and difficulty level
  List<Recipe> filterRecipes({
    RangeValues? priceRange,
    RangeValues? timeRange,
    String? difficultyLevel,
  }) {
    List<Recipe> filteredRecipes = List.from(
      _allRecipes,
    ); // Filter by price range
    if (priceRange != null) {
      filteredRecipes =
          filteredRecipes.where((recipe) {
            if (recipe.estimatedCost == null) return false;

            // Convert string estimatedCost to double for comparison
            final costDouble = double.tryParse(
              recipe.estimatedCost!.replaceAll(RegExp(r'[^0-9.]'), ''),
            );
            if (costDouble == null) return false;

            return costDouble >= priceRange.start &&
                costDouble <= priceRange.end;
          }).toList();
    } // Filter by time range
    if (timeRange != null) {
      filteredRecipes =
          filteredRecipes.where((recipe) {
            if (recipe.cookTime == null) return false;

            // Convert string cookTime to int for comparison
            final cookTimeInt = int.tryParse(
              recipe.cookTime!.replaceAll(RegExp(r'[^0-9]'), ''),
            );
            if (cookTimeInt == null) return false;

            return cookTimeInt >= timeRange.start &&
                cookTimeInt <= timeRange.end;
          }).toList();
    }

    // Filter by difficulty level
    if (difficultyLevel != null && difficultyLevel.isNotEmpty) {
      filteredRecipes =
          filteredRecipes.where((recipe) {
            return recipe.difficultyLevel == difficultyLevel;
          }).toList();
    }

    return filteredRecipes;
  }

  Future<List<String>> getRecipeCategories() async {
    try {
      print('🔍 Fetching categories from recipe_categories table...');
      final response = await _supabaseService.client
          .from('recipe_categories')
          .select('name')
          .order('name');

      final categories =
          response
              .map<String>((category) => category['name'] as String)
              .toList();

      print('✅ Found ${categories.length} categories from database');
      print('📋 Categories: ${categories.join(', ')}');

      // Add "All" at the beginning only if not already present
      final result = ['All', ...categories];
      return result;
    } catch (e) {
      print('❌ Error fetching categories: $e');
      // Return just 'All' if database fails - don't hardcode categories
      return ['All'];
    }
  }

  // Test function untuk melihat data bahan-bahan dari recipe_ingredients table
  Future<void> testRecipeIngredients() async {
    try {
      // Ambil beberapa recipe ID untuk testing
      final recipes = await _supabaseService.client
          .from('recipes')
          .select('id, name')
          .limit(3);

      print('🧪 Testing recipe ingredients connection...');

      for (final recipe in recipes) {
        final recipeId = recipe['id'];
        final recipeName = recipe['name'];

        print('📝 Recipe: $recipeName (ID: $recipeId)');

        final ingredients = await getRecipeIngredients(recipeId);

        if (ingredients.isNotEmpty) {
          print('✅ Found ${ingredients.length} ingredients:');
          for (final ingredient in ingredients) {
            print(
              '   - ${ingredient['name']} (${ingredient['quantity']} ${ingredient['unit']})',
            );
          }
        } else {
          print('❌ No ingredients found for this recipe');

          // Debug: cek apakah ada data di recipe_ingredients dengan recipe_id ini
          final debugCheck = await _supabaseService.client
              .from('recipe_ingredients')
              .select('ingredient_name, quantity, unit')
              .eq('recipe_id', recipeId);

          print('   🔍 Direct check found ${debugCheck.length} ingredients');
          for (final ing in debugCheck) {
            print(
              '   - ${ing['ingredient_name']} (${ing['quantity']} ${ing['unit']})',
            );
          }
        }
        print('');
      }
    } catch (e) {
      print('❌ Error testing recipe ingredients: $e');
    }
  } // Quick test untuk recipe tertentu yang ada di screenshot

  Future<void> testSpecificRecipe() async {
    try {
      // Test dengan recipe ID yang terlihat di screenshot: Soto Ayam Lamongan
      const String recipeId = 'a3cb8da7-8fb1-0a9b-f34e-7cbd3ba4e08d';

      print('🧪 Testing specific recipe: $recipeId');

      // Ambil data recipe
      final recipe =
          await _supabaseService.client
              .from('recipes')
              .select('id, name, slug')
              .eq('id', recipeId)
              .maybeSingle();

      if (recipe != null) {
        print('✅ Recipe found: ${recipe['name']}');

        // Ambil ingredients
        final ingredients = await _supabaseService.client
            .from('recipe_ingredients')
            .select('ingredient_name, quantity, unit')
            .eq('recipe_id', recipeId);

        print('✅ Found ${ingredients.length} ingredients:');
        for (final ingredient in ingredients) {
          print(
            '   - ${ingredient['ingredient_name']} (${ingredient['quantity']} ${ingredient['unit']})',
          );
        }

        // Ambil instructions
        final instructions = await _supabaseService.client
            .from('recipe_instructions')
            .select('step_number, instruction_text')
            .eq('recipe_id', recipeId)
            .order('step_number');

        print('✅ Found ${instructions.length} instructions:');
        for (final instruction in instructions) {
          print(
            '   ${instruction['step_number']}. ${instruction['instruction_text']}',
          );
        }

        // Ambil reviews
        final reviews = await getRecipeReviews(recipeId);
        print('✅ Found ${reviews.length} reviews:');
        for (final review in reviews.take(3)) {
          // Tampilkan 3 review pertama
          print(
            '   ⭐ ${review['rating']}/5 by ${review['user_name']}: ${review['comment']}',
          );
        }

        // Ambil review stats
        final stats = await getRecipeReviewStats(recipeId);
        print('📊 Review Stats:');
        print(
          '   Average: ${stats['average_rating']}/5 (${stats['total_reviews']} reviews)',
        );
        print('   Distribution: ${stats['rating_distribution']}');
      } else {
        print('❌ Recipe not found');
      }
    } catch (e) {
      print('❌ Error testing specific recipe: $e');
    }
  } // Test function untuk submit review (hanya untuk testing)

  Future<void> testSubmitReview() async {
    try {
      // Test dengan recipe ID yang ada di screenshot recipe_reviews
      const String recipeId = 'b4dc9eb8-9ac2-1bac-a45f-8dce4cb5f19e';

      print('🧪 Testing submit review for recipe: $recipeId');

      // Ambil reviews yang sudah ada dulu
      final existingReviews = await getRecipeReviews(recipeId);
      print('✅ Existing reviews count: ${existingReviews.length}');

      if (existingReviews.isNotEmpty) {
        print('📝 Sample existing reviews:');
        for (final review in existingReviews.take(3)) {
          print('   ⭐ ${review['rating']}/5: ${review['comment']}');
        }
      }

      // Test get review stats
      final stats = await getRecipeReviewStats(recipeId);
      print('📊 Review Stats:');
      print(
        '   Average: ${stats['average_rating']}/5 (${stats['total_reviews']} reviews)',
      );
      print('   Distribution: ${stats['rating_distribution']}');
    } catch (e) {
      print('❌ Error testing reviews: $e');
    }
  }

  /// Fetches recipes created by the current user
  Future<void> fetchUserRecipes() async {
    try {
      _setLoading(true);
      _clearError();

      // Get current user ID from Supabase auth
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        _userRecipes = [];
        return;
      }

      print(
        '🔍 Fetching user recipes for user: $userId',
      ); // Fetch recipes created by the user
      final response = await _supabaseService.client
          .from('recipes')
          .select('''
            *,
            recipe_ingredients(ingredient_name, order_index),
            recipe_instructions(step_number, instruction_text)
          ''')
          .eq('created_by', userId)
          .order('created_at', ascending: false);
      print('📥 Raw user recipes response: ${response.length} recipes');

      // Convert to Recipe objects
      final List<Recipe> userRecipesList = [];
      for (final json in response) {
        try {
          final recipe = Recipe.fromJson(json);
          userRecipesList.add(recipe);
        } catch (e) {
          print('❌ Error parsing user recipe: $e');
          print('   Recipe data: $json');
        }
      }

      _userRecipes = userRecipesList;

      print('✅ Loaded ${_userRecipes.length} user recipes');
    } catch (e) {
      _setError('Failed to fetch user recipes: $e');
      print('❌ Error fetching user recipes: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Refreshes user recipes after creating a new one
  Future<void> refreshUserRecipes() async {
    await fetchUserRecipes();
  }

  /// Test method to verify review and rating functionality
  Future<void> testReviewSystem(String recipeId) async {
    try {
      print('🧪 Testing review system for recipe: $recipeId');
      
      // Check current recipe rating
      final recipeCheck = await _supabaseService.client
          .from('recipes')
          .select('rating, review_count, name')
          .eq('id', recipeId)
          .single();
          
      print('📊 Current recipe state:');
      print('   Name: ${recipeCheck['name']}');
      print('   Rating: ${recipeCheck['rating']}');
      print('   Review Count: ${recipeCheck['review_count']}');
      
      // Check all reviews for this recipe
      final allReviews = await _supabaseService.client
          .from('recipe_reviews')
          .select('rating, comment, created_at')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);
          
      print('📊 All reviews in database:');
      print('   Total reviews: ${allReviews.length}');
      for (int i = 0; i < allReviews.length; i++) {
        final review = allReviews[i];
        print('   Review ${i + 1}: ${review['rating']}/5 - "${review['comment']}" (${review['created_at']})');
      }
      
      // Calculate expected average
      if (allReviews.isNotEmpty) {
        final totalRating = allReviews.fold<double>(0.0, (sum, review) => sum + (review['rating'] as num).toDouble());
        final expectedAverage = totalRating / allReviews.length;
        print('📊 Expected average: $expectedAverage');
        print('📊 Actual average: ${recipeCheck['rating']}');
        print('📊 Match: ${expectedAverage == recipeCheck['rating'] ? '✅' : '❌'}');
      }
      
      print('🧪 Review system test completed');
    } catch (e) {
      print('❌ Error testing review system: $e');
    }
  }
}
