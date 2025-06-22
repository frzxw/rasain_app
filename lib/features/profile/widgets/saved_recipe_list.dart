import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import '../../../cubits/recipe/recipe_cubit.dart';
import '../../../cubits/notification/notification_cubit.dart';

class SavedRecipeList extends StatefulWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  final Function(String recipeId)? onRemoveFromFavorite;

  const SavedRecipeList({
    super.key,
    required this.recipes,
    this.isLoading = false,
    this.onRemoveFromFavorite,
  });

  @override
  State<SavedRecipeList> createState() => _SavedRecipeListState();
}

class _SavedRecipeListState extends State<SavedRecipeList> {
  @override
  Widget build(BuildContext context) {
    print('📋 SavedRecipeList: Building widget...');
    print('   Recipe count: ${widget.recipes.length}');
    print('   Is loading: ${widget.isLoading}');

    for (int i = 0; i < widget.recipes.length; i++) {
      final recipe = widget.recipes[i];
      print('   [$i] ${recipe.name}');
      print('       ID: ${recipe.id}');
      print('       Image URL: ${recipe.imageUrl ?? 'No image'}');
      print('       Has image: ${recipe.imageUrl != null}');
      print('       Is saved: ${recipe.isSaved}');
    }

    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.recipes.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      itemCount: widget.recipes.length,
      itemBuilder: (context, index) {
        final recipe = widget.recipes[index];
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
          GoRouter.of(context).push('/recipe/${recipe.slug ?? recipe.id}');
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
                child:
                    recipe.imageUrl != null
                        ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Icon(
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
                    // Title and Remove Button Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Remove from favorite button
                        IconButton(
                          onPressed: () {
                            _showRemoveDialog(context, recipe);
                          },
                          icon: const Icon(
                            Icons.favorite,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'Hapus dari favorit',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
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
                                '${recipe.cookTime} menit',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),

                        if (recipe.cookTime != null &&
                            recipe.estimatedCost != null)
                          const SizedBox(width: AppSizes.marginM),

                        if (recipe.estimatedCost != null)
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                'Est. Rp ${recipe.estimatedCost}',
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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

  void _showRemoveDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus dari Favorit'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${recipe.name}" dari daftar favorit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Use the callback if provided, otherwise use cubit directly
                if (widget.onRemoveFromFavorite != null) {
                  widget.onRemoveFromFavorite!(recipe.id);
                } else {
                  // Use RecipeCubit directly if no callback provided
                  await context.read<RecipeCubit>().toggleSavedRecipe(
                    recipe.id,
                  );
                  await context.read<RecipeCubit>().getLikedRecipes();

                  // Show notification
                  final notificationCubit = context.read<NotificationCubit>();
                  await notificationCubit.notifyRecipeRemoved(
                    recipe.name,
                    context: context,
                    recipeId: recipe.id,
                  );
                }

                // Show snackbar confirmation
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${recipe.name} dihapus dari favorit'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
