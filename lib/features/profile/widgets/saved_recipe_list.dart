import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';

class SavedRecipeList extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  
  const SavedRecipeList({
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
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildSavedRecipeItem(context, recipe);
      },
    );
  }

  Widget _buildSavedRecipeItem(BuildContext context, Recipe recipe) {
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusM),
                bottomLeft: Radius.circular(AppSizes.radiusM),
              ),
              child: Container(
                width: 120,
                height: 120,
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
            
            // Recipe Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppSizes.marginS),
                    
                    // Rating
                    Row(
                      children: [
                        _buildRatingStars(recipe.rating),
                        const SizedBox(width: AppSizes.marginXS),
                        Text(
                          '(${recipe.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.marginS),
                    
                    // Basic Info Row
                    Row(
                      children: [
                        if (recipe.cookTime != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: AppSizes.iconXS,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.cookTime!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        
                        if (recipe.cookTime != null && recipe.estimatedCost != null)
                          const SizedBox(width: AppSizes.marginM),
                        
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
                                'Est. ${recipe.estimatedCost}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            size: AppSizes.iconXS,
            color: AppColors.highlight,
          );
        } else if (index == rating.floor() && rating % 1 != 0) {
          return const Icon(
            Icons.star_half,
            size: AppSizes.iconXS,
            color: AppColors.highlight,
          );
        } else {
          return const Icon(
            Icons.star_border,
            size: AppSizes.iconXS,
            color: AppColors.highlight,
          );
        }
      }),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        children: List.generate(
          3,
          (index) => Card(
            margin: const EdgeInsets.only(bottom: AppSizes.marginM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusM),
                      bottomLeft: Radius.circular(AppSizes.radiusM),
                    ),
                  ),
                ),
                
                // Content placeholders
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
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
                      ],
                    ),
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
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.marginM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bookmark_border,
            size: AppSizes.iconXL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'No saved recipes yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Find and bookmark recipes you love to save them for later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginL),
          OutlinedButton.icon(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            icon: const Icon(Icons.search),
            label: const Text('Explore Recipes'),
          ),
        ],
      ),
    );
  }
}
