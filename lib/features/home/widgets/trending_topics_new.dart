import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';

class TrendingTopics extends StatelessWidget {
  final List<Recipe> trendingRecipes;
  final Function(String)? onTopicTap;

  const TrendingTopics({
    super.key,
    required this.trendingRecipes,
    this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    if (trendingRecipes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: trendingRecipes.length > 5 ? 5 : trendingRecipes.length,
        itemBuilder: (context, index) {
          final recipe = trendingRecipes[index];
          return _buildTrendingCard(context, recipe, index);
        },
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, Recipe recipe, int index) {
    return GestureDetector(
      onTap: () => onTopicTap?.call(recipe.name),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppSizes.marginM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusL),
              ),
              child:
                  recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                      ? Image.network(
                        recipe.imageUrl!,
                        height: 60,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
            ),

            // Recipe Info
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
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
}
