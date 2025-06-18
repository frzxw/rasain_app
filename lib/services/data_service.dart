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
      final data = await _supabaseService.fetchAll('recipes');
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      return [];
    }
  }

  /// Get popular recipes (rating >= 4.7)
  Future<List<Recipe>> getPopularRecipes() async {
    try {
      final response = await _supabaseService.client
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
      final response = await _supabaseService.client
          .from('recipes')
          .select()
          .or('rating.gte.4.5,categories.cs.["Tradisional"]')
          .limit(5)
          .order('rating', ascending: false);
      return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching recommended recipes: $e');
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
      debugPrint('� DataService: Current user ID: $userId');

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
      debugPrint('🔍 Fetching community posts from database...');

      // Pertama cek struktur table community_posts
      final checkResponse = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .limit(3);
      debugPrint('🔍 Sample data from community_posts: $checkResponse');

      final response = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .order('created_at', ascending: false);

      debugPrint('📋 Raw community posts response: $response');
      debugPrint('✅ Fetched ${response.length} community posts');

      final posts =
          response.map<CommunityPost>((post) {
            return CommunityPost(
              id: post['id']?.toString() ?? '',
              userId: post['user_id']?.toString() ?? '',
              userName:
                  'User', // Sementara pakai default, nanti join dengan user table
              userImageUrl: null,
              timestamp: DateTime.parse(
                post['created_at'] ?? DateTime.now().toIso8601String(),
              ),
              content: post['content']?.toString(),
              imageUrl: post['image_url']?.toString(),
              category: post['category']?.toString(),
              likeCount: 0, // TODO: implement likes count
              commentCount: 0, // TODO: implement comments count
              isLiked: false, // TODO: implement user like status
              taggedIngredients: null, // TODO: implement if needed
            );
          }).toList();

      debugPrint('📝 Mapped ${posts.length} community posts');
      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching community posts: $e');
      return [];
    }
  }
}
