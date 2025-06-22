import 'package:equatable/equatable.dart';
import '../../models/pantry_item.dart';
import '../../models/recipe.dart';

enum PantryStatus { initial, loading, loaded, error }

class PantryState extends Equatable {
  final List<PantryItem> items;
  final Map<String, List<PantryItem>> categorizedItems;
  final List<Recipe> suggestedRecipes;
  final List<Recipe> pantryBasedRecipes;
  final List<PantryItem> expiringItems;
  final List<PantryItem> lowStockItems;
  final PantryStatus status;
  final String? errorMessage;
  final bool isLoadingRecipes;

  const PantryState({
    this.items = const [],
    this.categorizedItems = const {},
    this.suggestedRecipes = const [],
    this.pantryBasedRecipes = const [],
    this.expiringItems = const [],
    this.lowStockItems = const [],
    this.status = PantryStatus.initial,
    this.errorMessage,
    this.isLoadingRecipes = false,
  });
  PantryState copyWith({
    List<PantryItem>? items,
    Map<String, List<PantryItem>>? categorizedItems,
    List<Recipe>? suggestedRecipes,
    List<Recipe>? pantryBasedRecipes,
    List<PantryItem>? expiringItems,
    List<PantryItem>? lowStockItems,
    PantryStatus? status,
    String? errorMessage,
    bool? isLoadingRecipes,
  }) {
    return PantryState(
      items: items ?? this.items,
      categorizedItems: categorizedItems ?? this.categorizedItems,
      suggestedRecipes: suggestedRecipes ?? this.suggestedRecipes,
      pantryBasedRecipes: pantryBasedRecipes ?? this.pantryBasedRecipes,
      expiringItems: expiringItems ?? this.expiringItems,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingRecipes: isLoadingRecipes ?? this.isLoadingRecipes,
    );
  }

  @override
  List<Object?> get props => [
    items, 
    categorizedItems, 
    suggestedRecipes, 
    pantryBasedRecipes,
    expiringItems,
    lowStockItems,
    status, 
    errorMessage,
    isLoadingRecipes,
  ];
}
