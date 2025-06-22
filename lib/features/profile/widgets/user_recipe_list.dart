import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';

class UserRecipeList extends StatefulWidget {
  final List<Recipe> recipes;
  final bool isLoading;

  const UserRecipeList({
    super.key,
    required this.recipes,
    this.isLoading = false,
  });

  @override
  State<UserRecipeList> createState() => _UserRecipeListState();
}

class _UserRecipeListState extends State<UserRecipeList> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tombol expand/collapse
          InkWell(
            onTap: widget.recipes.isNotEmpty ? _toggleExpanded : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
                horizontal: AppSizes.paddingXS,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.marginM),
                  Expanded(
                    child: Text(
                      'Resep Buatan Saya',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.recipes.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.recipes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.marginS),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.marginM),

          // Content yang dapat di-expand/collapse
          if (widget.isLoading)
            _buildLoadingState()
          else if (widget.recipes.isEmpty)
            _buildEmptyState(context)
          else
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded 
                  ? _buildRecipeList(context)
                  : _buildCollapsedState(context),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_circle_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Belum Ada Resep',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Mulai bagikan resep istimewa Anda\ndan inspirasi jutaan orang',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginL),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/upload-recipe');
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Buat Resep Pertama',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
            ),
          ),
        ],
      ),
    );
  }  Widget _buildCollapsedState(BuildContext context) {
    // Tampilkan hanya 2 resep pertama dalam mode collapsed
    final displayRecipes = widget.recipes.take(2).toList();
    
    return Column(
      children: [
        ...displayRecipes.map((recipe) => _buildCompactRecipeItem(context, recipe)),
        if (widget.recipes.length > 2) ...[
          const SizedBox(height: AppSizes.marginM),
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _toggleExpanded,
              icon: Icon(
                Icons.expand_more,
                color: AppColors.primary,
              ),
              label: Text(
                'Lihat ${widget.recipes.length - 2} resep lainnya',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactRecipeItem(BuildContext context, Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.marginS),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).push('/recipe/${recipe.slug ?? recipe.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Row(
          children: [
            // Recipe Image (smaller)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                color: Colors.grey.shade100,
              ),
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      child: Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),
            const SizedBox(width: AppSizes.marginM),
            
            // Recipe Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppSizes.marginS),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.cookTime} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItem(BuildContext context, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail
          GoRouter.of(context).push('/recipe/${recipe.slug ?? recipe.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              // Recipe Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  color: Colors.grey.shade100,
                ),
                child:
                    recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          child: Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultImage();
                            },
                          ),
                        )
                        : _buildDefaultImage(),
              ),
              const SizedBox(width: AppSizes.marginM),

              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.description != null &&
                        recipe.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        recipe.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSizes.marginS),

                    // Recipe Stats
                    Row(
                      children: [
                        if (recipe.cookTime != null) ...[
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.cookTime} min',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: AppSizes.marginM),
                        ],
                        if (recipe.rating > 0) ...[
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Icon(Icons.restaurant, color: AppColors.primary, size: 32),
    );
  }

  Widget _buildRecipeList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.recipes.length,
      itemBuilder: (context, index) {
        final recipe = widget.recipes[index];
        return _buildRecipeItem(context, recipe);
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Icon(
        Icons.restaurant,
        color: Colors.grey.shade400,
        size: 24,
      ),
    );
  }
}
