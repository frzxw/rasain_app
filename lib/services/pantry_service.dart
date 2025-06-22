import 'package:flutter/foundation.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import 'data_service.dart';
import 'notification_service.dart';

class PantryService extends ChangeNotifier {
  final DataService _dataService = DataService();
  final NotificationService _notificationService = NotificationService();

  List<PantryItem> _pantryItems = [];
  List<String> _kitchenTools = [];
  List<Recipe> _suggestedRecipes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PantryItem> get pantryItems => _pantryItems;
  List<String> get kitchenTools => _kitchenTools;
  List<Recipe> get suggestedRecipes => _suggestedRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load data
  Future<void> initialize() async {
    await Future.wait([fetchPantryItems(), fetchKitchenTools()]);
    await fetchSuggestedRecipes();
  }

  // Fetch pantry items from API
  Future<void> fetchPantryItems() async {
    _setLoading(true);
    _clearError();

    try {
      final items = await _dataService.getPantryItems();
      _pantryItems = items;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pantry items: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch kitchen tools from API
  Future<void> fetchKitchenTools() async {
    _setLoading(true);
    _clearError();

    try {
      final tools = await _dataService.getKitchenTools();
      _kitchenTools = tools;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load kitchen tools: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch suggested recipes based on pantry items and tools
  Future<void> fetchSuggestedRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      final recipes = await _dataService.getRecommendedRecipes();
      _suggestedRecipes = recipes;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load suggested recipes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new pantry item
  Future<void> addPantryItem(PantryItem item) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 PantryService: Adding pantry item: ${item.name}');
      final newItem = await _dataService.addPantryItem(item);

      if (newItem != null) {
        _pantryItems.add(newItem);
        debugPrint('✅ PantryService: Successfully added item: ${newItem.name}');
        debugPrint(
          '📊 PantryService: Total items in pantry: ${_pantryItems.length}',
        );
        notifyListeners();

        // Refresh suggested recipes
        await fetchSuggestedRecipes();

        // Trigger notification
        await _notificationService.notifyPantryItemAdded(newItem.name, itemId: newItem.id);
      } else {
        debugPrint('❌ PantryService: Failed to add item - newItem is null');
        _setError('Failed to add pantry item - response was null');
      }
    } catch (e) {
      debugPrint('❌ PantryService: Error adding pantry item: $e');
      _setError('Failed to add pantry item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update existing pantry item
  Future<void> updatePantryItem(PantryItem item) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedItem = await _dataService.updatePantryItem(item);

      if (updatedItem != null) {
        final index = _pantryItems.indexWhere((i) => i.id == item.id);

        if (index != -1) {
          _pantryItems[index] = updatedItem;
          notifyListeners();
        }

        // Refresh suggested recipes
        await fetchSuggestedRecipes();
      }
    } catch (e) {
      _setError('Failed to update pantry item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete pantry item
  Future<void> deletePantryItem(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _dataService.deletePantryItem(itemId);

      if (success) {
        // Get the item name before removing it
        final itemName = _pantryItems.firstWhere((item) => item.id == itemId).name;
        
        _pantryItems.removeWhere((item) => item.id == itemId);
        notifyListeners();

        // Refresh suggested recipes
        await fetchSuggestedRecipes();
        
        // Trigger notification
        await _notificationService.notifyPantryItemRemoved(itemName, itemId: itemId);
      } else {
        _setError('Failed to delete pantry item');
      }
    } catch (e) {
      _setError('Failed to delete pantry item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle kitchen tool (add or remove)
  Future<void> toggleKitchenTool(String tool, bool isSelected) async {
    _setLoading(true);
    _clearError();

    try {
      if (isSelected && !_kitchenTools.contains(tool)) {
        _kitchenTools.add(tool);
      } else if (!isSelected && _kitchenTools.contains(tool)) {
        _kitchenTools.remove(tool);
      }

      // For now, just update locally (in a real app, you'd save to Supabase)
      // await _supabaseService.updateUserKitchenTools(_kitchenTools);

      notifyListeners();

      // Refresh suggested recipes
      await fetchSuggestedRecipes();
    } catch (e) {
      _setError('Failed to update kitchen tools: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add pantry item from image (using AI)
  Future<void> addPantryItemFromImage(
    List<int> imageBytes,
    String fileName,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // For now, add a mock detected item (in a real app, this would use AI detection)
      final mockDetectedItem = PantryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Detected Item from Image',
        category: 'Other',
        quantity: '1',
        unit: 'piece',
      );

      final addedItem = await _dataService.addPantryItem(mockDetectedItem);

      if (addedItem != null) {
        _pantryItems.add(addedItem);
      }

      notifyListeners();

      // Refresh suggested recipes
      await fetchSuggestedRecipes();
    } catch (e) {
      _setError('Failed to detect items from image: $e');
    } finally {
      _setLoading(false);
    }
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
}
