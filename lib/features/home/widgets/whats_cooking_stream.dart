import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import 'package:go_router/go_router.dart';

class WhatsCookingStream extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  
  const WhatsCookingStream({
    super.key,
    required this.recipes,
    this.isLoading = false,
  });

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
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildStreamItem(context, recipe);
      },
    );
  }
  
  Widget _buildStreamItem(BuildContext context, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail
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
                    style: Theme.of(context).textTheme.headlineSmall,
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
                            const Icon(
                              Icons.attach_money,
                              size: AppSizes.iconS,
                              color: AppColors.textSecondary,
                            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        children: List.generate(
          3,
          (index) => Card(
            margin: const EdgeInsets.only(bottom: AppSizes.marginM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant,
              size: AppSizes.iconXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Belum ada resep tersedia',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              'Periksa kembali nanti untuk rekomendasi baru',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
