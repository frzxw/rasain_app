import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_service.dart';
import '../../../cubits/notification/notification_cubit.dart';
import '../../../services/favorite_service.dart';
import '../../../services/notification_service.dart';
import '../../../cubits/notification/notification_state.dart';
import '../../../core/constants/assets.dart';
import '../../../cubits/recipe/recipe_cubit.dart';

class TrendingRecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const TrendingRecipeCard({super.key, required this.recipe, this.onTap});

  @override
  State<TrendingRecipeCard> createState() => _TrendingRecipeCardState();
}

class _TrendingRecipeCardState extends State<TrendingRecipeCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _hoverScale;

  final RecipeService _recipeService = RecipeService();
  late FavoriteService _favoriteService;
  late NotificationService _notificationService;
  late NotificationCubit _notificationCubit;

  bool _isHovered = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _hoverScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _controller.forward();
    _favoriteService = Provider.of<FavoriteService>(context, listen: false);
    _notificationService = Provider.of<NotificationService>(context, listen: false);
    _notificationCubit = NotificationCubit(_notificationService);
  }

  @override
  void dispose() {
    _controller.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _hoverController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Transform.scale(
                scale: _hoverScale.value,
                child: MouseRegion(
                  onEnter: (_) => _onHover(true),
                  onExit: (_) => _onHover(false),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSizes.marginS,
                        vertical: AppSizes.marginXS,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _isHovered
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.08),
                            blurRadius: _isHovered ? 20 : 15,
                            offset: Offset(0, _isHovered ? 8 : 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: _buildCardContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          // Recipe Image
          _buildRecipeImage(),

          const SizedBox(width: AppSizes.marginM), // Recipe Info
          Expanded(child: _buildRecipeInfo()),

          // Favorite Button
          _buildFavoriteButton(),

          const SizedBox(width: AppSizes.marginS),

          // Trending Badge
          _buildTrendingBadge(),
        ],
      ),
    );
  }

  Widget _buildRecipeImage() {
    return Hero(
      tag: 'trending_${widget.recipe.id}',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
          child:
              widget.recipe.imageUrl != null
                  ? Image.network(
                    widget.recipe.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                  : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 32),
    );
  }

  Widget _buildRecipeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe Name
        Text(
          widget.recipe.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: AppSizes.marginXS),

        // Chef Name
        Row(
          children: [
            Icon(Icons.person, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              'Chef Unknown', // Recipe model doesn't have chef field
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.marginS),

        // Stats Row
        Row(
          children: [
            _buildStatChip(
              icon: Icons.star,
              value: '${widget.recipe.rating.toStringAsFixed(1)}',
              color: Colors.amber,
            ),
            const SizedBox(width: AppSizes.marginS),
            _buildStatChip(
              icon: Icons.access_time,
              value: '${widget.recipe.cookTime ?? 30}m',
              color: AppColors.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<FavoriteService>(
      builder: (context, favoriteService, _) {
        final isSaved = favoriteService.isFavorite(widget.recipe.id);
        return StatefulBuilder(
          builder: (context, setState) {
            bool isHeartHovered = false;
            
            return MouseRegion(
              onEnter: (_) => setState(() => isHeartHovered = true),
              onExit: (_) => setState(() => isHeartHovered = false),
              child: GestureDetector(
                onTap: () async {
                  final wasSaved = isSaved;
                  final success = await favoriteService.toggleFavorite(widget.recipe.id);
                  if (success) {
                    // Get the notification cubit from the context
                    final notificationCubit = context.read<NotificationCubit>();
                    if (!wasSaved) {
                      await notificationCubit.notifyRecipeSaved(widget.recipe.name, context: context, recipeId: widget.recipe.id);
                    } else {
                      await notificationCubit.notifyRecipeRemoved(widget.recipe.name, context: context, recipeId: widget.recipe.id);
                    }
                    
                    // Refresh saved recipes in RecipeCubit to update profile page
                    context.read<RecipeCubit>().getLikedRecipes();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: isSaved ? AppColors.primary : (isHeartHovered ? Colors.grey.shade200 : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSaved ? AppColors.primary : (isHeartHovered ? Colors.grey.shade400 : Colors.grey.shade300),
                      width: isHeartHovered ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isSaved ? AppColors.primary : Colors.grey)
                            .withOpacity(isHeartHovered ? 0.3 : 0.2),
                        blurRadius: isHeartHovered ? 12 : 8,
                        offset: Offset(0, isHeartHovered ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: isHeartHovered ? 1.1 : 1.0,
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.white : (isHeartHovered ? Colors.grey.shade700 : Colors.grey.shade600),
                      size: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingBadge() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 0.1,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF6B35), const Color(0xFFFF8A65)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
