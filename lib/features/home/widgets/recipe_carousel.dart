import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/widgets/recipe_card.dart';
import '../../../models/recipe.dart';
import '../../../core/theme/colors.dart';

class RecipeCarousel extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  final double cardWidth;
  final double cardHeight;
  
  const RecipeCarousel({
    Key? key,
    required this.recipes,
    this.isLoading = false,
    this.cardWidth = AppSizes.recipeCardWidth,
    this.cardHeight = AppSizes.recipeCardHeight,
  }) : super(key: key);

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
          return RecipeCard(
            recipe: recipes[index],
            width: cardWidth,
            height: cardHeight,
          );
        },
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
        ),
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            height: cardHeight,
            margin: const EdgeInsets.only(right: AppSizes.marginM),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
            children: [
              const Icon(
                Icons.restaurant,
                size: AppSizes.iconL,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSizes.marginM),
              Text(
                'No recipes available',
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
