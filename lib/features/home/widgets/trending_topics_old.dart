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
          return _buildTopicCard(
            context,
            TrendingTopic(
              id: recipe.id.toString(),
              title: recipe.title,
              description: recipe.description ?? '',
              popularity: recipe.saves ?? 0,
            ),
            index,
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TrendingTopic topic, int index) {
    // Use shades of red for variety
    final colors = [
      AppColors.primary,
      AppColors.primary.withOpacity(0.8),
      AppColors.primary.withOpacity(0.9),
      AppColors.primary.withOpacity(0.7),
      AppColors.primary.withOpacity(0.85),
    ];

    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => onTopicTap?.call(topic.keyword),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppSizes.marginM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trending indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Topic name
                  Text(
                    topic.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Recipe count
                  Text(
                    '${topic.recipeCount} resep',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
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

class TrendingTopic {
  final String name;
  final String keyword;
  final int recipeCount;
  final String? emoji;

  const TrendingTopic({
    required this.name,
    required this.keyword,
    required this.recipeCount,
    this.emoji,
  });

  // Factory method for sample data
  static List<TrendingTopic> getSampleTopics() {
    return [
      const TrendingTopic(
        name: 'Makanan Pedas',
        keyword: 'pedas',
        recipeCount: 1205,
        emoji: '🌶️',
      ),
      const TrendingTopic(
        name: 'Dessert Coklat',
        keyword: 'coklat',
        recipeCount: 892,
        emoji: '🍫',
      ),
      const TrendingTopic(
        name: 'Seafood Fresh',
        keyword: 'seafood',
        recipeCount: 634,
        emoji: '🦐',
      ),
      const TrendingTopic(
        name: 'Vegetarian',
        keyword: 'vegetarian',
        recipeCount: 567,
        emoji: '🥗',
      ),
      const TrendingTopic(
        name: 'Comfort Food',
        keyword: 'comfort',
        recipeCount: 423,
        emoji: '🍲',
      ),
    ];
  }
}
