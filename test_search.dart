import 'package:flutter/foundation.dart';
import 'lib/services/supabase_service.dart';

void main() async {
  print('🧪 Testing search functionality...');

  try {
    final supabase = SupabaseService.instance;

    // Test 1: Basic connection
    print('1. Testing basic connection...');
    final basicTest = await supabase.client
        .from('recipes')
        .select('id, name')
        .limit(3);
    print('✅ Found ${basicTest.length} recipes');

    // Test 2: Search functionality
    print('2. Testing search with "nasi"...');
    final searchResult = await supabase.client
        .from('recipes')
        .select('id, name, description, categories')
        .or(
          'name.ilike.%nasi%,description.ilike.%nasi%,categories.ilike.%nasi%',
        );
    print('✅ Search found ${searchResult.length} recipes');

    if (searchResult.isNotEmpty) {
      print('Sample results:');
      for (var recipe in searchResult.take(3)) {
        print('  - ${recipe['name']}: ${recipe['categories']}');
      }
    }

    // Test 3: Category filtering
    print('3. Testing category filter with "Makanan Utama"...');
    final categoryResult = await supabase.client
        .from('recipes')
        .select('id, name, categories')
        .ilike('categories', '%Makanan Utama%');
    print('✅ Category filter found ${categoryResult.length} recipes');

    if (categoryResult.isNotEmpty) {
      print('Sample category results:');
      for (var recipe in categoryResult.take(3)) {
        print('  - ${recipe['name']}: ${recipe['categories']}');
      }
    }

    // Test 4: Check available categories
    print('4. Getting all unique categories...');
    final allRecipes = await supabase.client
        .from('recipes')
        .select('categories');

    Set<String> uniqueCategories = {};
    for (var recipe in allRecipes) {
      if (recipe['categories'] != null) {
        String categories = recipe['categories'].toString();
        // Split by comma and clean
        List<String> catList =
            categories
                .split(',')
                .map((cat) => cat.trim())
                .where((cat) => cat.isNotEmpty)
                .toList();
        uniqueCategories.addAll(catList);
      }
    }

    print('✅ Found ${uniqueCategories.length} unique categories:');
    for (var cat in uniqueCategories.take(10)) {
      print('  - $cat');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
