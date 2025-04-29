import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';

class PantrySuggestions extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  
  const PantrySuggestions({
    Key? key,
    required this.recipes,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }
    
    if (recipes.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildSuggestionItem(context, recipe);
      },
    );
  }
  
  Widget _buildSuggestionItem(BuildContext context, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail
          GoRouter.of(context).push('/recipe/${recipe.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                child: Container(
                  width: 100,
                  height: 100,
                  color: AppColors.surface,
                  child: recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            color: AppColors.textSecondary,
                            size: AppSizes.iconL,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppColors.textSecondary,
                          size: AppSizes.iconL,
                        ),
                ),
              ),
              
              const SizedBox(width: AppSizes.marginM),
              
              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppSizes.marginS),
                    
                    // Estimated Cost
                    if (recipe.estimatedCost != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: AppSizes.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Est. Total: ${recipe.estimatedCost}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: AppSizes.marginS),
                    
                    // Ingredient Summary
                    if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You have ${_calculateOwnedIngredients(recipe)} of ${recipe.ingredients!.length} ingredients',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSizes.marginXS),
                          _buildIngredientProgress(context, recipe),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  int _calculateOwnedIngredients(Recipe recipe) {
    if (recipe.ingredients == null) return 0;
    
    // In a real app, this would compare against pantry items
    // For now, we'll just simulate a random value for demonstration
    return (recipe.ingredients!.length * 0.7).floor(); // Simulate ~70% ownership
  }
  
  Widget _buildIngredientProgress(BuildContext context, Recipe recipe) {
    if (recipe.ingredients == null) return const SizedBox.shrink();
    
    final total = recipe.ingredients!.length;
    final owned = _calculateOwnedIngredients(recipe);
    final percentage = owned / total;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Stack(
          children: [
            // Background
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Foreground (owned)
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width * percentage * 0.5, // Adjust width based on parent constraints
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: AppSizes.marginM),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                ),
                
                const SizedBox(width: AppSizes.marginM),
                
                // Content placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 150,
                        color: AppColors.surface,
                      ),
                      const SizedBox(height: AppSizes.marginM),
                      Container(
                        height: 14,
                        width: 100,
                        color: AppColors.surface,
                      ),
                      const SizedBox(height: AppSizes.marginM),
                      Container(
                        height: 14,
                        width: 120,
                        color: AppColors.surface,
                      ),
                      const SizedBox(height: AppSizes.marginS),
                      Container(
                        height: 6,
                        width: double.infinity,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: AppSizes.iconXL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'No recipe suggestions yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Add more ingredients to your pantry to get personalized recipe suggestions',
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
