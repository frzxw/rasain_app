import 'package:bloc/bloc.dart';
import '../../services/pantry_service.dart';
import '../../models/pantry_item.dart';
import 'pantry_state.dart';

class PantryCubit extends Cubit<PantryState> {
  final PantryService _pantryService;

  PantryCubit(this._pantryService) : super(const PantryState());

  // Initialize and fetch pantry data
  Future<void> initialize() async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      // Initialize the pantry service which loads items and tools
      await _pantryService.initialize();

      // Get pantry items from service
      final items = _pantryService.pantryItems;

      // Organize items by category
      final Map<String, List<PantryItem>> categorizedItems = {};
      for (var item in items) {
        final category = item.category ?? 'Uncategorized';
        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!.add(item);
      }

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          status: PantryStatus.loaded,
        ),
      );
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

      // Reorganize categorized items
      final Map<String, List<PantryItem>> categorizedItems = {};
      for (var item in items) {
        final category = item.category ?? 'Uncategorized';
        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!.add(item);
      }

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          status: PantryStatus.loaded,
        ),
      );
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

      // Reorganize categorized items
      final Map<String, List<PantryItem>> categorizedItems = {};
      for (var item in items) {
        final category = item.category ?? 'Uncategorized';
        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!.add(item);
      }

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          status: PantryStatus.loaded,
        ),
      );
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

      // Reorganize categorized items
      final Map<String, List<PantryItem>> categorizedItems = {};
      for (var item in items) {
        final category = item.category ?? 'Uncategorized';
        if (!categorizedItems.containsKey(category)) {
          categorizedItems[category] = [];
        }
        categorizedItems[category]!.add(item);
      }

      emit(
        state.copyWith(
          items: items,
          categorizedItems: categorizedItems,
          status: PantryStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Get suggested recipes based on pantry items
  Future<void> getSuggestedRecipes() async {
    emit(state.copyWith(status: PantryStatus.loading));
    try {
      await _pantryService.fetchSuggestedRecipes();

      // The recipes are stored in the service
      // We don't need to update them in the state
      emit(state.copyWith(status: PantryStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: PantryStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
