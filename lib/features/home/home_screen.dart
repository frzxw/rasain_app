import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../cubits/recipe/recipe_state.dart';
import '../../cubits/pantry/pantry_cubit.dart';
import '../../cubits/pantry/pantry_state.dart';
import '../../models/recipe.dart';
import 'widgets/category_slider.dart';
import 'widgets/recipe_carousel.dart';
import 'widgets/whats_cooking_stream.dart';
import 'widgets/filter_recipe_widget.dart';
import 'widgets/greeting_header.dart';
import 'widgets/quick_action_buttons.dart';
import 'widgets/modern_stats_cards.dart';
import 'widgets/modern_floating_action_button.dart';
import 'widgets/trending_recipes_section.dart';
import 'widgets/modern_search_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/loading_state.dart';
import 'widgets/empty_state.dart';
import '../../core/widgets/notification_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [
    'All',
  ]; // Change to non-final so it can be updated
  String _selectedCategory = 'All';
  bool _isSearching = false;
  bool _hasActiveFilters = false;

  // Filter state variables
  RangeValues _priceRange = const RangeValues(0, 100000);
  RangeValues _timeRange = const RangeValues(0, 120);
  String? _selectedDifficultyLevel;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<RecipeCubit>().initialize();
      context.read<PantryCubit>().initialize();

      // Load categories from database using RecipeCubit
      try {
        final categories = await context.read<RecipeCubit>().getCategories();
        if (mounted && categories.isNotEmpty) {
          setState(() {
            _categories = ['All', ...categories];
          });
        }
      } catch (e) {
        print('❌ Error loading categories: $e');
        // Fallback to default categories if error occurs
        setState(() {
          _categories = [
            'All',
            'Appetizer',
            'Main Course',
            'Dessert',
            'Beverage',
          ];
        });
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      context.read<RecipeCubit>().searchRecipes(query);
    } else {
      if (_isSearching) {
        setState(() {
          _isSearching = false;
        });
        context.read<RecipeCubit>().initialize();
      }
    }
  }

  void _handleCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
    });

    if (category == 'All') {
      context.read<RecipeCubit>().initialize();
    } else {
      context.read<RecipeCubit>().loadCategoryRecipes(category);
    }
  }

  Future<void> _refreshHomeData() async {
    await Future.wait([
      context.read<RecipeCubit>().initialize(),
      context.read<PantryCubit>().initialize(),
    ]);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocBuilder<RecipeCubit, RecipeState>(
            builder: (context, state) {
              return FilterRecipeWidget(
                priceRange: _priceRange,
                timeRange: _timeRange,
                selectedDifficultyLevel: _selectedDifficultyLevel,
                availableDifficultyLevels: state.availableDifficultyLevels,
                onPriceRangeChanged: (range) {
                  setState(() {
                    _priceRange = range;
                    _hasActiveFilters = true;
                  });
                },
                onTimeRangeChanged: (range) {
                  setState(() {
                    _timeRange = range;
                    _hasActiveFilters = true;
                  });
                },
                onDifficultyLevelChanged: (level) {
                  setState(() {
                    _selectedDifficultyLevel = level;
                    _hasActiveFilters = level != null;
                  });
                },
                onApplyFilters: () {
                  context.read<RecipeCubit>().filterRecipes(
                    categories:
                        _selectedCategory != 'All' ? [_selectedCategory] : null,
                    priceRange: _priceRange,
                    timeRange: _timeRange,
                    difficulties:
                        _selectedDifficultyLevel != null
                            ? [_selectedDifficultyLevel!]
                            : null,
                  );
                  Navigator.pop(context);
                },
                onResetFilters: () {
                  setState(() {
                    _priceRange = const RangeValues(0, 100000);
                    _timeRange = const RangeValues(0, 120);
                    _selectedDifficultyLevel = null;
                    _hasActiveFilters = false;
                  });
                  context.read<RecipeCubit>().resetFilters();
                  Navigator.pop(context);
                },
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PantryCubit, PantryState>(
      listener: (context, state) {
        // Refresh pantry-based recipes when pantry items change
        if (state.status == PantryStatus.loaded) {
          context.read<RecipeCubit>().fetchPantryBasedRecipes();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshHomeData,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                if (_isSearching)
                  _buildSearchResults()
                else if (_selectedCategory != 'All')
                  _buildCategoryResults()
                else
                  _buildHomeContent(),
              ],
            ),
          ),
        ),
        // Modern Floating Action Button
        floatingActionButton: const ModernFloatingActionButton(),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      pinned: false,
      snap: true,
      expandedHeight: 200,
      actions: [
        // Removed notification icon from here
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            // Search Bar
            ModernSearchBar(
              controller: _searchController,
              hasActiveFilters: _hasActiveFilters,
              onFilterTap: _showFilterDialog,
              onCameraTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur pencarian dengan kamera akan segera hadir!',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              actions: [
                // Notification Icon styled to match filter icon
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: NotificationIcon(
                    iconColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Category Slider
            if (_categories.isNotEmpty)
              CategorySlider(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _handleCategoryFilter,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Greeting Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          child: GreetingHeader(
            userName: null, // TODO: Get from auth service
          ),
        ),
        const SizedBox(height: AppSizes.marginS),

        // Quick Action Buttons
        const QuickActionButtons(),
        const SizedBox(height: AppSizes.marginL),

        // Pantry-Based Recipes Section
        SectionHeader(
          title: 'Masak dari Pantry Anda',
          subtitle: 'Resep berdasarkan bahan yang Anda miliki',
          icon: Icons.kitchen,
          iconColor: AppColors.primary,
          onSeeAllTap: () {
            // Navigate to pantry-based recipes
            context.go('/pantry');
          },
        ),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            final pantryRecipes = state.pantryBasedRecipes;

            if (pantryRecipes.isEmpty) {
              return _buildEmptyPantryRecipesWidget();
            }

            return RecipeCarousel(recipes: pantryRecipes, isLoading: false);
          },
        ),
        const SizedBox(height: AppSizes.marginL),

        // Modern Stats Cards
        const ModernStatsCards(),

        const SizedBox(height: AppSizes.marginL),

        // Trending Recipes Section
        const TrendingRecipesSection(),

        const SizedBox(height: AppSizes.marginL),

        // What's Cooking Stream Section
        SectionHeader(
          title: 'What\'s Cooking',
          subtitle: 'Jelajahi resep dari komunitas',
          icon: Icons.restaurant,
          iconColor: AppColors.primary,
          onSeeAllTap: () {
            // TODO: Navigate to community recipes
          },
        ),
        const SizedBox(height: AppSizes.marginS),

        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loaded &&
                state.recipes.isNotEmpty) {
              return WhatsCookingStream(
                recipes: state.recipes.take(5).toList(),
              );
            } else {
              return const LoadingState();
            }
          },
        ),

        const SizedBox(height: AppSizes.marginXL),
      ]),
    );
  }

  Widget _buildEmptyPantryRecipesWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 64,
            color: AppColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Pantry Kosong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Tambahkan bahan ke pantry untuk mendapatkan rekomendasi resep yang dipersonalisasi',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginL),
          ElevatedButton.icon(
            onPressed: () => context.go('/pantry'),
            icon: const Icon(Icons.add),
            label: const Text('Kelola Pantry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        if (state.status == RecipeStatus.loading) {
          return const SliverToBoxAdapter(child: LoadingState());
        }

        if (state.status == RecipeStatus.error) {
          return SliverToBoxAdapter(
            child: _buildErrorState(state.errorMessage ?? 'Terjadi kesalahan'),
          );
        }

        // Use filteredRecipes for search results, fallback to recipes
        final searchResults =
            state.filteredRecipes.isNotEmpty
                ? state.filteredRecipes
                : state.recipes;

        if (searchResults.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.search_off,
              title: 'Tidak ada hasil',
              subtitle: 'Coba kata kunci lain atau hapus filter pencarian',
              actionText: 'Hapus Pencarian',
              onActionTap: () {
                _searchController.clear();
                setState(() => _isSearching = false);
                context.read<RecipeCubit>().initialize();
              },
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childCount: searchResults.length,
            itemBuilder: (context, index) {
              return _buildSearchResultItem(searchResults[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryResults() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: AppSizes.marginL),
        SectionHeader(
          title: _selectedCategory,
          subtitle: 'Resep dalam kategori $_selectedCategory',
          icon: Icons.category,
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading) {
              return const LoadingState();
            }

            if (state.status == RecipeStatus.error) {
              return _buildErrorState(
                state.errorMessage ?? 'Terjadi kesalahan',
              );
            }

            // Use filteredRecipes for category results, fallback to recipes
            final categoryResults =
                state.filteredRecipes.isNotEmpty
                    ? state.filteredRecipes
                    : state.recipes;

            if (categoryResults.isEmpty) {
              return EmptyState(
                icon: Icons.category_outlined,
                title: 'Kategori kosong',
                subtitle: 'Belum ada resep dalam kategori $_selectedCategory',
                actionText: 'Lihat Semua Resep',
                onActionTap: () {
                  setState(() => _selectedCategory = 'All');
                  context.read<RecipeCubit>().initialize();
                },
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: categoryResults.length,
                itemBuilder: (context, index) {
                  return _buildSearchResultItem(categoryResults[index]);
                },
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.marginXL),
      ]),
    );
  }

  Widget _buildSearchResultItem(Recipe recipe) {
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.slug ?? recipe.id}'),
      child: Container(
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
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusM),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child:
                    recipe.imageUrl != null
                        ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: AppColors.surface,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                        )
                        : Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.textSecondary,
                          ),
                        ),
              ),
            ),
            // Recipe Info
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.marginXS),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (recipe.cookTime != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.cookTime!.contains('m')
                              ? recipe.cookTime!
                              : '${recipe.cookTime}m',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
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

  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat resep',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
