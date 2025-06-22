import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../services/pantry_service.dart';
import '../../services/recipe_service.dart';
import '../../models/pantry_item.dart';
import 'pantry_state.dart';

class PantryCubit extends Cubit<PantryState> {
  final PantryService _pantryService;
  final RecipeService _recipeService;

  PantryCubit(this._pantryService, this._recipeService) : super(const PantryState());
  // Initialize and fetch pantry data
  Future<void> initialize() async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      // Initialize the pantry service which loads items and tools
      await _pantryService.initialize();

      // Get pantry items from service
      final items = _pantryService.pantryItems;

      // Organize items by category
      final categorizedItems = _organizePantryItems(items);

      // Get expiring and low stock items
      final expiringItems = _getExpiringItems(items);
      final lowStockItems = _getLowStockItems(items);

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          expiringItems: expiringItems,
          lowStockItems: lowStockItems,
          status: PantryStatus.loaded,
        ),
      );

      // Fetch pantry-based recipe recommendations
      await _fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }
  // Add new pantry item
  Future<void> addPantryItem(PantryItem item) async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      await _pantryService.addPantryItem(item);

      // Refresh state with updated data
      final items = _pantryService.pantryItems;
      final categorizedItems = _organizePantryItems(items);
      final expiringItems = _getExpiringItems(items);
      final lowStockItems = _getLowStockItems(items);

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          expiringItems: expiringItems,
          lowStockItems: lowStockItems,
          status: PantryStatus.loaded,
        ),
      );

      // Refresh recipe recommendations
      await _fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }
  // Update existing pantry item
  Future<void> updatePantryItem(PantryItem item) async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      await _pantryService.updatePantryItem(item);

      // Refresh state with updated data
      final items = _pantryService.pantryItems;
      final categorizedItems = _organizePantryItems(items);
      final expiringItems = _getExpiringItems(items);
      final lowStockItems = _getLowStockItems(items);

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          expiringItems: expiringItems,
          lowStockItems: lowStockItems,
          status: PantryStatus.loaded,
        ),
      );

      // Refresh recipe recommendations
      await _fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Delete pantry item
  Future<void> deletePantryItem(String itemId) async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      await _pantryService.deletePantryItem(itemId);

      // Refresh state with updated data
      final items = _pantryService.pantryItems;
      final categorizedItems = _organizePantryItems(items);
      final expiringItems = _getExpiringItems(items);
      final lowStockItems = _getLowStockItems(items);

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          expiringItems: expiringItems,
          lowStockItems: lowStockItems,
          status: PantryStatus.loaded,
        ),
      );

      // Refresh recipe recommendations
      await _fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Get suggested recipes based on pantry items
  Future<void> getSuggestedRecipes() async {
    await _fetchPantryBasedRecipes();
  }

  // Add pantry item from image detection
  Future<void> addPantryItemFromImage(List<int> imageBytes, String fileName) async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      await _pantryService.addPantryItemFromImage(imageBytes, fileName);

      // Refresh state with updated data
      final items = _pantryService.pantryItems;
      final categorizedItems = _organizePantryItems(items);
      final expiringItems = _getExpiringItems(items);
      final lowStockItems = _getLowStockItems(items);

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          expiringItems: expiringItems,
          lowStockItems: lowStockItems,
          status: PantryStatus.loaded,
        ),
      );

      // Refresh recipe recommendations
      await _fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Bulk operations
  Future<void> bulkDeleteItems(List<String> itemIds) async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      for (final itemId in itemIds) {
        await _pantryService.deletePantryItem(itemId);
      }

      // Refresh state with updated data
      final items = _pantryService.pantryItems;
      final categorizedItems = _organizePantryItems(items);
      final expiringItems = _getExpiringItems(items);
      final lowStockItems = _getLowStockItems(items);

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          expiringItems: expiringItems,
          lowStockItems: lowStockItems,
          status: PantryStatus.loaded,
        ),
      );

      // Refresh recipe recommendations
      await _fetchPantryBasedRecipes();
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Search pantry items by name or category
  List<PantryItem> searchPantryItems(String query) {
    if (query.isEmpty) return state.items;
    
    final lowercaseQuery = query.toLowerCase();
    return state.items.where((item) {
      final nameMatch = item.name.toLowerCase().contains(lowercaseQuery);
      final categoryMatch = item.category?.toLowerCase().contains(lowercaseQuery) ?? false;
      return nameMatch || categoryMatch;
    }).toList();
  }

  // Get items by storage location
  List<PantryItem> getItemsByStorageLocation(String location) {
    return state.items.where((item) => item.storageLocation == location).toList();
  }

  // Get items by category
  List<PantryItem> getItemsByCategory(String category) {
    return state.categorizedItems[category] ?? [];
  }

  // Mark item as used (update last used date)
  Future<void> markItemAsUsed(String itemId) async {
    try {
      final item = state.items.firstWhere((item) => item.id == itemId);
      final updatedItem = item.copyWith(lastUsedDate: DateTime.now());
      await updatePantryItem(updatedItem);
    } catch (e) {
      emit(state.copyWith(
        status: PantryStatus.error,
        errorMessage: 'Failed to mark item as used: $e',
      ));
    }
  }

  // Update item quantity (for consumption tracking)
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      final item = state.items.firstWhere((item) => item.id == itemId);
      final updatedItem = item.copyWith(
        totalQuantity: newQuantity,
        lastUsedDate: DateTime.now(),
      );
      await updatePantryItem(updatedItem);
    } catch (e) {
      emit(state.copyWith(
        status: PantryStatus.error,
        errorMessage: 'Failed to update item quantity: $e',
      ));
    }
  }

  // Quick add common ingredients
  Future<void> quickAddIngredient(String ingredientName, {String? category}) async {
    final item = PantryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: ingredientName,
      category: category ?? 'Other',
      quantity: '1',
      unit: 'piece',
      totalQuantity: 1,
      purchaseDate: DateTime.now(),
      lowStockAlert: false,
      expirationAlert: true,
    );
    
    await addPantryItem(item);
  }

  // Get statistics about pantry
  Map<String, dynamic> getPantryStatistics() {
    final items = state.items;
    final totalItems = items.length;
    final expiringItems = state.expiringItems.length;
    final lowStockItems = state.lowStockItems.length;
    
    // Categories breakdown
    final categoryBreakdown = <String, int>{};
    for (final item in items) {
      final category = item.category ?? 'Uncategorized';
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + 1;
    }
    
    // Storage location breakdown
    final storageBreakdown = <String, int>{};
    for (final item in items) {
      final location = item.storageLocation ?? 'Unknown';
      storageBreakdown[location] = (storageBreakdown[location] ?? 0) + 1;
    }

    return {
      'totalItems': totalItems,
      'expiringItems': expiringItems,
      'lowStockItems': lowStockItems,
      'categoryBreakdown': categoryBreakdown,
      'storageBreakdown': storageBreakdown,
    };
  }

  // Helper methods
  Map<String, List<PantryItem>> _organizePantryItems(List<PantryItem> items) {
    final Map<String, List<PantryItem>> categorizedItems = {};
    for (var item in items) {
      final category = item.category ?? 'Uncategorized';
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }
    return categorizedItems;
  }

  List<PantryItem> _getExpiringItems(List<PantryItem> items) {
    final now = DateTime.now();
    return items.where((item) {
      if (item.expirationDate == null) return false;
      final daysDiff = item.expirationDate!.difference(now).inDays;
      return daysDiff >= 0 && daysDiff <= 3; // Items expiring within 3 days
    }).toList();
  }

  List<PantryItem> _getLowStockItems(List<PantryItem> items) {
    return items.where((item) {
      if (item.totalQuantity == null) return false;
      return item.totalQuantity! <= 1; // Items with quantity <= 1
    }).toList();
  }

  Future<void> _fetchPantryBasedRecipes() async {
    if (state.items.isEmpty) {
      emit(state.copyWith(
        pantryBasedRecipes: [],
        suggestedRecipes: [],
        isLoadingRecipes: false,
      ));
      return;
    }

    emit(state.copyWith(isLoadingRecipes: true));
    try {
      // Fetch pantry-based recipes from recipe service
      await _recipeService.fetchPantryRecipes();
      final pantryRecipes = _recipeService.pantryRecipes;

      // Also get general suggested recipes
      final suggestedRecipes = _pantryService.suggestedRecipes;

      emit(state.copyWith(
        pantryBasedRecipes: pantryRecipes,
        suggestedRecipes: suggestedRecipes,
        isLoadingRecipes: false,
      ));
    } catch (e) {
      debugPrint('Error fetching pantry-based recipes: $e');
      emit(state.copyWith(isLoadingRecipes: false));
    }
  }
}
