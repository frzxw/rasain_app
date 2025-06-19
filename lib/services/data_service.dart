import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/user_profile.dart';
import '../models/community_post.dart';
import 'supabase_service.dart';
import 'local_storage_service.dart';

/// Service to handle data operations with Supabase database
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;
  final LocalStorageService _localStorage = LocalStorageService.instance;

  // Cache for frequently accessed data
  List<String>? _cachedKitchenTools;
  List<String>? _cachedCommonIngredients;
  List<String>? _cachedVegetables;
  List<String>? _cachedFruits;
  List<String>? _cachedMeats;
  List<String>? _cachedDairy;
  List<String>? _cachedSpices;

  /// Get all recipes from Supabase
  Future<List<Recipe>> getRecipes() async {
    try {
      debugPrint(
        '🔍 DataService: Fetching all recipes...',
      ); // Fetch from the main recipes table
      final data = await _supabaseService.fetchAll('recipes');
      debugPrint(
        '✅ DataService: Fetched [32m${data.length}[0m recipes from database',
      );

      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      debugPrint(
        '🔄 DataService: Converted to ${recipes.length} Recipe objects',
      );

      return recipes;
    } catch (e) {
      debugPrint('❌ DataService: Error fetching recipes: $e');

      // Return empty list instead of crashing the app
      return [];
    }
  }

  /// Get popular recipes (rating >= 4.7)
  Future<List<Recipe>> getPopularRecipes() async {
    try {
      final response = await _supabaseService.client
          // Fetch from the main recipes table
          .from('recipes')
          .select()
          .gte('rating', 4.7)
          .order('rating', ascending: false);
      return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching popular recipes: $e');
      return [];
    }
  }

  /// Get saved recipes
  Future<List<Recipe>> getSavedRecipes() async {
    try {
      final response = await _supabaseService.client
          // Fetch from the main recipes table
          .from('recipes')
          .select()
          .eq('is_saved', true)
          .order('created_at', ascending: false);
      return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching saved recipes: $e');
      return [];
    }
  }

  /// Get recipe recommendations
  Future<List<Recipe>> getRecommendedRecipes() async {
    try {
      debugPrint(
        '🔍 DataService: Fetching recommended recipes from database...',
      );

      // Try multiple strategies for recommendations
      List<Recipe> recommendations = [];

      // Strategy 1: Get highly rated recipes from main recipes table
      final highRatedResponse = await _supabaseService.client
          .from('recipes')
          .select()
          .gte('rating', 4.0)
          .limit(10)
          .order('rating', ascending: false);

      final highRatedRecipes =
          highRatedResponse
              .map<Recipe>((json) => Recipe.fromJson(json))
              .toList();
      debugPrint(
        '✅ Found ${highRatedRecipes.length} high-rated recipes',
      ); // Strategy 2: Get recipes by category (skip if categories column has issues)
      List<Map<String, dynamic>> traditionalResponse = [];
      try {
        traditionalResponse = await _supabaseService.client
            .from('recipes')
            .select()
            .limit(5)
            .order('rating', ascending: false);
      } catch (e) {
        debugPrint('⚠️ Category search failed, using fallback: $e');
        traditionalResponse = [];
      }

      final traditionalRecipes =
          traditionalResponse
              .map<Recipe>((json) => Recipe.fromJson(json))
              .toList();
      debugPrint('✅ Found ${traditionalRecipes.length} traditional recipes');

      // Strategy 3: Get recently added recipes
      final recentResponse = await _supabaseService.client
          .from('recipes')
          .select()
          .limit(10)
          .order('created_at', ascending: false);

      final recentRecipes =
          recentResponse.map<Recipe>((json) => Recipe.fromJson(json)).toList();
      debugPrint('✅ Found ${recentRecipes.length} recent recipes');

      // Combine all strategies and pick diverse recommendations
      Set<String> addedIds = {};

      // Add high-rated recipes first
      for (var recipe in highRatedRecipes) {
        if (recommendations.length >= 5) break;
        if (!addedIds.contains(recipe.id)) {
          recommendations.add(recipe);
          addedIds.add(recipe.id);
        }
      }

      // Add traditional recipes
      for (var recipe in traditionalRecipes) {
        if (recommendations.length >= 5) break;
        if (!addedIds.contains(recipe.id)) {
          recommendations.add(recipe);
          addedIds.add(recipe.id);
        }
      }

      // Fill remaining slots with recent recipes
      for (var recipe in recentRecipes) {
        if (recommendations.length >= 5) break;
        if (!addedIds.contains(recipe.id)) {
          recommendations.add(recipe);
          addedIds.add(recipe.id);
        }
      }

      debugPrint(
        '🎯 DataService: Returning ${recommendations.length} recommended recipes',
      );
      return recommendations;
    } catch (e) {
      debugPrint('❌ DataService: Error fetching recommended recipes: $e');
      return [];
    }
  }

  /// Get pantry items from Supabase
  Future<List<PantryItem>> getPantryItems() async {
    try {
      // Get current user ID
      final userId = _supabaseService.client.auth.currentUser?.id;
      debugPrint('👤 DataService: Getting pantry items for user: $userId');

      if (userId == null) {
        debugPrint(
          '❌ DataService: User not authenticated, using local storage',
        );
        return await _localStorage.loadPantryItems();
      }

      final data = await _supabaseService.fetchWithFilter(
        'pantry_items',
        'user_id',
        userId,
      );
      debugPrint('📦 DataService: Found ${data.length} pantry items for user');

      final items = data.map((json) => PantryItem.fromJson(json)).toList();

      // Save to local storage as backup
      await _localStorage.savePantryItems(items);

      return items;
    } catch (e) {
      debugPrint(
        '❌ DataService: Error fetching pantry items from Supabase: $e',
      );
      debugPrint('🔄 DataService: Falling back to local storage');
      return await _localStorage.loadPantryItems();
    }
  }

  /// Add pantry item to Supabase
  Future<PantryItem?> addPantryItem(PantryItem item) async {
    try {
      debugPrint(
        '🔄 DataService: Adding pantry item to database: ${item.name}',
      );

      // Get current user ID
      final userId = _supabaseService.client.auth.currentUser?.id;
      debugPrint('DataService: Current user ID: $userId');

      if (userId == null) {
        debugPrint(
          '❌ DataService: User not authenticated, cannot add pantry item',
        );
        return null;
      }

      // Create item data with user_id
      final itemData = item.toJson();
      itemData['user_id'] = userId;

      debugPrint('📝 DataService: Item data: $itemData');

      final data = await _supabaseService.insert('pantry_items', itemData);
      debugPrint('✅ DataService: Successfully inserted item to database');
      debugPrint('📄 DataService: Response data: $data');

      return PantryItem.fromJson(data);
    } catch (e) {
      debugPrint('❌ DataService: Error adding pantry item: $e');
      return null;
    }
  }

  /// Update pantry item in Supabase
  Future<PantryItem?> updatePantryItem(PantryItem item) async {
    try {
      final data = await _supabaseService.update(
        'pantry_items',
        item.id,
        item.toJson(),
      );
      return PantryItem.fromJson(data);
    } catch (e) {
      debugPrint('Error updating pantry item: $e');
      return null;
    }
  }

  /// Delete pantry item from Supabase
  Future<bool> deletePantryItem(String id) async {
    try {
      await _supabaseService.delete('pantry_items', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting pantry item: $e');
      return false;
    }
  }

  /// Get kitchen tools from Supabase with caching
  Future<List<String>> getKitchenTools() async {
    if (_cachedKitchenTools != null) {
      return _cachedKitchenTools!;
    }

    try {
      final response = await _supabaseService.client
          .from('kitchen_tools')
          .select('name')
          .order('name');

      _cachedKitchenTools =
          response.map<String>((item) => item['name'] as String).toList();
      return _cachedKitchenTools!;
    } catch (e) {
      debugPrint('Error fetching kitchen tools: $e');
      // Return default kitchen tools if database fails
      _cachedKitchenTools = [
        'Wajan',
        'Panci',
        'Dandang',
        'Cobek & Ulekan',
        'Serok',
        'Sutil',
        'Pisau',
        'Talenan',
        'Rice Cooker',
        'Blender',
        'Kompor Gas',
        'Kukusan',
        'Parutan',
      ];
      return _cachedKitchenTools!;
    }
  }

  /// Get common ingredients from Supabase with caching
  Future<List<String>> getCommonIngredients() async {
    if (_cachedCommonIngredients != null) {
      return _cachedCommonIngredients!;
    }

    try {
      final response = await _supabaseService.client
          .from('common_ingredients')
          .select('name')
          .order('name');

      _cachedCommonIngredients =
          response.map<String>((item) => item['name'] as String).toList();
      return _cachedCommonIngredients!;
    } catch (e) {
      debugPrint('Error fetching common ingredients: $e');
      // Return default ingredients if database fails
      _cachedCommonIngredients = [
        'bawang merah',
        'bawang putih',
        'tomat',
        'cabai merah',
        'cabai rawit',
        'wortel',
        'kentang',
        'ketimun',
        'brokoli',
        'kembang kol',
        'bayam',
        'kangkung',
        'terong',
        'tauge',
        'jagung',
        'apel',
        'pisang',
        'jeruk',
        'stroberi',
        'mangga',
        'nanas',
        'daging sapi',
        'daging ayam',
        'telur',
        'ikan',
        'udang',
        'tempe',
        'tahu',
        'susu',
        'keju',
        'mentega',
        'beras',
        'tepung terigu',
        'minyak goreng',
        'garam',
        'gula pasir',
      ];
      return _cachedCommonIngredients!;
    }
  }

  /// Get ingredients by category with caching
  Future<List<String>> getIngredientsByCategory(String category) async {
    List<String>? cachedList;
    final lowerCaseCategory = category.toLowerCase();

    switch (lowerCaseCategory) {
      case 'vegetables':
        cachedList = _cachedVegetables;
        break;
      case 'fruits':
        cachedList = _cachedFruits;
        break;
      case 'meat':
        cachedList = _cachedMeats;
        break;
      case 'dairy':
        cachedList = _cachedDairy;
        break;
      case 'spices':
        cachedList = _cachedSpices;
        break;
      default:
        return [];
    }

    if (cachedList != null) {
      return cachedList;
    }

    try {
      final response = await _supabaseService.client
          .from('ingredient_categories')
          .select('name')
          .eq('category', lowerCaseCategory)
          .order('name');

      final result =
          response.map<String>((item) => item['name'] as String).toList();

      // Cache the result
      switch (lowerCaseCategory) {
        case 'vegetables':
          _cachedVegetables = result;
          break;
        case 'fruits':
          _cachedFruits = result;
          break;
        case 'meat':
          _cachedMeats = result;
          break;
        case 'dairy':
          _cachedDairy = result;
          break;
        case 'spices':
          _cachedSpices = result;
          break;
      }

      return result;
    } catch (e) {
      debugPrint('Error fetching $category ingredients: $e');
      return _getDefaultIngredientsByCategory(category);
    }
  }

  /// Get vegetables list
  Future<List<String>> getVegetablesList() async {
    return getIngredientsByCategory('vegetables');
  }

  /// Get fruits list
  Future<List<String>> getFruitsList() async {
    return getIngredientsByCategory('fruits');
  }

  /// Get meat list
  Future<List<String>> getMeatList() async {
    return getIngredientsByCategory('meat');
  }

  /// Get dairy list
  Future<List<String>> getDairyList() async {
    return getIngredientsByCategory('dairy');
  }

  /// Get spices list
  Future<List<String>> getSpicesList() async {
    return getIngredientsByCategory('spices');
  }

  /// Default ingredients by category (fallback)
  List<String> _getDefaultIngredientsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return [
          'bawang merah',
          'bawang putih',
          'tomat',
          'cabai merah',
          'cabai rawit',
          'wortel',
          'kentang',
          'ketimun',
          'brokoli',
          'kembang kol',
          'bayam',
          'kangkung',
          'terong',
          'tauge',
          'jagung',
        ];
      case 'fruits':
        return [
          'apel',
          'pisang',
          'jeruk',
          'stroberi',
          'mangga',
          'nanas',
          'semangka',
          'melon',
          'pepaya',
          'alpukat',
          'jambu biji',
        ];
      case 'meat':
        return [
          'daging sapi',
          'daging ayam',
          'daging kambing',
          'ikan',
          'udang',
          'cumi',
          'kepiting',
          'telur',
        ];
      case 'dairy':
        return ['susu', 'keju', 'mentega', 'yogurt', 'krim', 'es krim'];
      case 'spices':
        return [
          'lada',
          'garam',
          'ketumbar',
          'jintan',
          'pala',
          'kayu manis',
          'cengkeh',
          'kunyit',
          'jahe',
          'lengkuas',
          'daun salam',
        ];
      default:
        return [];
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedKitchenTools = null;
    _cachedCommonIngredients = null;
    _cachedVegetables = null;
    _cachedFruits = null;
    _cachedMeats = null;
    _cachedDairy = null;
    _cachedSpices = null;
  }

  /// Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('rating', ascending: false);
      return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      return [];
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await _supabaseService.fetchById('user_profiles', userId);
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get community posts
  Future<List<CommunityPost>> getCommunityPosts() async {
    try {
      debugPrint('🔍 Fetching community posts...');

      // Try JOIN first, fall back to basic query if relationship doesn't exist
      List<Map<String, dynamic>> response;
      try {
        response = await _supabaseService.client
            .from('community_posts')
            .select('''
              *,
              user_profiles(name, image_url)
            ''')
            .order('created_at', ascending: false);
      } catch (joinError) {
        debugPrint('⚠️ JOIN failed, using basic query: $joinError');

        // Fallback to basic query without JOIN
        response = await _supabaseService.client
            .from('community_posts')
            .select('*')
            .order('created_at', ascending: false);
      }

      debugPrint('✅ Fetched ${response.length} community posts');
      debugPrint(
        '🔍 First post data: ${response.isNotEmpty ? response.first : 'No posts'}',
      );

      return response.map<CommunityPost>((json) {
        debugPrint('📊 Processing post JSON: $json');

        // Extract user profile data if available from JOIN
        String userName = 'Unknown User';
        String? userImageUrl;

        if (json.containsKey('user_profiles') &&
            json['user_profiles'] != null) {
          final userProfile = json['user_profiles'];
          userName = userProfile['name'] ?? 'Unknown User';
          userImageUrl = userProfile['image_url'];
        } else if (json.containsKey('user_name') && json['user_name'] != null) {
          // Use direct columns if available
          userName = json['user_name'];
          userImageUrl = json['user_image_url'];
        }

        // Create a modified JSON with user name and image
        final modifiedJson = Map<String, dynamic>.from(json);
        modifiedJson['user_name'] = userName;
        modifiedJson['user_image_url'] = userImageUrl;

        return CommunityPost.fromJson(modifiedJson);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching community posts: $e');
      return [];
    }
  }

  /// Create a new community post
  Future<CommunityPost?> createCommunityPost({
    required String userId,
    required String userName,
    String? userImageUrl,
    required String content,
    String? imageUrl,
    String? category,
    List<String>? taggedIngredients,
  }) async {
    try {
      debugPrint('🔍 Creating community post for user: $userName');

      final postData = {
        'user_id': userId,
        'user_name': userName,
        'user_image_url': userImageUrl,
        'content': content,
        'image_url': imageUrl,
        'category': category,
        'tagged_ingredients': taggedIngredients,
        'like_count': 0,
        'comment_count': 0,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabaseService.client
              .from('community_posts')
              .insert(postData)
              .select()
              .single();

      debugPrint('✅ Created community post: ${response['id']}');
      return CommunityPost.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error creating community post: $e');
      return null;
    }
  }
}
