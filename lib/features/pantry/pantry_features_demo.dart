// Demo script to showcase the enhanced pantry features

import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/sizes.dart';

class PantryFeaturesDemo extends StatelessWidget {
  const PantryFeaturesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry Features Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureCard(
              context,
              title: 'Enhanced Pantry Management',
              features: [
                '✅ Add pantry items manually or via camera scan',
                '✅ Advanced filtering by category, location, expiry, stock',
                '✅ Real-time expiration and low stock alerts',
                '✅ Quantity tracking and consumption management',
                '✅ Smart categorization and storage location tracking',
              ],
              icon: Icons.inventory_2,
              color: AppColors.primary,
            ),

            const SizedBox(height: AppSizes.marginL),

            _buildFeatureCard(
              context,
              title: 'Smart Recipe Recommendations',
              features: [
                '✅ Recipes based on available pantry ingredients',
                '✅ Ingredient match percentage calculation',
                '✅ Missing ingredients shopping list generation',
                '✅ Personalized recommendations',
                '✅ Integration with recipe database',
              ],
              icon: Icons.restaurant_menu,
              color: AppColors.success,
            ),

            const SizedBox(height: AppSizes.marginL),

            _buildFeatureCard(
              context,
              title: 'Analytics & Insights',
              features: [
                '✅ Pantry overview with statistics',
                '✅ Category and storage location breakdown',
                '✅ Usage tracking and trends',
                '✅ Smart insights and recommendations',
                '✅ Recipe cooking potential analysis',
              ],
              icon: Icons.analytics,
              color: Colors.purple,
            ),

            const SizedBox(height: AppSizes.marginL),

            _buildFeatureCard(
              context,
              title: 'Advanced Features',
              features: [
                '✅ Quick add common ingredients',
                '✅ Bulk operations (delete multiple items)',
                '✅ Search and advanced filtering',
                '✅ Camera-based ingredient detection',
                '✅ Shopping list generation from recipes',
              ],
              icon: Icons.auto_awesome,
              color: Colors.orange,
            ),

            const SizedBox(height: AppSizes.marginL),

            _buildImplementationStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required List<String> features,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSizes.marginS),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.marginM),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildImplementationStatus(BuildContext context) {
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
            '🚀 Implementation Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),
          
          _buildStatusItem('✅ Enhanced Pantry Cubit with advanced methods', true),
          _buildStatusItem('✅ Smart Recipe Recommendations widget', true),
          _buildStatusItem('✅ Advanced Pantry Item Card component', true),
          _buildStatusItem('✅ Search and Filter functionality', true),
          _buildStatusItem('✅ Pantry Statistics dashboard', true),
          _buildStatusItem('✅ Quick Add ingredients feature', true),
          _buildStatusItem('✅ Shopping List generator', true),
          _buildStatusItem('✅ Enhanced Pantry Screen with tabs', true),
          _buildStatusItem('✅ Integration with Recipe system', true),
          _buildStatusItem('✅ Comprehensive error handling', true),

          const SizedBox(height: AppSizes.marginM),

          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: AppSizes.marginS),
                Expanded(
                  child: Text(
                    'All pantry features have been successfully implemented!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String text, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: AppSizes.marginS),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                decoration: isCompleted ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
