import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/sizes.dart';
import '../theme/colors.dart';
import '../../models/recipe.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../cubits/recipe/recipe_state.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final double width;
  final double height;
  final bool showEstimatedCost;
  final bool isHighlighted;
  final VoidCallback? onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.width = AppSizes.recipeCardWidth,
    this.height = AppSizes.recipeCardHeight,
    this.showEstimatedCost = true,
    this.isHighlighted = false,
    this.onFavoriteToggle,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _favoriteScale;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _favoriteScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _onFavoritePressed() {
    _favoriteController.forward().then((_) {
      _favoriteController.reverse();
    });

    context.read<RecipeCubit>().toggleLike(int.parse(widget.recipe.id));
    widget.onFavoriteToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Debug output to verify recipe data
    debugPrint('Building RecipeCard for recipe: ${widget.recipe.name}');

    return GestureDetector(
      onTap:
          () => GoRouter.of(
            context,
          ).push('/recipe/${widget.recipe.slug ?? widget.recipe.id}'),
      child: Container(
        width: widget.width,
        height: widget.height,
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
          border:
              widget.isHighlighted
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // Main card content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusM),
                    topRight: Radius.circular(AppSizes.radiusM),
                  ),
                  child: Container(
                    height: widget.height * 0.6,
                    width: double.infinity,
                    color: AppColors.surface,
                    child:
                        widget.recipe.imageUrl != null &&
                                widget.recipe.imageUrl!.isNotEmpty
                            ? Image.network(
                              widget.recipe.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary,
                                        ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  '❌ Error loading image for ${widget.recipe.name}: $error',
                                );
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant,
                                        color: AppColors.textSecondary,
                                        size: AppSizes.iconL,
                                      ),
                                      Text(
                                        'Image unavailable',
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
                                  Text(
                                    'No image',
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
                          widget.recipe.name,
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Recipe Rating & Review
                        Row(
                          children: [
                            _buildRatingStars(widget.recipe.rating),
                            const SizedBox(width: AppSizes.marginXS),
                            Text(
                              '(${widget.recipe.reviewCount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),

                        // Estimated Cost
                        if (widget.showEstimatedCost &&
                            widget.recipe.estimatedCost != null)
                          Row(
                            children: [
                              const SizedBox(width: 2),
                              Text(
                                'Est. ${widget.recipe.estimatedCost}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Favorite Button (Heart Icon)
            Positioned(
              top: 8,
              right: 8,
              child: BlocBuilder<RecipeCubit, RecipeState>(
                builder: (context, state) {
                  return AnimatedBuilder(
                    animation: _favoriteScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _favoriteScale.value,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _onFavoritePressed,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.recipe.isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    widget.recipe.isSaved
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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
