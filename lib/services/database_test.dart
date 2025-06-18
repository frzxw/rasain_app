import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class DatabaseTest {
  static final SupabaseService _supabaseService = SupabaseService.instance;

  /// Test basic database connection
  static Future<bool> testConnection() async {
    try {
      debugPrint('🧪 Testing database connection...');

      // Test 1: Simple table existence check
      final response = await _supabaseService.client
          .from('recipes')
          .select('id')
          .limit(1);

      debugPrint('✅ Database connection successful');
      debugPrint('📊 Found ${response.length} recipes in database');

      return true;
    } catch (e) {
      debugPrint('❌ Database connection failed: $e');
      return false;
    }
  }

  /// Test recipes table specifically
  static Future<Map<String, dynamic>> testRecipesTable() async {
    try {
      debugPrint('🧪 Testing recipes table...');

      // Get total count
      final countResponse = await _supabaseService.client
          .from('recipes')
          .select('id');      // Get sample recipes
      final sampleResponse = await _supabaseService.client
          .from('recipes')
          .select('id, name, rating, image_url')
          .limit(5);

      final result = {
        'success': true,
        'total_recipes': countResponse.length,
        'sample_recipes': sampleResponse,
      };

      debugPrint('✅ Recipes table test successful');
      debugPrint('📊 Total recipes: ${result['total_recipes']}');
      debugPrint('📄 Sample recipes: ${sampleResponse.length}');

      return result;
    } catch (e) {
      debugPrint('❌ Recipes table test failed: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Test complete app data flow
  static Future<Map<String, dynamic>> testDataFlow() async {
    final results = <String, dynamic>{};

    try {
      debugPrint('🧪 Testing complete data flow...');

      // Test connection
      results['connection'] = await testConnection();

      // Test recipes table
      results['recipes'] = await testRecipesTable();

      // Test pantry table
      try {
        final pantryResponse = await _supabaseService.client
            .from('pantry_items')
            .select('id')
            .limit(1);
        results['pantry'] = {'success': true, 'count': pantryResponse.length};
        debugPrint('✅ Pantry table accessible');
      } catch (e) {
        results['pantry'] = {'success': false, 'error': e.toString()};
        debugPrint('❌ Pantry table error: $e');
      }

      // Test community table
      try {
        final communityResponse = await _supabaseService.client
            .from('community_posts')
            .select('id')
            .limit(1);
        results['community'] = {
          'success': true,
          'count': communityResponse.length,
        };
        debugPrint('✅ Community table accessible');
      } catch (e) {
        results['community'] = {'success': false, 'error': e.toString()};
        debugPrint('❌ Community table error: $e');
      }

      debugPrint('🎉 Data flow test completed');
      return results;
    } catch (e) {
      debugPrint('❌ Data flow test failed: $e');
      results['error'] = e.toString();
      return results;
    }
  }
}
