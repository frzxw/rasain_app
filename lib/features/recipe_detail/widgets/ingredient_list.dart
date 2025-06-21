import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/ingredient_tile.dart';
import '../../../models/pantry_item.dart';

class IngredientList extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;
  final int originalServings;
  final int currentServings;
  final Function(int)? onServingChanged;

  const IngredientList({
    super.key,
    required this.ingredients,
    this.originalServings = 1,
    this.currentServings = 1,
    this.onServingChanged,
  });

  // Helper method to calculate serving multiplier
  double get _servingMultiplier {
    if (originalServings <= 0) return 1.0;
    return currentServings / originalServings;
  }

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return _buildEmptyState(context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Serving control section
        if (onServingChanged != null)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            margin: const EdgeInsets.only(bottom: AppSizes.marginM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Porsi:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildServingButton(
                      context,
                      icon: Icons.remove,
                      onPressed:
                          currentServings > 1
                              ? () => onServingChanged!(currentServings - 1)
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$currentServings',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildServingButton(
                      context,
                      icon: Icons.add,
                      onPressed:
                          currentServings < 20
                              ? () => onServingChanged!(currentServings + 1)
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Ingredients Count
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: Text(
            '${ingredients.length} ingredients',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),

        // Total Estimated Cost
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: Row(
            children: [
              const SizedBox(width: 4),
              Text(
                'Total Estimasi : ${_calculateTotalCost()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),

        // Ingredients List
        ...ingredients.map(
          (ingredient) => _buildIngredientItem(context, ingredient),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(
    BuildContext context,
    Map<String, dynamic> ingredient,
  ) {
    // Convert ingredient map to PantryItem for the IngredientTile widget
    final pantryItem = PantryItem(
      id: ingredient['id'] ?? '',
      name: ingredient['name'] ?? 'Unknown',
      quantity: _calculateAdjustedQuantity(ingredient),
      imageUrl: ingredient['image_url'],
      price: _calculateAdjustedPrice(ingredient),
    );

    // Check if the ingredient is owned (in a real app, this would check against the user's pantry)
    final bool isOwned = ingredient['is_owned'] ?? false;

    return IngredientTile(
      ingredient: pantryItem,
      isOwned: isOwned,
      showPrice: true,
      onToggle: () {
        // In a real app, this would toggle the ingredient in the user's pantry
      },
    );
  }

  String _calculateAdjustedQuantity(Map<String, dynamic> ingredient) {
    final quantity = ingredient['quantity'];
    final unit = ingredient['unit'];

    if (quantity == null && unit == null) {
      return '';
    }

    String result = '';

    if (quantity != null) {
      // Apply serving multiplier to quantity
      double actualQuantity;
      if (quantity is num) {
        actualQuantity = quantity.toDouble() * _servingMultiplier;
      } else {
        // Try to parse string quantity
        actualQuantity =
            (double.tryParse(quantity.toString()) ?? 0.0) * _servingMultiplier;
      }

      // Format quantity with proper decimal places
      if (actualQuantity % 1 == 0) {
        result = actualQuantity.toInt().toString();
      } else {
        result = actualQuantity.toStringAsFixed(1);
      }
    }

    if (unit != null && unit.toString().isNotEmpty) {
      if (result.isNotEmpty) {
        result += ' ${unit.toString()}';
      } else {
        result = unit.toString();
      }
    }

    return result;
  }

  String _calculateAdjustedPrice(Map<String, dynamic> ingredient) {
    if (ingredient['price'] == null) return '';

    final priceString = ingredient['price'].toString();
    final numericPrice =
        double.tryParse(priceString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    // Apply serving multiplier to price
    final adjustedPrice = numericPrice * _servingMultiplier;

    return 'Rp ${adjustedPrice.toStringAsFixed(0)}';
  }

  String _calculateTotalCost() {
    double totalCost = 0.0;

    for (final ingredient in ingredients) {
      if (ingredient['price'] != null) {
        // Extract numeric value from price string (e.g., "$2.99" -> 2.99)
        final priceString = ingredient['price'].toString();
        final numericPrice =
            double.tryParse(
              priceString.replaceAll(
                RegExp(r'[^\d.]'),
                '',
              ), // Menghapus simbol selain angka dan titik
            ) ??
            0.0;

        // Apply serving multiplier to cost
        totalCost += numericPrice * _servingMultiplier;
      }
    }
    // Format sebagai Rupiah (rp) dengan 3 angka di belakang koma
    return 'Rp ${totalCost.toStringAsFixed(3)}';
  }

  Widget _buildServingButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: onPressed != null ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          onTap: onPressed,
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : AppColors.textSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_basket_outlined,
            size: AppSizes.iconL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'No ingredients listed',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'This recipe doesn\'t have any ingredients listed yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
