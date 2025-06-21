import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class QuickAddIngredients extends StatelessWidget {
  final Function(String, String) onQuickAdd;

  const QuickAddIngredients({
    super.key,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
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
            'Quick Add',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),
          
          // Categories with common ingredients
          _buildCategorySection(
            context,
            title: 'Vegetables',
            icon: Icons.eco,
            color: Colors.green,
            items: [
              'Bawang Merah', 'Bawang Putih', 'Tomat', 'Cabai Merah',
              'Wortel', 'Kentang', 'Bayam', 'Kangkung'
            ],
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          _buildCategorySection(
            context,
            title: 'Proteins',
            icon: Icons.egg,
            color: Colors.red,
            items: [
              'Daging Sapi', 'Daging Ayam', 'Telur', 'Ikan',
              'Tahu', 'Tempe', 'Udang', 'Ayam'
            ],
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          _buildCategorySection(
            context,
            title: 'Spices & Seasonings',
            icon: Icons.restaurant,
            color: Colors.purple,
            items: [
              'Garam', 'Lada', 'Kunyit', 'Jahe',
              'Lengkuas', 'Serai', 'Daun Salam', 'Kecap Manis'
            ],
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          _buildCategorySection(
            context,
            title: 'Staples',
            icon: Icons.grain,
            color: Colors.brown,
            items: [
              'Beras', 'Mi Instan', 'Tepung Terigu', 'Gula',
              'Minyak Goreng', 'Santan', 'Bawang Goreng', 'Kerupuk'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: AppSizes.marginS),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.marginS),
        Wrap(
          spacing: AppSizes.marginS,
          runSpacing: AppSizes.marginS,
          children: items.map((item) {
            return _buildQuickAddChip(item, _getCategoryFromTitle(title), color);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAddChip(String item, String category, Color color) {
    return InkWell(
      onTap: () => onQuickAdd(item, category),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryFromTitle(String title) {
    switch (title) {
      case 'Vegetables':
        return 'Vegetables';
      case 'Proteins':
        return 'Meat';
      case 'Spices & Seasonings':
        return 'Spices';
      case 'Staples':
        return 'Grains';
      default:
        return 'Other';
    }
  }
}
