import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
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
    ]);
  }

  // Initialize service (call this on app startup)
  Future<void> initializeService() async {
    try {
      debugPrint('🚀 Initializing Recipe Service...');

      // Update any recipes that don't have slugs
      await updateRecipeSlugs();

      debugPrint('✅ Recipe Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Recipe Service: $e');
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
        'saved_at': DateTime.now().toIso8601String(),
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
      debugPrint('🧪 Testing recipe connection...');

      // Gunakan recipe ID yang ada di screenshot dari attachment
      const String recipeId =
          'b4dc9eb8-9ac2-1bac-a45f-8dce47ecf62a'; // salah satu ID dari gambar

      // Test ambil instructions dulu
      debugPrint('🔍 Testing instructions for recipe: $recipeId');
      final instructions = await getRecipeInstructions(recipeId);
      debugPrint('📋 Instructions count: ${instructions.length}');

      if (instructions.isNotEmpty) {
        debugPrint('✅ Found instructions:');
        for (var i = 0; i < instructions.length; i++) {
          debugPrint('   Step ${i + 1}: ${instructions[i]['text']}');
        }
      } else {
        debugPrint('❌ No instructions found for recipe');
      }

      // Test ambil reviews
      final reviews = await getRecipeReviews(recipeId);
      debugPrint('✅ Found ${reviews.length} reviews for recipe');

      if (reviews.isNotEmpty) {
        final firstReview = reviews.first;
        debugPrint(
          '   Sample review: ${firstReview['rating']}/5 - ${firstReview['comment']}',
        );
      }

      // Test review stats
      final stats = await getRecipeReviewStats(recipeId);
      debugPrint(
        '📊 Review stats: ${stats['average_rating']}/5 (${stats['total_reviews']} total)',
      );
    } catch (e) {
      debugPrint('❌ Error testing recipe connection: $e');
    }
  } // Fetch popular recipes

  Future<void> fetchPopularRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔍 Fetching popular recipes from main recipes table...');

      // Use main recipes table instead of popular_recipes view
      // Sort by rating and review_count to get popular recipes
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .gte('rating', 4.0) // Minimum rating of 4.0
          .order('rating', ascending: false)
          .order('review_count', ascending: false)
          .limit(10);

      debugPrint('📋 Raw popular recipes response: $response');

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

      debugPrint(
        '✅ Fetched ${_popularRecipes.length} popular recipes with complete details',
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load popular recipes: $e');
      debugPrint('❌ Error fetching popular recipes: $e');

      // Fallback: Get any recipes if no highly rated ones exist
      try {
        debugPrint('🔄 Trying fallback: fetching any available recipes...');
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
        debugPrint(
          '✅ Fallback successful: ${_popularRecipes.length} recipes loaded',
        );
        notifyListeners();
      } catch (fallbackError) {
        debugPrint('❌ Fallback also failed: $fallbackError');
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

        debugPrint(
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

      debugPrint(
        '✅ Fetched ${_recommendedRecipes.length} personalized recommended recipes',
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommended recipes: $e');
      debugPrint('❌ Error fetching recommended recipes: $e');
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
      debugPrint('🔍 Fetching recipe by identifier: $identifier');

      Map<String, dynamic> response;

      // First try to fetch by slug
      try {
        response =
            await _supabaseService.client
                .from('recipes')
                .select()
                .eq('slug', identifier)
                .single();
        debugPrint('✅ Found recipe by slug: $identifier');
      } catch (e) {
        debugPrint('❌ No recipe found by slug: $identifier, trying ID...');

        // If slug fails, try by ID
        response =
            await _supabaseService.client
                .from('recipes')
                .select()
                .eq('id', identifier)
                .single();
        debugPrint('✅ Found recipe by ID: $identifier');
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

      debugPrint(
        '✅ Fetched complete recipe: $ingredientsCount ingredients, $instructionsCount instructions, $reviewsCount reviews',
      );
      return recipe;
    } catch (e) {
      debugPrint('❌ Error fetching recipe by identifier: $e');
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

      debugPrint(
        '✅ Fetched ${response.length} ingredients for recipe: $recipeId',
      );

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

        debugPrint(
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

      debugPrint('✅ Successfully rated recipe: $recipeId with rating: $rating');
      debugPrint(
        '📋 Verification - Rating: ${verifyReview['rating']}, Comment: ${verifyReview['comment'] ?? 'No comment'}',
      );
    } catch (e) {
      _setError('Failed to submit rating: $e');
      debugPrint('❌ Error rating recipe: $e');
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

      debugPrint('✅ Found ${recipes.length} recipes matching "$query" by name');
      return recipes;
    } catch (e) {
      _setError('Failed to search recipes: $e');
      debugPrint('❌ Error searching recipes: $e');
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

      debugPrint('✅ Image uploaded to Supabase Storage: $imageUrl');

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
      debugPrint('🔍 Fetching recipes for category: $category');

      if (category == 'All') {
        // Return all recipes sorted by rating
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .order('rating', ascending: false)
            .limit(50);

        debugPrint('✅ Found ${response.length} recipes for "All" category');
        return response.map((recipe) => Recipe.fromJson(recipe)).toList();
      } else {
        // Filter by specific category using junction table with explicit join
        debugPrint('🔗 Using explicit join query for category: $category');

        // First, get the category ID
        final categoryResponse =
            await _supabaseService.client
                .from('recipe_categories')
                .select('id')
                .eq('name', category)
                .single();

        final categoryId = categoryResponse['id'];
        debugPrint('📋 Category ID for "$category": $categoryId');
        // Then get recipe IDs that belong to this category
        final mappingResponse = await _supabaseService.client
            .from('recipe_categories_recipes')
            .select('recipe_id')
            .eq('category_id', categoryId);

        final recipeIds =
            mappingResponse
                .map((mapping) => mapping['recipe_id'] as String)
                .toList();

        debugPrint(
          '📋 Found ${recipeIds.length} recipe IDs for category: $category',
        );

        if (recipeIds.isEmpty) {
          debugPrint('⚠️ No recipes found for category: $category');
          return [];
        } // Finally, get the actual recipes
        final response = await _supabaseService.client
            .from('recipes')
            .select()
            .filter('id', 'in', '(${recipeIds.join(',')})')
            .order('rating', ascending: false)
            .limit(50);

        debugPrint(
          '✅ Found ${response.length} recipes for category: $category',
        );
        if (response.isNotEmpty) {
          debugPrint('📋 Sample recipe: ${response.first['name']}');
        }
        return response.map((recipe) => Recipe.fromJson(recipe)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error fetching recipes by category: $e');
      debugPrint('🔧 Error type: ${e.runtimeType}');
      debugPrint('🔧 Error details: ${e.toString()}');
      return [];
    }
  } // Get instructions for a specific recipe from recipe_instructions table

  Future<List<Map<String, dynamic>>> getRecipeInstructions(
    String recipeId,
  ) async {
    try {
      debugPrint('🔍 Fetching instructions for recipe: $recipeId');

      // Cek apakah table ada dan isinya
      final checkTable = await _supabaseService.client
          .from('recipe_instructions')
          .select('*')
          .limit(5);
      debugPrint('🔍 Sample data from recipe_instructions table: $checkTable');
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

      debugPrint('📋 Raw instructions response: $response');
      debugPrint('📋 Response type: ${response.runtimeType}');
      debugPrint(
        '✅ Fetched ${response.length} instructions for recipe: $recipeId',
      );
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

      debugPrint('📝 Processed instructions: $instructions');
      return instructions;
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
        final recipeWithDetails = Recipe.fromJson({
          ...data,
          'ingredients': details['ingredients'],
          'instructions': details['instructions'],
          'reviews': details['reviews'],
        });
        recipesWithDetails.add(recipeWithDetails);
      } catch (e) {
        debugPrint('❌ Error processing recipe ${data['id']}: $e');
        // Tambahkan recipe tanpa details sebagai fallback
        recipesWithDetails.add(Recipe.fromJson(data));
      }
    }

    return recipesWithDetails;
  }

  // Get reviews for a specific recipe from recipe_reviews table
  Future<List<Map<String, dynamic>>> getRecipeReviews(String recipeId) async {
    try {
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

      debugPrint('✅ Fetched ${response.length} reviews for recipe: $recipeId');
      return response
          .map<Map<String, dynamic>>(
            (review) => {
              'id': review['id']?.toString() ?? '',
              'user_id': review['user_id']?.toString() ?? '',
              'rating': (review['rating'] as num?)?.toDouble() ?? 0.0,
              'comment':
                  review['comment']?.toString() ??
                  '', // Fixed: using 'comment' instead of 'review_text'
              'date': review['created_at']?.toString() ?? '',
              'user_name':
                  'User', // Default name, bisa diambil dari user_profiles nanti
              'user_image': null,
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching reviews for recipe $recipeId: $e');
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
        // Update existing review, preserve created_at
        await _supabaseService.client
            .from('recipe_reviews')
            .update({
              'rating': rating,
              'comment': comment,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingReviews.first['id']);
        debugPrint(
          '✅ Review updated successfully for recipe: $recipeId (preserved created_at)',
        );
      } else {
        // Insert new review
        await _supabaseService.client.from('recipe_reviews').insert({
          'recipe_id': recipeId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        });
        debugPrint('✅ New review submitted successfully for recipe: $recipeId');
      }

      // Update average rating in the recipes table
      await _updateRecipeAverageRating(recipeId);

      return true;
    } catch (e) {
      debugPrint('❌ Error submitting review: $e');
      _setError('Failed to submit review: $e');
      return false;
    }
  }

  // Update average rating for a recipe
  Future<void> _updateRecipeAverageRating(String recipeId) async {
    try {
      // Get all ratings for this recipe from recipe_reviews table
      final allRatings = await _supabaseService.client
          .from('recipe_reviews')
          .select('rating')
          .eq('recipe_id', recipeId);

      if (allRatings.isNotEmpty) {
        final avgRating =
            allRatings.map<num>((r) => r['rating']).reduce((a, b) => a + b) /
            allRatings.length;

        await _supabaseService.client
            .from('recipes')
            .update({'rating': avgRating, 'review_count': allRatings.length})
            .eq('id', recipeId);

        debugPrint(
          '✅ Updated average rating for recipe $recipeId: $avgRating (${allRatings.length} reviews)',
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating average rating: $e');
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
      debugPrint('❌ Error getting review stats: $e');
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
      debugPrint('🔧 Updating recipe slugs...');

      // Get all recipes without slugs or with empty slugs
      final recipes = await _supabaseService.client
          .from('recipes')
          .select('id, name, slug')
          .or('slug.is.null,slug.eq.');

      debugPrint('📋 Found ${recipes.length} recipes needing slug updates');

      for (final recipe in recipes) {
        final recipeId = recipe['id'];
        final recipeName = recipe['name'];
        final newSlug = generateSlug(recipeName);

        debugPrint('🔄 Updating recipe: $recipeName -> $newSlug');

        await _supabaseService.client
            .from('recipes')
            .update({'slug': newSlug})
            .eq('id', recipeId);
      }

      debugPrint('✅ Recipe slugs updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating recipe slugs: $e');
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
  }) async {
    try {
      _setLoading(true);
      _error = null;

      // Get current user ID from Supabase auth
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create recipe data
      final recipeData = {
        'name': name,
        'description': description,
        'servings': servings,
        'cooking_time': cookingTime,
        'category': category,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'rating': 0.0,
        'rating_count': 0,
        'is_premium': false,
        'slug': _generateSlug(name),
      };

      // Insert recipe into database
      final response =
          await _supabaseService.client
              .from('recipes')
              .insert(recipeData)
              .select()
              .single();

      final recipeId = response['id'] as String;
      debugPrint('✅ Recipe created with ID: $recipeId');

      // Add ingredients
      if (ingredients.isNotEmpty) {
        final ingredientData =
            ingredients.asMap().entries.map((entry) {
              return {
                'recipe_id': recipeId,
                'name': entry.value,
                'order_index': entry.key,
              };
            }).toList();

        await _supabaseService.client
            .from('recipe_ingredients')
            .insert(ingredientData);

        debugPrint('✅ ${ingredients.length} ingredients added');
      }

      // Add instructions
      if (instructions.isNotEmpty) {
        final instructionData =
            instructions.asMap().entries.map((entry) {
              return {
                'recipe_id': recipeId,
                'step_number': entry.key + 1,
                'instruction': entry.value,
              };
            }).toList();

        await _supabaseService.client
            .from('recipe_instructions')
            .insert(instructionData);

        debugPrint('✅ ${instructions.length} instructions added');
      } // TODO: Handle image uploads to Supabase Storage
      // For now, we'll skip image handling as it requires additional setup

      debugPrint('🎉 Recipe "$name" created successfully!');

      // Refresh user recipes to include the new recipe
      await fetchUserRecipes();

      return recipeId;
    } catch (e) {
      _error = 'Failed to create recipe: ${e.toString()}';
      debugPrint('❌ Error creating recipe: $e');
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Generates a URL-friendly slug from recipe name
  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
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
  } // Get recipe categories from database

  Future<List<String>> getRecipeCategories() async {
    try {
      debugPrint('🔍 Fetching categories from recipe_categories table...');
      final response = await _supabaseService.client
          .from('recipe_categories')
          .select('name')
          .order('name');

      final categories =
          response
              .map<String>((category) => category['name'] as String)
              .toList();

      debugPrint('✅ Found ${categories.length} categories from database');
      debugPrint('📋 Categories: ${categories.join(', ')}');

      // Add "All" at the beginning only if not already present
      final result = ['All', ...categories];
      return result;
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
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

      debugPrint('🧪 Testing recipe ingredients connection...');

      for (final recipe in recipes) {
        final recipeId = recipe['id'];
        final recipeName = recipe['name'];

        debugPrint('📝 Recipe: $recipeName (ID: $recipeId)');

        final ingredients = await getRecipeIngredients(recipeId);

        if (ingredients.isNotEmpty) {
          debugPrint('✅ Found ${ingredients.length} ingredients:');
          for (final ingredient in ingredients) {
            debugPrint(
              '   - ${ingredient['name']} (${ingredient['quantity']} ${ingredient['unit']})',
            );
          }
        } else {
          debugPrint('❌ No ingredients found for this recipe');

          // Debug: cek apakah ada data di recipe_ingredients dengan recipe_id ini
          final debugCheck = await _supabaseService.client
              .from('recipe_ingredients')
              .select('ingredient_name, quantity, unit')
              .eq('recipe_id', recipeId);

          debugPrint(
            '   🔍 Direct check found ${debugCheck.length} ingredients',
          );
          for (final ing in debugCheck) {
            debugPrint(
              '   - ${ing['ingredient_name']} (${ing['quantity']} ${ing['unit']})',
            );
          }
        }
        debugPrint('');
      }
    } catch (e) {
      debugPrint('❌ Error testing recipe ingredients: $e');
    }
  } // Quick test untuk recipe tertentu yang ada di screenshot

  Future<void> testSpecificRecipe() async {
    try {
      // Test dengan recipe ID yang terlihat di screenshot: Soto Ayam Lamongan
      const String recipeId = 'a3cb8da7-8fb1-0a9b-f34e-7cbd3ba4e08d';

      debugPrint('🧪 Testing specific recipe: $recipeId');

      // Ambil data recipe
      final recipe =
          await _supabaseService.client
              .from('recipes')
              .select('id, name, slug')
              .eq('id', recipeId)
              .maybeSingle();

      if (recipe != null) {
        debugPrint('✅ Recipe found: ${recipe['name']}');

        // Ambil ingredients
        final ingredients = await _supabaseService.client
            .from('recipe_ingredients')
            .select('ingredient_name, quantity, unit')
            .eq('recipe_id', recipeId);

        debugPrint('✅ Found ${ingredients.length} ingredients:');
        for (final ingredient in ingredients) {
          debugPrint(
            '   - ${ingredient['ingredient_name']} (${ingredient['quantity']} ${ingredient['unit']})',
          );
        }

        // Ambil instructions
        final instructions = await _supabaseService.client
            .from('recipe_instructions')
            .select('step_number, instruction_text')
            .eq('recipe_id', recipeId)
            .order('step_number');

        debugPrint('✅ Found ${instructions.length} instructions:');
        for (final instruction in instructions) {
          debugPrint(
            '   ${instruction['step_number']}. ${instruction['instruction_text']}',
          );
        }

        // Ambil reviews
        final reviews = await getRecipeReviews(recipeId);
        debugPrint('✅ Found ${reviews.length} reviews:');
        for (final review in reviews.take(3)) {
          // Tampilkan 3 review pertama
          debugPrint(
            '   ⭐ ${review['rating']}/5 by ${review['user_name']}: ${review['comment']}',
          );
        }

        // Ambil review stats
        final stats = await getRecipeReviewStats(recipeId);
        debugPrint('📊 Review Stats:');
        debugPrint(
          '   Average: ${stats['average_rating']}/5 (${stats['total_reviews']} reviews)',
        );
        debugPrint('   Distribution: ${stats['rating_distribution']}');
      } else {
        debugPrint('❌ Recipe not found');
      }
    } catch (e) {
      debugPrint('❌ Error testing specific recipe: $e');
    }
  } // Test function untuk submit review (hanya untuk testing)

  Future<void> testSubmitReview() async {
    try {
      // Test dengan recipe ID yang ada di screenshot recipe_reviews
      const String recipeId = 'b4dc9eb8-9ac2-1bac-a45f-8dce4cb5f19e';

      debugPrint('🧪 Testing submit review for recipe: $recipeId');

      // Ambil reviews yang sudah ada dulu
      final existingReviews = await getRecipeReviews(recipeId);
      debugPrint('✅ Existing reviews count: ${existingReviews.length}');

      if (existingReviews.isNotEmpty) {
        debugPrint('📝 Sample existing reviews:');
        for (final review in existingReviews.take(3)) {
          debugPrint('   ⭐ ${review['rating']}/5: ${review['comment']}');
        }
      }

      // Test get review stats
      final stats = await getRecipeReviewStats(recipeId);
      debugPrint('📊 Review Stats:');
      debugPrint(
        '   Average: ${stats['average_rating']}/5 (${stats['total_reviews']} reviews)',
      );
      debugPrint('   Distribution: ${stats['rating_distribution']}');
    } catch (e) {
      debugPrint('❌ Error testing reviews: $e');
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

      debugPrint('🔍 Fetching user recipes for user: $userId');

      // Fetch recipes created by the user
      final response = await _supabaseService.client
          .from('recipes')
          .select('''
            *,
            recipe_ingredients(name, order_index),
            recipe_instructions(step_number, instruction),
            recipe_nutrition(calories, protein, carbs, fat),
            recipe_timers(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint(
        '📥 Raw user recipes response: ${response.length} recipes',
      ); // Convert to Recipe objects
      final List<Recipe> userRecipesList = [];
      for (final json in response) {
        try {
          final recipe = Recipe.fromJson(json);
          userRecipesList.add(recipe);
        } catch (e) {
          debugPrint('❌ Error parsing user recipe: $e');
          debugPrint('   Recipe data: $json');
        }
      }

      _userRecipes = userRecipesList;

      debugPrint('✅ Loaded ${_userRecipes.length} user recipes');
    } catch (e) {
      _setError('Failed to fetch user recipes: $e');
      debugPrint('❌ Error fetching user recipes: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Refreshes user recipes after creating a new one
  Future<void> refreshUserRecipes() async {
    await fetchUserRecipes();
  }
}
