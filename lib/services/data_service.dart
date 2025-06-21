import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/user_profile.dart';
import '../models/community_post.dart';
import '../models/post_comment.dart';
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
      
      // Try JOIN query first for better performance
      try {
        final response = await _supabaseService.client
            .from('community_posts')
            .select('''
              id,
              user_id,
              content,
              image_url,
              category,
              like_count,
              comment_count,
              created_at,
              updated_at,
              user_profiles!inner(
                name,
                image_url
              )
            ''')
            .order('created_at', ascending: false);

        debugPrint('📋 Community posts with JOIN response: $response');

        final posts = response.map<CommunityPost>((post) {
          final userProfile = post['user_profiles'];
          final userName = userProfile is List && userProfile.isNotEmpty 
              ? userProfile[0]['name']?.toString() ?? 'Community User'
              : userProfile is Map 
                  ? userProfile['name']?.toString() ?? 'Community User'
                  : 'Community User';
          
          final userImageUrl = userProfile is List && userProfile.isNotEmpty 
              ? userProfile[0]['image_url']?.toString()
              : userProfile is Map 
                  ? userProfile['image_url']?.toString()
                  : null;

          return CommunityPost(
            id: post['id']?.toString() ?? '',
            userId: post['user_id']?.toString() ?? '',
            userName: userName,
            userImageUrl: userImageUrl,
            timestamp: DateTime.parse(
              post['created_at'] ?? DateTime.now().toIso8601String(),
            ),
            content: post['content']?.toString(),
            imageUrl: post['image_url']?.toString(),
            category: post['category']?.toString(),
            likeCount: post['like_count']?.toInt() ?? 0,
            commentCount: post['comment_count']?.toInt() ?? 0,
            isLiked: false,
            taggedIngredients: null,
          );
        }).toList();

        debugPrint('🎯 Successfully fetched ${posts.length} posts with JOIN');
        return posts;
      } catch (joinError) {
        debugPrint('⚠️ JOIN query failed: $joinError');
        debugPrint('🔄 Falling back to manual method...');
      }
      
      // Fallback: manual method
      await debugUserAndPostData();
      
      // Use manual join instead of automatic join to avoid foreign key issues
      final response = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .order('created_at', ascending: false);

      debugPrint('📋 Raw community posts response: $response');
      debugPrint('✅ Fetched ${response.length} community posts');
      
      // Debug each post individually
      for (int i = 0; i < response.length; i++) {
        final post = response[i];
        debugPrint('📝 Post $i: id=${post['id']}, user_id=${post['user_id']}, content="${post['content']?.toString().substring(0, 20) ?? 'empty'}..."');
      }

      // Get user profiles for all user_ids in posts
      final userIds = response
          .map((post) => post['user_id']?.toString())
          .where((id) => id != null)
          .toSet()
          .cast<String>() // Ensure all IDs are non-null strings
          .toList();

      debugPrint('🔍 Extracted user IDs from posts: $userIds');Map<String, Map<String, dynamic>> userProfiles = {};
        if (userIds.isNotEmpty) {
        try {
          debugPrint('🔍 Fetching user profiles for IDs: $userIds');
          
          // First, let's check if user_profiles table has any data at all
          final allProfilesCheck = await _supabaseService.client
              .from('user_profiles')
              .select('id, name, image_url')
              .limit(10);
          debugPrint('📊 Sample user_profiles in database: $allProfilesCheck');
          debugPrint('📊 Total profiles found in sample: ${allProfilesCheck.length}');
          
          final profilesResponse = await _supabaseService.client
              .from('user_profiles')
              .select('id, name, image_url')
              .inFilter('id', userIds);
          
          debugPrint('👥 Raw user profiles response: $profilesResponse');
          
          for (final profile in profilesResponse) {
            userProfiles[profile['id']] = profile;
            debugPrint('✅ Mapped profile: ${profile['id']} -> ${profile['name']}');
          }
          debugPrint('👥 Fetched ${userProfiles.length} user profiles total');} catch (profileError) {
          debugPrint('⚠️ Warning: Could not fetch user profiles: $profileError');          // Create default profiles for unknown users
          for (final userId in userIds) {
            if (!userProfiles.containsKey(userId)) {
              userProfiles[userId] = {
                'id': userId,
                'name': 'User ${userId.length > 8 ? userId.substring(0, 8) : userId}', // Show first 8 chars of ID
                'image_url': null,
              };
            }
          }
          debugPrint('🔄 Created ${userProfiles.length} default user profiles');
        }
      } else {
        debugPrint('⚠️ No user IDs found to fetch profiles for');
      }      final posts = response.map<CommunityPost>((post) {
        final userId = post['user_id']?.toString() ?? '';
        final userProfile = userProfiles[userId];
        
        debugPrint('📝 Processing post: ${post['id']} by user: $userId');
        debugPrint('👤 User profile found: ${userProfile != null}');
        if (userProfile != null) {
          debugPrint('👤 User name: ${userProfile['name']}');
        } else {
          debugPrint('❌ No profile found for user: $userId');
          debugPrint('🔍 Available profile IDs: ${userProfiles.keys.toList()}');
        }

        return CommunityPost(
          id: post['id']?.toString() ?? '',
          userId: userId,
          userName: userProfile?['name']?.toString() ?? 'Anonymous User',
          userImageUrl: userProfile?['image_url']?.toString(),
          timestamp: DateTime.parse(
            post['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          content: post['content']?.toString(),
          imageUrl: post['image_url']?.toString(),
          category: post['category']?.toString(),
          likeCount: post['like_count']?.toInt() ?? 0,
          commentCount: post['comment_count']?.toInt() ?? 0,
          isLiked: false, // TODO: implement user like status check
          taggedIngredients: null, // TODO: implement if needed
        );
      }).toList();

      debugPrint('🎯 Successfully mapped ${posts.length} community posts with user data');
      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching community posts: $e');
      return [];
    }
  }

  /// Get community posts with improved user name resolution
  Future<List<CommunityPost>> getCommunityPostsImproved() async {
    try {
      debugPrint('🔍 Fetching community posts with improved method...');
      
      // Try JOIN query first for better performance
      try {
        final response = await _supabaseService.client
            .from('community_posts')
            .select('''
              id,
              user_id,
              content,
              image_url,
              category,
              like_count,
              comment_count,
              created_at,
              updated_at,
              user_profiles!inner(
                name,
                image_url
              )
            ''')
            .order('created_at', ascending: false);

        debugPrint('📋 Community posts with JOIN response: $response');

        final posts = response.map<CommunityPost>((post) {
          final userProfile = post['user_profiles'];
          final userName = userProfile is List && userProfile.isNotEmpty 
              ? userProfile[0]['name']?.toString() ?? 'Community User'
              : userProfile is Map 
                  ? userProfile['name']?.toString() ?? 'Community User'
                  : 'Community User';
          
          final userImageUrl = userProfile is List && userProfile.isNotEmpty 
              ? userProfile[0]['image_url']?.toString()
              : userProfile is Map 
                  ? userProfile['image_url']?.toString()
                  : null;

          debugPrint('📝 Processing post: ${post['id']} by user: $userName');

          return CommunityPost(
            id: post['id']?.toString() ?? '',
            userId: post['user_id']?.toString() ?? '',
            userName: userName,
            userImageUrl: userImageUrl,
            timestamp: DateTime.parse(
              post['created_at'] ?? DateTime.now().toIso8601String(),
            ),
            content: post['content']?.toString(),
            imageUrl: post['image_url']?.toString(),
            category: post['category']?.toString(),
            likeCount: post['like_count']?.toInt() ?? 0,
            commentCount: post['comment_count']?.toInt() ?? 0,
            isLiked: false,
            taggedIngredients: null,
          );
        }).toList();

        debugPrint('🎯 Successfully fetched ${posts.length} posts with JOIN');
        return posts;
      } catch (joinError) {
        debugPrint('⚠️ JOIN query failed: $joinError');
        debugPrint('🔄 Falling back to manual method...');
      }
      
      // Fallback: manual method
      final response = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .order('created_at', ascending: false);

      debugPrint('📋 Fallback: Raw community posts response: $response');

      // Get user profiles for all user_ids in posts
      final userIds = response
          .map((post) => post['user_id']?.toString())
          .where((id) => id != null)
          .toSet()
          .cast<String>()
          .toList();

      Map<String, Map<String, dynamic>> userProfiles = {};
      if (userIds.isNotEmpty) {
        try {
          final profilesResponse = await _supabaseService.client
              .from('user_profiles')
              .select('id, name, image_url')
              .inFilter('id', userIds);
          
          for (final profile in profilesResponse) {
            userProfiles[profile['id']] = profile;
          }
        } catch (profileError) {
          debugPrint('⚠️ Could not fetch user profiles: $profileError');
        }
      }

      // Create default profiles for missing users
      for (final userId in userIds) {
        if (!userProfiles.containsKey(userId)) {
          userProfiles[userId] = {
            'id': userId,
            'name': 'Community User',
            'image_url': null,
          };
        }
      }

      final posts = response.map<CommunityPost>((post) {
        final userId = post['user_id']?.toString() ?? '';
        final userProfile = userProfiles[userId];
        
        return CommunityPost(
          id: post['id']?.toString() ?? '',
          userId: userId,
          userName: userProfile?['name']?.toString() ?? 'Community User',
          userImageUrl: userProfile?['image_url']?.toString(),
          timestamp: DateTime.parse(
            post['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          content: post['content']?.toString(),
          imageUrl: post['image_url']?.toString(),
          category: post['category']?.toString(),
          likeCount: post['like_count']?.toInt() ?? 0,
          commentCount: post['comment_count']?.toInt() ?? 0,
          isLiked: false,
          taggedIngredients: null,
        );
      }).toList();

      debugPrint('🎯 Fallback: Successfully mapped ${posts.length} community posts');
      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching community posts: $e');
      return [];
    }
  }  /// Get community posts with user names (using direct join after RLS fix)
  Future<List<CommunityPost>> getCommunityPostsSecure() async {
    try {
      debugPrint('🔍 Fetching community posts with user names...');
      
      // Direct join with user_profiles - now possible after RLS fix
      final response = await _supabaseService.client
          .from('community_posts')
          .select('''
            id,
            user_id,
            content,
            image_url,
            category,
            like_count,
            comment_count,
            created_at,
            updated_at,
            user_profiles!inner(
              name,
              image_url
            )
          ''')
          .order('created_at', ascending: false);

      debugPrint('📋 Community posts response: ${response.length} posts found');

      final posts = response.map<CommunityPost>((post) {
        final userProfile = post['user_profiles'];
        final userName = userProfile is List && userProfile.isNotEmpty 
            ? userProfile[0]['name']?.toString() ?? 'Community User'
            : userProfile is Map 
                ? userProfile['name']?.toString() ?? 'Community User'
                : 'Community User';
        
        final userImageUrl = userProfile is List && userProfile.isNotEmpty 
            ? userProfile[0]['image_url']?.toString()
            : userProfile is Map 
                ? userProfile['image_url']?.toString()
                : null;

        return CommunityPost(
          id: post['id']?.toString() ?? '',
          userId: post['user_id']?.toString() ?? '',
          userName: userName,
          userImageUrl: userImageUrl,
          timestamp: DateTime.parse(
            post['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          content: post['content']?.toString(),
          imageUrl: post['image_url']?.toString(),
          category: post['category']?.toString(),
          likeCount: post['like_count']?.toInt() ?? 0,
          commentCount: post['comment_count']?.toInt() ?? 0,
          isLiked: false,
          taggedIngredients: null,
        );
      }).toList();

      debugPrint('✅ Successfully fetched ${posts.length} community posts with user names');
      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching community posts: $e');
      return [];
    }
  }

  /// Alternative method to get community posts using separate queries (more reliable)
  Future<List<CommunityPost>> getCommunityPostsAlternative() async {
    try {
      debugPrint('🔍 Fetching community posts using alternative method...');
      
      // First, get all community posts
      final postsResponse = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .order('created_at', ascending: false);

      debugPrint('📋 Found ${postsResponse.length} community posts');

      if (postsResponse.isEmpty) {
        debugPrint('ℹ️ No community posts found');
        return [];
      }

      // Get unique user IDs from posts
      final userIds = postsResponse          .map((post) => post['user_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>() // Cast to non-nullable String
          .toSet()
          .toList();

      debugPrint('👥 Need user data for ${userIds.length} unique users');

      // Get user profiles for these users - using individual requests
      List<Map<String, dynamic>> usersResponse = [];
      
      if (userIds.isNotEmpty) {
        for (final userId in userIds) {
          try {
            final userResponse = await _supabaseService.client
                .from('user_profiles')
                .select('id, name, image_url')
                .eq('id', userId);
            
            usersResponse.addAll(userResponse);
          } catch (e) {
            debugPrint('⚠️ Could not fetch user $userId: $e');
          }
        }
      }

      debugPrint('👤 Found ${usersResponse.length} user profiles');

      // Create a map of user ID to user data for quick lookup
      final userMap = <String, Map<String, dynamic>>{};
      for (final user in usersResponse) {
        if (user['id'] != null) {
          userMap[user['id'].toString()] = user;
        }
      }

      // Combine posts with user data
      final posts = postsResponse.map<CommunityPost>((post) {
        final userId = post['user_id']?.toString() ?? '';
        final userData = userMap[userId];
        
        return CommunityPost(
          id: post['id']?.toString() ?? '',
          userId: userId,
          userName: userData?['name']?.toString() ?? 'Community User',
          userImageUrl: userData?['image_url']?.toString(),
          timestamp: DateTime.parse(
            post['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          content: post['content']?.toString(),
          imageUrl: post['image_url']?.toString(),
          category: post['category']?.toString(),
          likeCount: post['like_count']?.toInt() ?? 0,
          commentCount: post['comment_count']?.toInt() ?? 0,
          isLiked: false,
          taggedIngredients: null,
        );
      }).toList();

      debugPrint('✅ Successfully fetched ${posts.length} community posts with user data');
      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching community posts (alternative): $e');
      return [];
    }
  }

  /// Debug method to check user_profiles and community_posts data
  Future<void> debugUserAndPostData() async {
    try {
      debugPrint('🔍 ====== DEBUGGING USER AND POST DATA ======');
      
      // Check all user_profiles
      final allProfiles = await _supabaseService.client
          .from('user_profiles')
          .select('*')
          .order('created_at', ascending: false);
      
      debugPrint('👥 Total user profiles in database: ${allProfiles.length}');
      for (int i = 0; i < allProfiles.length && i < 5; i++) {
        final profile = allProfiles[i];
        debugPrint('   Profile $i: id=${profile['id']}, name="${profile['name']}", email="${profile['email']}", created=${profile['created_at']}');
      }
      
      // Check all community_posts
      final allPosts = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .order('created_at', ascending: false);
      
      debugPrint('📋 Total community posts in database: ${allPosts.length}');
      for (int i = 0; i < allPosts.length && i < 5; i++) {
        final post = allPosts[i];
        debugPrint('   Post $i: id=${post['id']}, user_id=${post['user_id']}, content="${(post['content']?.toString() ?? '').length > 30 ? (post['content']?.toString().substring(0, 30) ?? '') + '...' : post['content']?.toString() ?? 'empty'}", created=${post['created_at']}');
      }
      
      // Check if user_ids in posts exist in user_profiles
      final postUserIds = allPosts
          .map((post) => post['user_id']?.toString())
          .where((id) => id != null)
          .toSet()
          .cast<String>()
          .toList();
      
      final profileUserIds = allProfiles
          .map((profile) => profile['id']?.toString())
          .where((id) => id != null)
          .toSet()
          .cast<String>()
          .toList();
      
      debugPrint('🔗 User IDs in posts: $postUserIds');
      debugPrint('🔗 User IDs in profiles: $profileUserIds');
      
      final missingProfiles = postUserIds.where((id) => !profileUserIds.contains(id)).toList();
      final orphanProfiles = profileUserIds.where((id) => !postUserIds.contains(id)).toList();
      
      if (missingProfiles.isNotEmpty) {
        debugPrint('❌ Posts with missing user profiles: $missingProfiles');
      } else {
        debugPrint('✅ All posts have corresponding user profiles');
      }
      
      if (orphanProfiles.isNotEmpty) {
        debugPrint('⚠️ User profiles without posts: $orphanProfiles');
      }
      
      // Check current user
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser != null) {
        debugPrint('👤 Current user: ${currentUser.id}, email: ${currentUser.email}');
        
        final currentUserProfile = await _supabaseService.client
            .from('user_profiles')
            .select('*')
            .eq('id', currentUser.id)
            .maybeSingle();
        
        if (currentUserProfile != null) {
          debugPrint('✅ Current user profile found: ${currentUserProfile['name']}');
        } else {
          debugPrint('❌ Current user profile NOT found in database!');
        }
      } else {
        debugPrint('⚠️ No current user logged in');
      }
      
      debugPrint('🔍 ====== END DEBUGGING ======');
    } catch (e) {
      debugPrint('❌ Error during debugging: $e');
    }
  }

  /// Create test data for debugging purposes
  Future<void> createTestDataIfNeeded() async {
    try {
      debugPrint('🧪 Checking if test data is needed...');
      
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('⚠️ No user logged in, cannot create test data');
        return;
      }
      
      // Check if current user has a profile
      final userProfile = await _supabaseService.client
          .from('user_profiles')
          .select('*')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      if (userProfile == null) {
        debugPrint('🧪 Creating test user profile for current user...');
        final profileData = {
          'id': currentUser.id,
          'name': currentUser.email?.split('@')[0] ?? 'Test User',
          'email': currentUser.email,
          'image_url': null,
          'saved_recipes_count': 0,
          'posts_count': 0,
          'is_notifications_enabled': true,
          'language': 'id',
          'is_dark_mode_enabled': false,
        };
        
        await _supabaseService.client
            .from('user_profiles')
            .insert(profileData);
        
        debugPrint('✅ Test user profile created');
      } else {
        debugPrint('✅ User profile already exists: ${userProfile['name']}');
      }
      
      // Check if there are any posts by current user
      final userPosts = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .eq('user_id', currentUser.id);
      
      if (userPosts.isEmpty) {
        debugPrint('🧪 Creating test community post...');
        final postData = {
          'user_id': currentUser.id,
          'content': 'Test post untuk debug - ${DateTime.now().toIso8601String()}',
          'image_url': null,
          'category': 'Test',
          'like_count': 0,
          'comment_count': 0,
          'is_featured': false,
        };
        
        await _supabaseService.client
            .from('community_posts')
            .insert(postData);
        
        debugPrint('✅ Test community post created');
      } else {
        debugPrint('✅ User already has ${userPosts.length} posts');
      }
      
    } catch (e) {      debugPrint('❌ Error creating test data: $e');
    }
  }

  // ===== COMMENT METHODS =====  /// Get comments for a specific post
  Future<List<PostComment>> getPostComments(String postId) async {
    try {
      debugPrint('🔍 Fetching comments for post: $postId');
      
      // First, check if the post exists
      final postCheck = await _supabaseService.client
          .from('community_posts')
          .select('id')
          .eq('id', postId)
          .maybeSingle();
      
      if (postCheck == null) {
        debugPrint('❌ Post not found: $postId');
        return [];
      }
      
      debugPrint('✅ Post exists, fetching comments...');
      
      // Simple query first without JOIN to test connectivity
      final response = await _supabaseService.client
          .from('post_comments')
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      debugPrint('📋 Comments query response: ${response.length} comments found');
      debugPrint('📋 Raw response data: $response');

      if (response.isEmpty) {
        debugPrint('📋 No comments found for post: $postId');
        return [];
      }

      // Get unique user IDs for fetching user profiles
      final userIds = response
          .map((comment) => comment['user_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      debugPrint('👤 Found ${userIds.length} unique user IDs: $userIds');

      // Fetch user profiles
      Map<String, Map<String, dynamic>> userMap = {};
      if (userIds.isNotEmpty) {
        try {
          final usersResponse = await _supabaseService.client
              .from('user_profiles')
              .select('id, name, image_url')
              .inFilter('id', userIds);

          debugPrint('👤 User profiles response: $usersResponse');

          for (final user in usersResponse) {
            if (user['id'] != null) {
              userMap[user['id'].toString()] = user;
            }
          }
          debugPrint('👤 Created user map with ${userMap.length} entries');
        } catch (userError) {
          debugPrint('⚠️ Error fetching user profiles: $userError');
          // Continue without user data
        }
      }

      // Parse comments
      final comments = response.map<PostComment>((comment) {
        final userId = comment['user_id']?.toString() ?? '';
        final userData = userMap[userId];
        
        debugPrint('📝 Parsing comment: ${comment['id']} by user $userId');
        
        return PostComment(
          id: comment['id']?.toString() ?? '',
          postId: comment['post_id']?.toString() ?? '',
          userId: userId,
          parentCommentId: comment['parent_comment_id']?.toString(),
          content: comment['content']?.toString() ?? '',
          likeCount: comment['like_count']?.toInt() ?? 0,
          createdAt: DateTime.parse(
            comment['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          updatedAt: DateTime.parse(
            comment['updated_at'] ?? DateTime.now().toIso8601String(),
          ),
          authorName: userData?['name']?.toString() ?? 'Unknown User',
          authorAvatar: userData?['image_url']?.toString(),
        );
      }).toList();

      debugPrint('✅ Successfully parsed ${comments.length} comments');
      return comments;
    } catch (e) {
      debugPrint('❌ Error fetching comments: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Error details: ${e.toString()}');
      return [];
    }
  }  /// Create a new comment for a post
  Future<bool> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      if (content.trim().isEmpty) {
        debugPrint('❌ Comment content is empty');
        return false;
      }

      debugPrint('💬 Creating comment for post: $postId');
      debugPrint('👤 User ID: ${currentUser.id}');
      debugPrint('📝 Comment content: ${content.substring(0, content.length.clamp(0, 50))}...');

      // First check if the post exists
      final postExists = await _supabaseService.client
          .from('community_posts')
          .select('id')
          .eq('id', postId)
          .maybeSingle();

      if (postExists == null) {
        debugPrint('❌ Post does not exist: $postId');
        return false;
      }

      debugPrint('✅ Post exists, creating comment...');

      final commentData = {
        'post_id': postId,
        'user_id': currentUser.id,
        'parent_comment_id': parentCommentId,
        'content': content.trim(),
        'like_count': 0,
      };

      debugPrint('📤 Comment data to insert: $commentData');

      final result = await _supabaseService.client
          .from('post_comments')
          .insert(commentData)
          .select()
          .single();

      debugPrint('✅ Comment insertion result: $result');

      // Database trigger will automatically update comment_count in community_posts table
      debugPrint('✅ Comment created successfully with ID: ${result['id']}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating comment: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      // Provide specific error information
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('23503')) {
        debugPrint('❌ Foreign key constraint violation - post or user not found');
      } else if (errorMessage.contains('23505')) {
        debugPrint('❌ Duplicate comment detected');
      } else if (errorMessage.contains('42501') || errorMessage.contains('permission')) {
        debugPrint('❌ Permission denied - check RLS policies');
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        debugPrint('❌ Network/connection error');
      }
      
      return false;
    }
  }

  /// Test database connection for comments
  Future<void> testCommentConnection() async {
    try {
      debugPrint('🧪 Testing comment database connection...');
      
      // Test 1: Check if post_comments table exists
      final tableTest = await _supabaseService.client
          .from('post_comments')
          .select('count')
          .limit(1);
      
      debugPrint('✅ post_comments table accessible: $tableTest');
      
      // Test 2: Check authentication
      final currentUser = _supabaseService.client.auth.currentUser;
      debugPrint('👤 Current user: ${currentUser?.id ?? 'Not authenticated'}');
      
      // Test 3: Check if we can read community_posts
      final postsTest = await _supabaseService.client
          .from('community_posts')
          .select('id')
          .limit(1);
      
      debugPrint('✅ community_posts table accessible: ${postsTest.length} posts found');
      
      // Test 4: Check user_profiles access
      if (currentUser != null) {
        final profileTest = await _supabaseService.client
            .from('user_profiles')
            .select('id, name')
            .eq('id', currentUser.id)
            .maybeSingle();
        
        debugPrint('✅ User profile: $profileTest');
      }
      
      debugPrint('🧪 Database connection test completed');
    } catch (e) {
      debugPrint('❌ Database connection test failed: $e');    }
  }

  /// Delete a comment (only by the author)
  Future<bool> deleteComment(String commentId) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // Get the comment to check ownership
      final commentResponse = await _supabaseService.client
          .from('post_comments')
          .select('user_id, post_id')
          .eq('id', commentId)
          .single();

      if (commentResponse['user_id'] != currentUser.id) {
        debugPrint('❌ User not authorized to delete this comment');
        return false;
      }

      // Delete the comment
      await _supabaseService.client
          .from('post_comments')
          .delete()
          .eq('id', commentId);

      // Database trigger will automatically update comment_count in community_posts table
      debugPrint('✅ Comment deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      return false;
    }
  }

  /// Like/unlike a comment
  Future<bool> toggleCommentLike(String commentId) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // For now, just increment/decrement the like count
      // In a real app, you'd want to track individual likes in a separate table
      final currentComment = await _supabaseService.client
          .from('post_comments')
          .select('like_count')
          .eq('id', commentId)
          .single();

      final currentLikes = currentComment['like_count'] as int? ?? 0;
      final newLikes = currentLikes + 1; // Simple increment for now

      await _supabaseService.client
          .from('post_comments')
          .update({'like_count': newLikes})
          .eq('id', commentId);

      debugPrint('✅ Comment like toggled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error toggling comment like: $e');
      return false;
    }
  }
}
