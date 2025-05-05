import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../models/recipe.dart';
import '../../../core/theme/colors.dart';
import 'package:go_router/go_router.dart';

class RecipeCarousel extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  final double cardWidth;
  final double cardHeight;
  
  const RecipeCarousel({
    super.key,
    required this.recipes,
    this.isLoading = false,
    this.cardWidth = 280, // Wider card to match WhatsCoookingStream style
    this.cardHeight = 320, // Taller card to match WhatsCoookingStream style
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }
    
    if (recipes.isEmpty) {
      return _buildEmptyState();
    }
    
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
        ),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildRecipeCard(context, recipe);
        },
      ),
    );
  }
  
  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.only(right: AppSizes.marginM),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        child: InkWell(
          onTap: () {
            GoRouter.of(context).push('/recipe/${recipe.id}');
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
                  height: 180,
                  width: double.infinity,
                  color: AppColors.surface,
                  child: recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            color: AppColors.textSecondary,
                            size: AppSizes.iconXL,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppColors.textSecondary,
                          size: AppSizes.iconXL,
                        ),
                ),
              ),
              
              // Recipe Content
              Padding(
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
                    
                    // Rating and Reviews
                    Row(
                      children: [
                        _buildRatingStars(recipe.rating),
                        const SizedBox(width: AppSizes.marginS),
                        Text(
                          '(${recipe.reviewCount} ulasan)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.marginM),
                    
                    // Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cook Time
                        if (recipe.cookTime != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: AppSizes.iconS,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.cookTime!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        
                        // Estimated Cost
                        if (recipe.estimatedCost != null)
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                'Est. Rp ${recipe.estimatedCost}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
  
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            size: AppSizes.iconS,
            color: AppColors.highlight,
          );
        } else if (index == rating.floor() && rating % 1 != 0) {
          return const Icon(
            Icons.star_half,
            size: AppSizes.iconS,
            color: AppColors.highlight,
          );
        } else {
          return const Icon(
            Icons.star_border,
            size: AppSizes.iconS,
            color: AppColors.highlight,
          );
        }
      }),
    );
  }
  
  Widget _buildLoadingState() {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
        ),
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            height: cardHeight,
            margin: const EdgeInsets.only(right: AppSizes.marginM),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusM),
                        topRight: Radius.circular(AppSizes.radiusM),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 24,
                          width: 200,
                          color: AppColors.surface,
                        ),
                        const SizedBox(height: AppSizes.marginM),
                        Container(
                          height: 16,
                          width: 150,
                          color: AppColors.surface,
                        ),
                        const SizedBox(height: AppSizes.marginM),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 16,
                              width: 80,
                              color: AppColors.surface,
                            ),
                            Container(
                              height: 16,
                              width: 80,
                              color: AppColors.surface,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return SizedBox(
      height: cardHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.restaurant,
                size: AppSizes.iconL,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSizes.marginM),
              Text(
                'Belum ada resep tersedia',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
