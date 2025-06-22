import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/recipe_card.dart';
import '../../../core/widgets/shimmer_widget.dart';
import '../../../cubits/recipe/recipe_cubit.dart';
import '../../../cubits/recipe/recipe_state.dart';
import '../../../models/recipe.dart';

class PantryBasedRecipes extends StatelessWidget {
  const PantryBasedRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        // Check if pantry-based recipes are available
        final pantryRecipes = state.pantryBasedRecipes;

        if (state.status == RecipeStatus.loading) {
          return _buildLoadingState();
        }

        if (pantryRecipes.isEmpty) {
          return _buildEmptyPantryState(context);
        }

        return _buildRecipesList(pantryRecipes);
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: AppSizes.marginM),
            child: ShimmerWidget(
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPantryState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.kitchen_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Pantry Kosong?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Tambahkan bahan-bahan ke pantry Anda untuk mendapatkan rekomendasi resep yang bisa dibuat',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.go('/pantry');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Kelola Pantry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.marginS),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to popular recipes as fallback
                    context.go('/recipes');
                  },
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Lihat Resep'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(List<Recipe> recipes) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: AppSizes.marginM),
            child: _buildPantryRecipeCard(recipe),
          );
        },
      ),
    );
  }

  Widget _buildPantryRecipeCard(Recipe recipe) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image with Pantry Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusM),
                      topRight: Radius.circular(AppSizes.radiusM),
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.surface,
                      child:
                          recipe.imageUrl != null
                              ? Image.network(
                                recipe.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _buildPlaceholderImage(),
                              )
                              : _buildPlaceholderImage(),
                    ),
                  ),
                  // Pantry Match Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.kitchen,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pantry Match',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Recipe Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.marginXS),

                      // Recipe Stats
                      Row(
                        children: [
                          if (recipe.cookTime != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookTime}m',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSizes.marginS),
                          ],
                          if (recipe.difficultyLevel != null) ...[
                            Icon(
                              Icons.speed,
                              size: 14,
                              color: _getDifficultyColor(
                                recipe.difficultyLevel!,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getDifficultyText(recipe.difficultyLevel!),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDifficultyColor(
                                  recipe.difficultyLevel!,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: AppSizes.marginS),

                      // Available Ingredients Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Bahan tersedia di pantry',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/recipe/${recipe.slug ?? recipe.id}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Masak Sekarang',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.restaurant, color: AppColors.textSecondary, size: 40),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Mudah';
      case 'medium':
        return 'Sedang';
      case 'hard':
        return 'Sulit';
      default:
        return difficulty;
    }
  }
}
