import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../cubits/recipe/recipe_cubit.dart';
import '../../../cubits/recipe/recipe_state.dart';
import '../../../models/recipe.dart';
import '../../../core/widgets/recipe_card.dart';

class PantryRecommendationsSection extends StatelessWidget {
  const PantryRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Row(
            children: [
              Icon(
                Icons.kitchen,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.marginS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masak dari Pantry Anda',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Resep berdasarkan bahan yang Anda miliki',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to pantry screen
                  Navigator.pushNamed(context, '/pantry');
                },
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.marginM),
        
        // Pantry-based recipes
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading && state.pantryBasedRecipes.isEmpty) {
              return _buildLoadingWidget();
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(state.errorMessage ?? 'Error loading pantry recipes');
            }
            
            final pantryRecipes = state.pantryBasedRecipes;
            
            if (pantryRecipes.isEmpty) {
              return _buildEmptyWidget();
            }
            
            return _buildRecipesList(pantryRecipes);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSizes.marginM),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 32,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.kitchen_outlined,
              color: AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              'Tambahkan bahan ke pantry untuk mendapatkan rekomendasi resep',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList(List<Recipe> recipes) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSizes.marginM),
            child: RecipeCard(recipe: recipe),
          );
        },
      ),
    );
  }
}
