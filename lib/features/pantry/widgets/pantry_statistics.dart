import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/pantry_item.dart';

class PantryStatistics extends StatelessWidget {
  final List<PantryItem> items;
  final List<PantryItem> expiringItems;
  final List<PantryItem> lowStockItems;

  const PantryStatistics({
    super.key,
    required this.items,
    required this.expiringItems,
    required this.lowStockItems,
  });

  @override
  Widget build(BuildContext context) {
    final statistics = _calculateStatistics();

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
          Text(
            'Pantry Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Quick stats grid
          _buildQuickStatsGrid(context, statistics),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Category breakdown
          if (statistics['categoryBreakdown'].isNotEmpty) ...[
            Text(
              'By Category',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.marginS),
            _buildCategoryBreakdown(context, statistics['categoryBreakdown']),
            
            const SizedBox(height: AppSizes.marginM),
          ],
          
          // Storage location breakdown
          if (statistics['storageBreakdown'].isNotEmpty) ...[
            Text(
              'By Storage Location',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.marginS),
            _buildStorageBreakdown(context, statistics['storageBreakdown']),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(BuildContext context, Map<String, dynamic> statistics) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Total Items',
            value: '${statistics['totalItems']}',
            icon: Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.marginS),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Expiring Soon',
            value: '${statistics['expiringItems']}',
            icon: Icons.schedule,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: AppSizes.marginS),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Low Stock',
            value: '${statistics['lowStockItems']}',
            icon: Icons.inventory_outlined,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, Map<String, int> breakdown) {
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: AppSizes.marginS,
      runSpacing: AppSizes.marginS,
      children: sortedEntries.map((entry) {
        return _buildBreakdownChip(
          context,
          label: entry.key,
          count: entry.value,
          color: _getCategoryColor(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildStorageBreakdown(BuildContext context, Map<String, int> breakdown) {
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: AppSizes.marginS,
      runSpacing: AppSizes.marginS,
      children: sortedEntries.map((entry) {
        return _buildBreakdownChip(
          context,
          label: entry.key,
          count: entry.value,
          color: _getStorageColor(entry.key),
          icon: _getStorageIcon(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildBreakdownChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStatistics() {
    final totalItems = items.length;
    final expiringItemsCount = expiringItems.length;
    final lowStockItemsCount = lowStockItems.length;
    
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
      'expiringItems': expiringItemsCount,
      'lowStockItems': lowStockItemsCount,
      'categoryBreakdown': categoryBreakdown,
      'storageBreakdown': storageBreakdown,
    };
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
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
      case 'bakery':
        return Colors.amber;
      case 'canned':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  Color _getStorageColor(String location) {
    switch (location.toLowerCase()) {
      case 'refrigerator':
        return Colors.blue;
      case 'freezer':
        return Colors.lightBlue;
      case 'pantry':
        return Colors.brown;
      case 'spice rack':
        return Colors.purple;
      case 'counter':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
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
