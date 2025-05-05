import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/ingredient_tile.dart';
import '../../../models/pantry_item.dart';

class IngredientList extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;
  
  const IngredientList({
    super.key,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredients Count
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: Text(
            '${ingredients.length} ingredients',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
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
        ...ingredients.map((ingredient) => _buildIngredientItem(context, ingredient)),
      ],
    );
  }

  Widget _buildIngredientItem(BuildContext context, Map<String, dynamic> ingredient) {
    // Convert ingredient map to PantryItem for the IngredientTile widget
    final pantryItem = PantryItem(
      id: ingredient['id'] ?? '',
      name: ingredient['name'] ?? 'Unknown',
      quantity: ingredient['quantity'],
      imageUrl: ingredient['image_url'],
      price: ingredient['price'],
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

String _calculateTotalCost() {
  double totalCost = 0.0;
  
  for (final ingredient in ingredients) {
    if (ingredient['price'] != null) {
      // Extract numeric value from price string (e.g., "$2.99" -> 2.99)
      final priceString = ingredient['price'].toString();
      final numericPrice = double.tryParse(
        priceString.replaceAll(RegExp(r'[^\d.]'), '') // Menghapus simbol selain angka dan titik
      ) ?? 0.0;
      
      totalCost += numericPrice;
    }
  }
  
  // Format sebagai Rupiah (rp) dengan 3 angka di belakang koma
  return 'Rp ${totalCost.toStringAsFixed(3)}';
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'This recipe doesn\'t have any ingredients listed yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
