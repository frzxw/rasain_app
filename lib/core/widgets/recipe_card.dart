import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/sizes.dart';
import '../theme/colors.dart';
import '../../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double width;
  final double height;
  final bool showEstimatedCost;
  final bool isHighlighted;
  
  const RecipeCard({
    super.key,
    required this.recipe,
    this.width = AppSizes.recipeCardWidth,
    this.height = AppSizes.recipeCardHeight,
    this.showEstimatedCost = true,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Debug output to verify recipe data
    debugPrint('Building RecipeCard for recipe: ${recipe.name}');
    
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/recipe/${recipe.id}'),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: AppSizes.marginM),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
          border: isHighlighted 
              ? Border.all(color: AppColors.primary, width: 2) 
              : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusM),
                topRight: Radius.circular(AppSizes.radiusM),
              ),
              child: Container(
                height: height * 0.6,
                width: double.infinity,
                color: AppColors.surface,
                child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                    ? Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('❌ Error loading image for ${recipe.name}: $error');
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: AppColors.textSecondary,
                                  size: AppSizes.iconL,
                                ),
                                Text('Image unavailable',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: AppColors.textSecondary,
                              size: AppSizes.iconL,
                            ),
                            Text('No image',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            // Recipe Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Recipe Title
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Recipe Rating & Review
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
                    
                    // Estimated Cost
                    if (showEstimatedCost && recipe.estimatedCost != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: AppSizes.iconXS,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Est. ${recipe.estimatedCost}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
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
}
