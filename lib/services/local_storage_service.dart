import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/pantry_item.dart';

class LocalStorageService {
  static const String _pantryItemsKey = 'pantry_items';
  static const String _kitchenToolsKey = 'kitchen_tools';

  // Singleton pattern
  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  LocalStorageService._();

  // Save pantry items to local storage
  Future<void> savePantryItems(List<PantryItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_pantryItemsKey, jsonString);
      debugPrint('✅ LocalStorage: Saved ${items.length} pantry items');
    } catch (e) {
      debugPrint('❌ LocalStorage: Error saving pantry items: $e');
    }
  }

  // Load pantry items from local storage
  Future<List<PantryItem>> loadPantryItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pantryItemsKey);

      if (jsonString == null) {
        debugPrint('💾 LocalStorage: No pantry items found in local storage');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final items =
          jsonList
              .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
              .toList();
      debugPrint('📦 LocalStorage: Loaded ${items.length} pantry items');
      return items;
    } catch (e) {
      debugPrint('❌ LocalStorage: Error loading pantry items: $e');
      return [];
    }
  }

  // Add a single pantry item
  Future<PantryItem?> addPantryItem(PantryItem item) async {
    try {
      final items = await loadPantryItems();

      // Create new item with unique ID if not provided
      final newItem = item.copyWith(
        id:
            item.id.isEmpty
                ? DateTime.now().millisecondsSinceEpoch.toString()
                : item.id,
      );

      items.add(newItem);
      await savePantryItems(items);

      debugPrint('✅ LocalStorage: Added pantry item: ${newItem.name}');
      return newItem;
    } catch (e) {
      debugPrint('❌ LocalStorage: Error adding pantry item: $e');
      return null;
    }
  }

  // Update a pantry item
  Future<PantryItem?> updatePantryItem(PantryItem item) async {
    try {
      final items = await loadPantryItems();
      final index = items.indexWhere((i) => i.id == item.id);

      if (index == -1) {
        debugPrint('❌ LocalStorage: Item not found for update: ${item.id}');
        return null;
      }

      items[index] = item;
      await savePantryItems(items);

      debugPrint('✅ LocalStorage: Updated pantry item: ${item.name}');
      return item;
    } catch (e) {
      debugPrint('❌ LocalStorage: Error updating pantry item: $e');
      return null;
    }
  }

  // Delete a pantry item
  Future<bool> deletePantryItem(String itemId) async {
    try {
      final items = await loadPantryItems();
      final initialLength = items.length;

      items.removeWhere((item) => item.id == itemId);

      if (items.length == initialLength) {
        debugPrint('❌ LocalStorage: Item not found for deletion: $itemId');
        return false;
      }

      await savePantryItems(items);
      debugPrint('✅ LocalStorage: Deleted pantry item: $itemId');
      return true;
    } catch (e) {
      debugPrint('❌ LocalStorage: Error deleting pantry item: $e');
      return false;
    }
  }

  // Save kitchen tools
  Future<void> saveKitchenTools(List<String> tools) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kitchenToolsKey, tools);
      debugPrint('✅ LocalStorage: Saved ${tools.length} kitchen tools');
    } catch (e) {
      debugPrint('❌ LocalStorage: Error saving kitchen tools: $e');
    }
  }

  // Load kitchen tools
  Future<List<String>> loadKitchenTools() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tools = prefs.getStringList(_kitchenToolsKey) ?? [];
      debugPrint('🔧 LocalStorage: Loaded ${tools.length} kitchen tools');
      return tools;
    } catch (e) {
      debugPrint('❌ LocalStorage: Error loading kitchen tools: $e');
      return [];
    }
  }

  // Clear all local data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pantryItemsKey);
      await prefs.remove(_kitchenToolsKey);
      debugPrint('✅ LocalStorage: Cleared all pantry data');
    } catch (e) {
      debugPrint('❌ LocalStorage: Error clearing data: $e');
    }
  }
}
