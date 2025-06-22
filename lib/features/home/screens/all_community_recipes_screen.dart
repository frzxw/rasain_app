import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../cubits/recipe/recipe_cubit.dart';
import '../../../cubits/recipe/recipe_state.dart';
import '../../../models/recipe.dart';

class AllCommunityRecipesScreen extends StatefulWidget {
  const AllCommunityRecipesScreen({super.key});

  @override
  State<AllCommunityRecipesScreen> createState() =>
      _AllCommunityRecipesScreenState();
}

class _AllCommunityRecipesScreenState extends State<AllCommunityRecipesScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Terbaru',
    'Rating Tertinggi',
    'Tercepat',
    'Populer'
  ];
  @override
  void initState() {
    super.initState();
    // Load all community recipes
    context.read<RecipeCubit>().refreshAllRecipes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Masak Apa Hari Ini',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Recipes grid
          Expanded(
            child: BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                if (state.status == RecipeStatus.loading) {
                  return _buildLoadingState();
                }
                  if (state.status == RecipeStatus.error) {
                  return _buildErrorState(state.errorMessage ?? 'Terjadi kesalahan');
                }
                
                if (state.recipes.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredRecipes = _filterRecipes(state.recipes);
                
                return _buildRecipesGrid(filteredRecipes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.marginS),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipesGrid(List<Recipe> recipes) {    return RefreshIndicator(
      onRefresh: () async {
        context.read<RecipeCubit>().refreshAllRecipes();
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: MasonryGridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: AppSizes.marginM,
          crossAxisSpacing: AppSizes.marginM,
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return _buildRecipeCard(recipe);
          },
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/recipe/${recipe.slug ?? recipe.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusL),
                topRight: Radius.circular(AppSizes.radiusL),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                color: AppColors.surface,
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.restaurant,
                          color: AppColors.textSecondary,
                          size: AppSizes.iconXL,
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        color: AppColors.textSecondary,
                        size: AppSizes.iconXL,
                      ),
              ),
            ),
            
            // Recipe Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: AppSizes.marginS),
                  
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${recipe.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.marginS),
                  
                  // Cook time and difficulty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (recipe.cookTime != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookTime}m',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      
                      if (recipe.difficultyLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(recipe.difficultyLevel!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            recipe.difficultyLevel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    switch (_selectedFilter) {      case 'Terbaru':
        // Since we don't have createdAt, sort by ID (assuming newer recipes have higher IDs)
        return recipes..sort((a, b) => b.id.compareTo(a.id));
      case 'Rating Tertinggi':
        return recipes..sort((a, b) => b.rating.compareTo(a.rating));
      case 'Tercepat':
        return recipes.where((r) => r.cookTime != null).toList()
          ..sort((a, b) => a.cookTime!.compareTo(b.cookTime!));
      case 'Populer':
        return recipes..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      default:
        return recipes;
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Oops! Terjadi kesalahan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginL),          ElevatedButton(
            onPressed: () {
              context.read<RecipeCubit>().refreshAllRecipes();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Belum ada resep',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Mulai berbagi resep favoritmu!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
