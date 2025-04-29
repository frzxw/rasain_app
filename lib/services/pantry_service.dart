import 'package:flutter/foundation.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import 'api_service.dart';

class PantryService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
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
    await Future.wait([
      fetchPantryItems(),
      fetchKitchenTools(),
    ]);
    await fetchSuggestedRecipes();
  }
  
  // Fetch pantry items from API
  Future<void> fetchPantryItems() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get('pantry/items');
      
      final items = (response['items'] as List)
          .map((item) => PantryItem.fromJson(item))
          .toList();
      
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
      final response = await _apiService.get('pantry/tools');
      
      final tools = (response['tools'] as List)
          .map((tool) => tool as String)
          .toList();
      
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
      final response = await _apiService.get(
        'recipes/suggestions',
        queryParams: {
          'pantry_items': _pantryItems.map((item) => item.id).join(','),
          'kitchen_tools': _kitchenTools.join(','),
        },
      );
      
      final recipes = (response['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
      
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
      final response = await _apiService.post(
        'pantry/items',
        body: item.toJson(),
      );
      
      final newItem = PantryItem.fromJson(response['item']);
      
      _pantryItems.add(newItem);
      notifyListeners();
      
      // Refresh suggested recipes
      await fetchSuggestedRecipes();
    } catch (e) {
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
      await _apiService.put(
        'pantry/items/${item.id}',
        body: item.toJson(),
      );
      
      final index = _pantryItems.indexWhere((i) => i.id == item.id);
      
      if (index != -1) {
        _pantryItems[index] = item;
        notifyListeners();
      }
      
      // Refresh suggested recipes
      await fetchSuggestedRecipes();
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
      await _apiService.delete('pantry/items/$itemId');
      
      _pantryItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
      
      // Refresh suggested recipes
      await fetchSuggestedRecipes();
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
      
      // Update kitchen tools on backend
      await _apiService.put(
        'pantry/tools',
        body: {'tools': _kitchenTools},
      );
      
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
  Future<void> addPantryItemFromImage(List<int> imageBytes, String fileName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.uploadFile(
        'pantry/detect',
        imageBytes,
        fileName,
        'image',
      );
      
      final detectedItems = (response['detected_items'] as List)
          .map((item) => PantryItem.fromJson(item))
          .toList();
      
      // Add each detected item to pantry
      for (final item in detectedItems) {
        _pantryItems.add(item);
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
