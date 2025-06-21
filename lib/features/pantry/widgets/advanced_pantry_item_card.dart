import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/pantry_item.dart';

class AdvancedPantryItemCard extends StatelessWidget {
  final PantryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onUse;
  final Function(int)? onQuantityChanged;

  const AdvancedPantryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onUse,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and actions
              Row(
                children: [
                  // Category indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color: _getCategoryColor(item.category).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.category ?? 'Other',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(item.category),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
              
              const SizedBox(height: AppSizes.marginS),
              
              // Item name
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: AppSizes.marginS),
              
              // Item details
              _buildItemDetails(context),
              
              // Expiration warning if applicable
              if (item.isExpiringSoon) _buildExpirationWarning(context),
              
              // Low stock warning if applicable
              if (item.isLowStock) _buildLowStockWarning(context),
              
              // Quantity controls if available
              if (item.totalQuantity != null) _buildQuantityControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onUse != null)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: onUse,
            tooltip: 'Use Item',
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(left: AppSizes.marginS),
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
            tooltip: 'Delete',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(left: AppSizes.marginS),
            color: AppColors.error,
          ),
      ],
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    return Wrap(
      spacing: AppSizes.marginM,
      runSpacing: AppSizes.marginS,
      children: [
        // Quantity
        if (item.quantity != null)
          _buildDetailChip(
            icon: Icons.inventory_2_outlined,
            label: item.quantity!,
            color: AppColors.primary,
          ),
          // Storage location
        if (item.storageLocation != null)
          _buildDetailChip(
            icon: _getStorageIcon(item.storageLocation!),
            label: item.storageLocation!,
            color: AppColors.primary.withOpacity(0.7),
          ),
        
        // Price
        if (item.price != null)
          _buildDetailChip(
            icon: Icons.attach_money,
            label: item.price!,
            color: AppColors.success,
          ),
          // Expiration date
        if (item.expirationDate != null)
          _buildDetailChip(
            icon: Icons.schedule,
            label: DateFormat('MMM dd').format(item.expirationDate!),
            color: item.isExpiringSoon ? Colors.orange : AppColors.textSecondary,
          ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationWarning(BuildContext context) {
    final daysLeft = item.expirationDate!.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.marginS),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: 4,
      ),      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            daysLeft == 0 
                ? 'Expires today' 
                : 'Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}',            style: TextStyle(
              fontSize: 11,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.marginS),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            'Low stock',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.marginM),
      child: Row(
        children: [
          Text(
            'Quantity: ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: item.totalQuantity! > 0 
                ? () => onQuantityChanged?.call(item.totalQuantity! - 1)
                : null,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: AppSizes.marginS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingS,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              '${item.totalQuantity}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSizes.marginS),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => onQuantityChanged?.call(item.totalQuantity! + 1),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'vegetables':
        return Colors.green;
      case 'fruits':
        return Colors.orange;
      case 'meat':
        return Colors.red;
      case 'dairy':
        return Colors.blue;
      case 'grains':
        return Colors.brown;
      case 'spices':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStorageIcon(String location) {
    switch (location.toLowerCase()) {
      case 'refrigerator':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.kitchen_outlined;
      case 'spice rack':
        return Icons.restaurant;
      case 'counter':
        return Icons.countertops;
      default:
        return Icons.storage;
    }
  }
}
