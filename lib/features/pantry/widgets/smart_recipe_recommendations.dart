import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import '../../../models/pantry_item.dart';

class SmartRecipeRecommendations extends StatelessWidget {
  final List<Recipe> pantryBasedRecipes;
  final List<Recipe> generalRecommendations;
  final List<PantryItem> pantryItems;
  final bool isLoading;

  const SmartRecipeRecommendations({
    super.key,
    required this.pantryBasedRecipes,
    required this.generalRecommendations,
    required this.pantryItems,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pantry-based recommendations
        if (pantryBasedRecipes.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: 'Cook with Your Pantry',
            subtitle: 'Recipes you can make with ingredients you have',
            icon: Icons.kitchen,
          ),
          const SizedBox(height: AppSizes.marginM),
          _buildRecipesList(context, pantryBasedRecipes, showIngredientMatch: true),
          const SizedBox(height: AppSizes.marginL),
        ],

        // General recommendations
        if (generalRecommendations.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            title: 'Recommended for You',
            subtitle: 'Popular recipes you might enjoy',
            icon: Icons.star,
          ),
          const SizedBox(height: AppSizes.marginM),
          _buildRecipesList(context, generalRecommendations, showIngredientMatch: false),
        ],

        // Empty state
        if (pantryBasedRecipes.isEmpty && generalRecommendations.isEmpty)
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSizes.marginS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesList(
    BuildContext context,
    List<Recipe> recipes, {
    required bool showIngredientMatch,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(context, recipe, showIngredientMatch);
      },
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    Recipe recipe,
    bool showIngredientMatch,
  ) {
    final matchPercentage = showIngredientMatch 
        ? _calculateIngredientMatchPercentage(recipe)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).push('/recipe/${recipe.slug ?? recipe.id}');
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
                  width: 80,
                  height: 80,
                  color: AppColors.surface,
                  child: recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppColors.textSecondary,
                        ),
                ),
              ),

              const SizedBox(width: AppSizes.marginM),

              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Match Percentage
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (matchPercentage != null) ...[
                          const SizedBox(width: AppSizes.marginS),
                          _buildMatchPercentageBadge(matchPercentage),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSizes.marginS),                    // Recipe details
                    Wrap(
                      spacing: AppSizes.marginM,
                      runSpacing: 4,
                      children: [
                        _buildDetailItem(
                          icon: Icons.star,
                          text: '${recipe.rating}',
                          color: Colors.amber,
                        ),
                        if (recipe.cookTime != null)
                          _buildDetailItem(
                            icon: Icons.schedule,
                            text: '${recipe.cookTime} min',
                            color: AppColors.textSecondary,
                          ),
                        if (recipe.servings != null)
                          _buildDetailItem(
                            icon: Icons.people,
                            text: '${recipe.servings} servings',
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),

                    // Ingredient summary for pantry-based recipes
                    if (showIngredientMatch && recipe.ingredients != null) ...[
                      const SizedBox(height: AppSizes.marginS),
                      _buildIngredientSummary(recipe),
                    ],

                    // Estimated cost
                    if (recipe.estimatedCost != null) ...[
                      const SizedBox(height: AppSizes.marginS),
                      _buildDetailItem(
                        icon: Icons.attach_money,
                        text: 'Est. Rp ${recipe.estimatedCost}',
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchPercentageBadge(double percentage) {
    final color = percentage >= 0.8 
        ? AppColors.success
        : percentage >= 0.5 
            ? Colors.orange
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '${(percentage * 100).round()}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientSummary(Recipe recipe) {
    final pantryIngredientNames = pantryItems.map((item) => item.name.toLowerCase()).toList();
    final matchedIngredients = <String>[];
    final missingIngredients = <String>[];

    for (final ingredient in recipe.ingredients!) {
      final ingredientName = ingredient['name']?.toString().toLowerCase() ?? '';
      
      final isMatched = pantryIngredientNames.any((pantryItem) => 
          ingredientName.contains(pantryItem) || pantryItem.contains(ingredientName));
      
      if (isMatched) {
        matchedIngredients.add(ingredient['name']?.toString() ?? '');
      } else {
        missingIngredients.add(ingredient['name']?.toString() ?? '');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (matchedIngredients.isNotEmpty)
          _buildIngredientList(
            'You have: ${matchedIngredients.take(3).join(', ')}',
            AppColors.success,
            Icons.check_circle_outline,
          ),
        if (missingIngredients.isNotEmpty)
          _buildIngredientList(
            'Need: ${missingIngredients.take(3).join(', ')}',
            AppColors.error,
            Icons.shopping_cart_outlined,
          ),
      ],
    );
  }

  Widget _buildIngredientList(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) => 
        Container(
          margin: const EdgeInsets.only(bottom: AppSizes.marginM),
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
            'No recipe recommendations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  double _calculateIngredientMatchPercentage(Recipe recipe) {
    if (recipe.ingredients == null || recipe.ingredients!.isEmpty) {
      return 0.0;
    }

    final pantryIngredientNames = pantryItems.map((item) => item.name.toLowerCase()).toList();
    int matchedIngredients = 0;
    final totalIngredients = recipe.ingredients!.length;

    for (final ingredient in recipe.ingredients!) {
      final ingredientName = ingredient['name']?.toString().toLowerCase() ?? '';
      
      if (pantryIngredientNames.any((pantryItem) => 
          ingredientName.contains(pantryItem) || pantryItem.contains(ingredientName))) {
        matchedIngredients++;
      }
    }

    return matchedIngredients / totalIngredients;
  }
}
