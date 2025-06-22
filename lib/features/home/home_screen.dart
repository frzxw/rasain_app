import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rasain_app/core/widgets/shimmer_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import 'package:rasain_app/features/home/widgets/filter_recipe_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = []; // Start empty, load from database
  String _selectedCategory = 'All';
  bool _isSearching = false;
  bool _isImageSearching = false;
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 100000);
  RangeValues _timeRange = const RangeValues(0, 180);
  String? _selectedDifficultyLevel;
  List<String> _availableDifficultyLevels = [];
  bool _hasActiveFilters = false;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeCubit = context.read<RecipeCubit>();
      if (recipeCubit.state.status == RecipeStatus.initial) {
        recipeCubit.initialize();
      }
      // Fetch pantry-based recipes for "Dari Dapur Anda" section
      recipeCubit.fetchPantryBasedRecipes();
      _loadCategories();
      _loadDifficultyLevels();
    });
  }

  Future<void> _loadCategories() async {
    try {
      debugPrint('🔍 Loading categories from database...');
      final categories = await context.read<RecipeCubit>().getCategories();

      // Remove duplicates if any
      final uniqueCategories = categories.toSet().toList();

      setState(() {
        _categories = uniqueCategories;
      });
      debugPrint('✅ Categories loaded: ${uniqueCategories.join(', ')}');
    } catch (e) {
      debugPrint('❌ Failed to load categories: $e');
      // Set default if failed to load from database
      setState(() {
        _categories = [];
      });
    }
  }

  Future<void> _loadDifficultyLevels() async {
    try {
      debugPrint('🔍 Loading difficulty levels from database...');
      final recipeCubit = context.read<RecipeCubit>();
      final difficultyLevels = await recipeCubit.getDifficultyLevels();

      setState(() {
        _availableDifficultyLevels = difficultyLevels;
      });
      debugPrint('✅ Difficulty levels loaded: ${difficultyLevels.join(', ')}');
    } catch (e) {
      debugPrint('❌ Failed to load difficulty levels: $e');
      // Set default if failed to load from database
      setState(() {
        _availableDifficultyLevels = ['Mudah', 'Sedang', 'Sulit'];
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      if (!_isSearching) {
        setState(() {
          _isSearching = true;
        });
      }
      context.read<RecipeCubit>().searchRecipes(_searchController.text);
    } else {
      if (_isSearching) {
        setState(() {
          _isSearching = false;
        });
        context.read<RecipeCubit>().initialize();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<PantryCubit, PantryState>(      listener: (context, state) {
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
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(background: _buildAppBarContent()),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: CategorySlider(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: _handleCategoryFilter,
        ),
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari resep...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: 14,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted:
                    (query) => context.read<RecipeCubit>().searchRecipes(query),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.marginM),
          // Filter Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _hasActiveFilters ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: _hasActiveFilters ? Colors.white : AppColors.textPrimary,
              ),
              onPressed: _showFilterDialog,
            ),
          ),
          const SizedBox(width: AppSizes.marginM),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () => GoRouter.of(context).push('/notifications'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: AppSizes.marginL),
        _buildSectionTitle('Rekomendasi Menu Untuk Anda'),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading) {
              return RecipeCarousel(recipes: const [], isLoading: true);
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(
                state.errorMessage ?? 'Error loading recipes',
              );
            }
            return RecipeCarousel(
              recipes: state.recommendedRecipes,
              isLoading: false,
            );
          },
        ),
        const SizedBox(height: AppSizes.marginL),
        _buildSectionTitle('Hidangan Populer'),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading) {
              return RecipeCarousel(recipes: const [], isLoading: true);
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(
                state.errorMessage ?? 'Error loading recipes',
              );
            }
            return RecipeCarousel(
              recipes: state.featuredRecipes,
              isLoading: false,
            );
          },        ),
        const SizedBox(height: AppSizes.marginL),
        _buildPantrySectionHeader(),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading && state.pantryBasedRecipes.isEmpty) {
              return RecipeCarousel(recipes: const [], isLoading: true);
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(
                state.errorMessage ?? 'Error loading pantry recipes',
              );
            }
            
            // Use pantry-based recipes from the state
            final pantryRecipes = state.pantryBasedRecipes;
            
            // If no pantry recipes available, show helpful message
            if (pantryRecipes.isEmpty) {
              return _buildEmptyPantryRecipesWidget();
            }
            
            return RecipeCarousel(recipes: pantryRecipes, isLoading: false);
          },
        ),
        const SizedBox(height: AppSizes.marginL),
        _buildSectionTitle('Masak Apa Hari Ini?'),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading) {
              return WhatsCookingStream(recipes: const [], isLoading: true);
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(
                state.errorMessage ?? 'Error loading recipes',
              );
            }
            return WhatsCookingStream(
              recipes: state.recipes.take(5).toList(),
              isLoading: false,
            );
          },
        ),
        const SizedBox(height: AppSizes.marginL),
      ]),
    );
  }

  Widget _buildSearchResults() {
    if (_isImageSearching) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSizes.marginM),
              Text('Menganalisis gambar...'),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        if (state.status == RecipeStatus.loading && state.recipes.isEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childCount: 6,
              itemBuilder: (context, index) {
                return ShimmerWidget(
                  child: Container(
                    height: (index % 2 + 1) * 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (state.recipes.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSizes.marginM),
                  Text(
                    'Tidak ada resep ditemukan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginS),
                  Text(
                    'Coba kata kunci lain atau kategori berbeda.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childCount: state.recipes.length,
            itemBuilder: (context, index) {
              final recipe = state.recipes[index];
              return _buildSearchResultItem(recipe);
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
        _buildSectionTitle('$_selectedCategory'),
        const SizedBox(height: AppSizes.marginS),
        BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state.status == RecipeStatus.loading) {
              return _buildShimmerGrid();
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(
                state.errorMessage ?? 'Error loading recipes',
              );
            } else if (state.recipes.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppSizes.marginM),
                      Text(
                        'Tidak ada resep untuk kategori $_selectedCategory',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildRecipeGrid(state.recipes);
          },
        ),
        const SizedBox(height: AppSizes.marginL),
      ]),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ShimmerWidget(
            child: Container(
              height: (index % 2 + 1) * 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid(List<Recipe> recipes) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: recipes.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildSearchResultItem(recipe);
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildSearchResultItem(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        final identifier =
            recipe.slug?.isNotEmpty == true ? recipe.slug! : recipe.id;
        GoRouter.of(context).push('/recipe/$identifier');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe_image_${recipe.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusM),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.surface,
                  child:
                      recipe.imageUrl != null
                          ? Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.restaurant_menu,
                                  color: AppColors.textSecondary,
                                  size: AppSizes.iconL,
                                ),
                          )
                          : const Icon(
                            Icons.restaurant_menu,
                            color: AppColors.textSecondary,
                            size: AppSizes.iconL,
                          ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.marginS),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.highlight,
                        size: AppSizes.iconS,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.rating} (${recipe.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (recipe.estimatedCost != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.paddingS),
                      child: Text(
                        'Est. Rp ${recipe.estimatedCost}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshHomeData() async {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _selectedCategory = 'All';
    });
    await context.read<RecipeCubit>().initialize();
  }

  void _handleCategoryFilter(String category) {
    debugPrint('🏷️ Category selected: $category');
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _isSearching = false; // Reset search state
    });

    if (category == 'All') {
      debugPrint('📋 Loading all recipes');
      context.read<RecipeCubit>().initialize();
    } else {
      debugPrint('🔍 Filtering by category: $category');
      context.read<RecipeCubit>().filterByCategory(category);
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FilterRecipeWidget(
          priceRange: _priceRange,
          timeRange: _timeRange,
          selectedDifficultyLevel: _selectedDifficultyLevel,
          availableDifficultyLevels: _availableDifficultyLevels,
          onPriceRangeChanged: (RangeValues range) {
            setState(() {
              _priceRange = range;
            });
          },
          onTimeRangeChanged: (RangeValues range) {
            setState(() {
              _timeRange = range;
            });
          },
          onDifficultyLevelChanged: (String? level) {
            setState(() {
              _selectedDifficultyLevel = level;
            });
          },
          onApplyFilters: _applyFilters,
          onResetFilters: _resetFilters,
        );
      },
    );
  }

  void _applyFilters() {
    // Check if filters are different from default values
    final bool hasPriceFilter =
        _priceRange.start > 0 || _priceRange.end < 100000;
    final bool hasTimeFilter = _timeRange.start > 0 || _timeRange.end < 180;
    final bool hasDifficultyFilter = _selectedDifficultyLevel != null;

    setState(() {
      _hasActiveFilters =
          hasPriceFilter || hasTimeFilter || hasDifficultyFilter;
      _isSearching = false;
      _searchController.clear();
    });

    // Apply filters with current category
    context.read<RecipeCubit>().filterRecipes(
      priceRange: hasPriceFilter ? _priceRange : null,
      timeRange: hasTimeFilter ? _timeRange : null,
      category: _selectedCategory != 'All' ? _selectedCategory : null,
      difficultyLevel: _selectedDifficultyLevel,
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 100000);
      _timeRange = const RangeValues(0, 180);
      _selectedDifficultyLevel = null;
      _hasActiveFilters = false;
      _isSearching = false;
      _searchController.clear();
      _selectedCategory = 'All';
    });    // Reload initial data
    context.read<RecipeCubit>().initialize();
    // Also refresh pantry-based recipes
    context.read<RecipeCubit>().fetchPantryBasedRecipes();
  }

  Widget _buildEmptyPantryRecipesWidget() {
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
            Icons.kitchen_outlined,
            size: AppSizes.iconXL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Belum Ada Resep dari Dapur Anda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Tambahkan bahan-bahan ke pantry Anda untuk mendapatkan rekomendasi resep yang bisa dibuat',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginM),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/pantry');
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Isi Pantry', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
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

  Widget _buildPantrySectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dari Dapur Anda',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.marginXS),
                BlocBuilder<RecipeCubit, RecipeState>(
                  builder: (context, state) {
                    final pantryRecipesCount = state.pantryBasedRecipes.length;
                    return Text(
                      pantryRecipesCount > 0 
                          ? '$pantryRecipesCount resep yang bisa dibuat dari bahan di pantry Anda'
                          : 'Resep berdasarkan bahan di pantry Anda',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/pantry');
            },
            icon: const Icon(
              Icons.kitchen_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Kelola Pantry',
          ),
        ],
      ),
    );
  }
}
