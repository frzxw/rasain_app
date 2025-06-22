import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import '../../../models/pantry_item.dart';

class ShoppingListGenerator extends StatelessWidget {
  final Recipe recipe;
  final List<PantryItem> pantryItems;
  final Function(List<String>) onGenerateShoppingList;

  const ShoppingListGenerator({
    super.key,
    required this.recipe,
    required this.pantryItems,
    required this.onGenerateShoppingList,
  });

  @override
  Widget build(BuildContext context) {
    final missingIngredients = _getMissingIngredients();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSizes.marginS),
              Expanded(
                child: Text(
                  'Shopping List for ${recipe.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.marginM),

          if (missingIngredients.isEmpty)
            _buildAllIngredientsAvailable(context)
          else
            _buildMissingIngredientsList(context, missingIngredients),
        ],
      ),
    );
  }

  Widget _buildAllIngredientsAvailable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: AppSizes.marginS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All ingredients available!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'You have everything needed to cook this recipe.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingIngredientsList(BuildContext context, List<String> missingIngredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Missing ingredients (${missingIngredients.length}):',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),

        const SizedBox(height: AppSizes.marginS),

        // Missing ingredients list
        ...missingIngredients.map((ingredient) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSizes.marginS),
                Expanded(
                  child: Text(
                    ingredient,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSizes.marginM),

        // Generate shopping list button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => onGenerateShoppingList(missingIngredients),
            icon: const Icon(Icons.list_alt),
            label: const Text('Generate Shopping List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getMissingIngredients() {
    if (recipe.ingredients == null) return [];

    final pantryIngredientNames = pantryItems
        .map((item) => item.name.toLowerCase())
        .toList();

    final missingIngredients = <String>[];

    for (final ingredient in recipe.ingredients!) {
      final ingredientName = ingredient['name']?.toString() ?? '';
      final ingredientNameLower = ingredientName.toLowerCase();

      final isAvailable = pantryIngredientNames.any((pantryItem) =>
          ingredientNameLower.contains(pantryItem) ||
          pantryItem.contains(ingredientNameLower));

      if (!isAvailable) {
        missingIngredients.add(ingredientName);
      }
    }

    return missingIngredients;
  }
}
