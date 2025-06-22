import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

/// Service to handle data operations with Supabase database
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;

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
        throw Exception('User must be authenticated to access pantry items');
      }

      final data = await _supabaseService.fetchWithFilter(
        'pantry_items',
        'user_id',
        userId,
      );
      debugPrint('📦 DataService: Found ${data.length} pantry items for user');

      return data.map((json) => PantryItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ DataService: Error fetching pantry items from Supabase: $e');
      throw Exception('Failed to load pantry items. Please try again.');
    }
  }  /// Add pantry item to Supabase
  Future<PantryItem?> addPantryItem(PantryItem item) async {
    try {
      debugPrint('🔄 DataService: Adding pantry item to database: ${item.name}');
      
      // Get current user ID  
      final userId = _supabaseService.client.auth.currentUser?.id;
      debugPrint('🔍 DataService: Current user ID: ${userId ?? "null"}');
      
      if (userId == null) {
        debugPrint('❌ DataService: User not authenticated, cannot add pantry item');
        throw Exception('User must be authenticated to add pantry items');
      }

      // Check for duplicate items for this user (case-insensitive)
      try {
        final existingItems = await _supabaseService.client
            .from('pantry_items')
            .select('id, name')
            .eq('user_id', userId)
            .ilike('name', item.name.trim());
        
        if (existingItems.isNotEmpty) {
          debugPrint('⚠️ DataService: Item "${item.name}" already exists for user');
          throw Exception('Bahan "${item.name}" sudah ada di pantry Anda');
        }
      } catch (e) {
        if (e.toString().contains('already exists') || e.toString().contains('sudah ada')) {
          rethrow;
        }
        // If error checking duplicates, continue with insertion
        debugPrint('⚠️ DataService: Could not check for duplicates: $e');
      }      // Prepare item data for database insertion
      final itemData = item.toJson();
      
      // Ensure user_id is set
      itemData['user_id'] = userId;
      
      // Always remove the id field - let database generate UUID
      itemData.remove('id');
      
      // Ensure name is trimmed and not empty
      if (itemData['name'] == null || itemData['name'].toString().trim().isEmpty) {
        throw Exception('Pantry item name cannot be empty');
      }
      itemData['name'] = itemData['name'].toString().trim();
      
      // Handle schema cache issue by removing potentially problematic fields
      // and trying insertion with different field combinations
      final sanitizedData = _sanitizeJsonData(itemData);
      
      // Remove category field temporarily if it's null or causing cache issues
      final insertData = Map<String, dynamic>.from(sanitizedData);
      if (insertData['category'] == null) {
        insertData.remove('category');
      }      
      debugPrint('📝 DataService: Sanitized data for insertion: $insertData');

      // Double-check required fields are present
      if (!insertData.containsKey('user_id') || insertData['user_id'] == null) {
        throw Exception('user_id is required for pantry items');
      }
      if (!insertData.containsKey('name') || insertData['name'] == null || insertData['name'].toString().trim().isEmpty) {
        throw Exception('name is required for pantry items');
      }
      
      // Log the exact request we're about to make
      debugPrint('🚀 DataService: About to insert pantry item...');
      debugPrint('📊 DataService: Table: pantry_items');
      debugPrint('📊 DataService: Data keys: ${insertData.keys.toList()}');
      debugPrint('📊 DataService: Data values: ${insertData.values.toList()}');

      // Try insertion with retry logic for schema cache issues
      Map<String, dynamic> responseData;
      try {
        responseData = await _supabaseService.insert('pantry_items', insertData);      } catch (schemaError) {
        if (schemaError.toString().contains('PGRST204') || 
            schemaError.toString().contains('schema cache')) {
          debugPrint('⚠️ DataService: Schema cache error detected, trying stored function...');
          
          try {
            // Try using stored function as fallback
            final functionResult = await _addPantryItemUsingFunction(item, userId);
            if (functionResult != null) {
              debugPrint('✅ DataService: Successfully inserted item using stored function');
              return functionResult;
            }
          } catch (functionError) {
            debugPrint('❌ DataService: Stored function also failed: $functionError');
            // Continue with retry logic below
          }
          
          debugPrint('⚠️ DataService: Retrying with minimal fields...');
          
          // Retry with only essential fields
          final minimalData = <String, dynamic>{
            'user_id': insertData['user_id'],
            'name': insertData['name'],
          };
          
          // Add non-null optional fields one by one
          if (insertData['quantity'] != null && insertData['quantity'].toString().isNotEmpty) {
            minimalData['quantity'] = insertData['quantity'];
          }
          if (insertData['unit'] != null && insertData['unit'].toString().isNotEmpty) {
            minimalData['unit'] = insertData['unit'];
          }
          if (insertData['expiration_date'] != null) {
            minimalData['expiration_date'] = insertData['expiration_date'];
          }
          if (insertData['price'] != null && insertData['price'].toString().isNotEmpty) {
            minimalData['price'] = insertData['price'];
          }
          if (insertData['image_url'] != null && insertData['image_url'].toString().isNotEmpty) {
            minimalData['image_url'] = insertData['image_url'];
          }
          
          debugPrint('🔄 DataService: Retrying with minimal data: $minimalData');
          responseData = await _supabaseService.insert('pantry_items', minimalData);
          
          // If minimal insertion succeeds, try to update with remaining fields
          if (responseData['id'] != null) {
            try {
              final updateData = <String, dynamic>{};
              
              // Add remaining fields that weren't in minimal data
              if (sanitizedData['category'] != null && sanitizedData['category'].toString().isNotEmpty) {
                updateData['category'] = sanitizedData['category'];
              }
              if (sanitizedData['storage_location'] != null && sanitizedData['storage_location'].toString().isNotEmpty) {
                updateData['storage_location'] = sanitizedData['storage_location'];
              }
              if (sanitizedData['total_quantity'] != null) {
                updateData['total_quantity'] = sanitizedData['total_quantity'];
              }
              if (sanitizedData['low_stock_alert'] != null) {
                updateData['low_stock_alert'] = sanitizedData['low_stock_alert'];
              }
              if (sanitizedData['expiration_alert'] != null) {
                updateData['expiration_alert'] = sanitizedData['expiration_alert'];
              }
              if (sanitizedData['notes'] != null && sanitizedData['notes'].toString().isNotEmpty) {
                updateData['notes'] = sanitizedData['notes'];
              }
              if (sanitizedData['purchase_date'] != null) {
                updateData['purchase_date'] = sanitizedData['purchase_date'];
              }
              if (sanitizedData['last_used_date'] != null) {
                updateData['last_used_date'] = sanitizedData['last_used_date'];
              }
              
              if (updateData.isNotEmpty) {
                debugPrint('🔄 DataService: Updating item with additional fields: $updateData');
                responseData = await _supabaseService.update('pantry_items', responseData['id'], updateData);
              }
            } catch (updateError) {
              debugPrint('⚠️ DataService: Failed to update with additional fields: $updateError');
              // Don't fail the operation, just use the minimal data
            }
          }
        } else {
          rethrow;
        }
      }
      
      debugPrint('✅ DataService: Successfully inserted item to database');
      debugPrint('📄 DataService: Response data: $responseData');

      return PantryItem.fromJson(responseData);    } catch (e) {
      debugPrint('❌ DataService: Error adding pantry item: $e');
      
      // Provide more specific error messages
      if (e.toString().contains('PGRST204') || e.toString().contains('schema cache')) {
        throw Exception('Database sedang memperbarui skema. Silakan coba lagi dalam beberapa saat.');
      } else if (e.toString().contains('JWT') || e.toString().contains('authentication')) {
        throw Exception('Silakan login untuk menambahkan item ke pantry.');
      } else if (e.toString().contains('RLS') || e.toString().contains('permission')) {
        throw Exception('Anda hanya bisa menambahkan item ke pantry sendiri.');
      } else if (e.toString().contains('duplicate') || 
                 e.toString().contains('unique constraint') ||
                 e.toString().contains('duplicated') ||
                 e.toString().contains('Key (user_id, lower(name::text))')) {
        // Extract item name from error if possible
        String itemName = item.name;
        if (e.toString().contains('Key (user_id, lower(name::text))=')) {
          final regex = RegExp(r'lower\(name::text\)\)=\([^,]+,\s*([^)]+)\)');
          final match = regex.firstMatch(e.toString());
          if (match != null) {
            itemName = match.group(1) ?? item.name;
          }
        }
        throw Exception('Bahan "$itemName" sudah ada di pantry Anda');
      } else if (e.toString().contains('already exists') || e.toString().contains('sudah ada')) {
        rethrow; // Re-throw our custom duplicate message
      } else {
        throw Exception('Gagal menambahkan item ke pantry. Silakan coba lagi.');
      }
    }
  }  /// Update pantry item in Supabase
  Future<PantryItem?> updatePantryItem(PantryItem item) async {
    try {
      debugPrint('🔄 DataService: Updating pantry item: ${item.name}');
      
      // Get current user ID to ensure user can only update their own items
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ DataService: User not authenticated, cannot update pantry item');
        throw Exception('User must be authenticated to update pantry items');
      }

      // Prepare update data (exclude id and ensure user_id)
      final updateData = item.toJson();
      updateData['user_id'] = userId;
      updateData.remove('id'); // Don't update the ID
      
      // Sanitize data
      final sanitizedData = _sanitizeJsonData(updateData);
      debugPrint('📝 DataService: Update data: $sanitizedData');      final data = await _supabaseService.update(
        'pantry_items',
        item.id,
        sanitizedData,
      );
      
      debugPrint('✅ DataService: Successfully updated pantry item');
      
      return PantryItem.fromJson(data);
    } catch (e) {
      debugPrint('❌ DataService: Error updating pantry item: $e');
        // Try stored function if schema cache error
      if (e.toString().contains('PGRST204') || e.toString().contains('schema cache')) {
        try {
          debugPrint('⚠️ DataService: Schema cache error, trying stored function for update...');
          
          // Get userId again for the function call
          final currentUserId = _supabaseService.client.auth.currentUser?.id;
          if (currentUserId != null) {
            return await _updatePantryItemUsingFunction(item, currentUserId);
          } else {
            throw Exception('User authentication lost');
          }
        } catch (functionError) {
          debugPrint('❌ DataService: Stored function update also failed: $functionError');
          throw Exception('Database sedang memperbarui skema. Silakan coba lagi dalam beberapa saat.');
        }
      }
      
      if (e.toString().contains('JWT') || e.toString().contains('authentication')) {
        throw Exception('Authentication required. Please log in to update pantry items.');
      } else if (e.toString().contains('RLS') || e.toString().contains('permission')) {
        throw Exception('Permission denied. You can only update your own pantry items.');
      } else {
        throw Exception('Failed to update pantry item. Please try again.');
      }
    }
  }  /// Delete pantry item from Supabase
  Future<bool> deletePantryItem(String id) async {
    try {
      debugPrint('🔄 DataService: Deleting pantry item with ID: $id');
      
      // Get current user ID to ensure user can only delete their own items
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ DataService: User not authenticated, cannot delete pantry item');
        throw Exception('User must be authenticated to delete pantry items');
      }

      await _supabaseService.delete('pantry_items', id);
      debugPrint('✅ DataService: Successfully deleted pantry item');
      
      return true;
    } catch (e) {
      debugPrint('❌ DataService: Error deleting pantry item: $e');
      
      if (e.toString().contains('JWT') || e.toString().contains('authentication')) {
        throw Exception('Authentication required. Please log in to delete pantry items.');
      } else if (e.toString().contains('RLS') || e.toString().contains('permission')) {
        throw Exception('Permission denied. You can only delete your own pantry items.');
      } else {
        throw Exception('Failed to delete pantry item. Please try again.');
      }
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

  /// Add pantry item using stored function (fallback for schema cache issues)
  Future<PantryItem?> _addPantryItemUsingFunction(PantryItem item, String userId) async {
    try {
      debugPrint('🔄 DataService: Using stored function to add pantry item: ${item.name}');      // Call the stored function
      final response = await _supabaseService.client.rpc(
        'insert_pantry_item',
        params: {
          'p_user_id': userId,
          'p_name': item.name,
          'p_image_url': item.imageUrl,
          'p_quantity': item.quantity,
          'p_unit': item.unit,
          'p_price': item.price,
          'p_category': item.category,
          'p_storage_location': item.storageLocation,
          'p_total_quantity': item.totalQuantity,
          'p_expiration_date': item.expirationDate?.toIso8601String(),
          'p_purchase_date': item.purchaseDate?.toIso8601String(),
          'p_last_used_date': item.lastUsedDate?.toIso8601String(),
          'p_low_stock_alert': item.lowStockAlert ?? false,
          'p_expiration_alert': item.expirationAlert ?? true,
          'p_notes': item.notes,
        },
      );
      
      debugPrint('✅ DataService: Successfully added item using stored function');
      debugPrint('📄 DataService: Function response: $response');
      
      // The function returns JSON, parse it
      if (response is Map<String, dynamic>) {
        return PantryItem.fromJson(response);
      } else {
        throw Exception('Invalid response from stored function');
      }
    } catch (e) {
      debugPrint('❌ DataService: Error using stored function: $e');
      rethrow;
    }
  }

  /// Update pantry item using stored function (fallback for schema cache issues)
  Future<PantryItem?> _updatePantryItemUsingFunction(PantryItem item, String userId) async {
    try {
      debugPrint('🔄 DataService: Using stored function to update pantry item: ${item.name}');
        // Call the stored function
      final response = await _supabaseService.client.rpc(
        'update_pantry_item',
        params: {
          'p_item_id': item.id,
          'p_user_id': userId,
          'p_name': item.name,
          'p_image_url': item.imageUrl,
          'p_quantity': item.quantity,
          'p_unit': item.unit,
          'p_price': item.price,
          'p_category': item.category,
          'p_storage_location': item.storageLocation,
          'p_total_quantity': item.totalQuantity,
          'p_expiration_date': item.expirationDate?.toIso8601String(),
          'p_purchase_date': item.purchaseDate?.toIso8601String(),
          'p_last_used_date': item.lastUsedDate?.toIso8601String(),
          'p_low_stock_alert': item.lowStockAlert ?? false,
          'p_expiration_alert': item.expirationAlert ?? true,
          'p_notes': item.notes,
        },
      );
      
      debugPrint('✅ DataService: Successfully updated item using stored function');
      debugPrint('📄 DataService: Function response: $response');
      
      // The function returns JSON, parse it
      if (response is Map<String, dynamic>) {
        return PantryItem.fromJson(response);
      } else {
        throw Exception('Invalid response from stored function');
      }
    } catch (e) {
      debugPrint('❌ DataService: Error using stored function: $e');
      rethrow;
    }
  }

  // Helper method to sanitize text and prevent UTF-8 encoding issues
  Map<String, dynamic> _sanitizeJsonData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.value is String) {
        // Sanitize string values to ensure proper UTF-8 encoding
        final sanitizedValue = entry.value
            .replaceAll(RegExp(r'[^\u0000-\u007F\u0080-\uFFFF]'), '') // Remove invalid unicode
            .replaceAll(RegExp(r'[\uFFFD]'), '') // Remove replacement characters
            .trim();
        sanitized[entry.key] = sanitizedValue;
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }
}
