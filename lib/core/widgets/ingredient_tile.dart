import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import '../theme/colors.dart';
import '../../models/pantry_item.dart';

class IngredientTile extends StatelessWidget {
  final PantryItem ingredient;
  final bool isOwned;
  final bool showPrice;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const IngredientTile({
    super.key,
    required this.ingredient,
    this.isOwned = false,
    this.showPrice = false,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.marginS),
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: isOwned ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isOwned ? AppColors.success.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Checkbox for owned/not-owned toggle
          if (onToggle != null)
            GestureDetector(
              onTap: onToggle,
              child: Container(
                margin: const EdgeInsets.only(right: AppSizes.marginS),
                width: AppSizes.iconM,
                height: AppSizes.iconM,
                decoration: BoxDecoration(
                  color: isOwned ? AppColors.success.withOpacity(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                  border: Border.all(
                    color: isOwned ? AppColors.success : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: isOwned
                    ? const Icon(
                        Icons.check,
                        size: AppSizes.iconS,
                        color: AppColors.success,
                      )
                    : null,
              ),
            ),
          
          // Ingredient Image (if available)
          if (ingredient.imageUrl != null)
            Container(
              width: AppSizes.thumbnailS,
              height: AppSizes.thumbnailS,
              margin: const EdgeInsets.only(right: AppSizes.marginS),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                image: DecorationImage(
                  image: NetworkImage(ingredient.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Ingredient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  ingredient.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isOwned ? null : TextDecoration.none,
                  ),
                ),
                
                // Quantity and Expiration Date
                if (ingredient.quantity != null || ingredient.expirationDate != null)
                  Text(
                    [
                      if (ingredient.quantity != null) ingredient.quantity,
                      if (ingredient.expirationDate != null)
                        'Exp: ${_formatDate(ingredient.expirationDate!)}',
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getExpirationColor(ingredient.expirationDate),
                    ),
                  ),
              ],
            ),
          ),
          
          // Price
          if (showPrice && ingredient.price != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingS),
              child: Text(
                '${ingredient.price}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          
          // Actions
          if (onEdit != null || onDelete != null)
            Row(
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: AppSizes.iconS,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: AppSizes.iconM,
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: AppSizes.marginS),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: AppSizes.iconS,
                      color: AppColors.error,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: AppSizes.iconM,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getExpirationColor(DateTime? expirationDate) {
    if (expirationDate == null) return AppColors.textSecondary;
    
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;
    
    if (difference < 0) {
      return AppColors.error;
    } else if (difference < 3) {
      return Colors.orange;
    } else {
      return AppColors.textSecondary;
    }
  }
}
