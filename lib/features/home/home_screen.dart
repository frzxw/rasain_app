import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../services/recipe_service.dart';
import '../../models/recipe.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../cubits/recipe/recipe_state.dart';
import 'widgets/category_slider.dart';
import 'widgets/recipe_carousel.dart';
import 'widgets/whats_cooking_stream.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Makanan Utama',
    'Pedas',
    'Tradisional',
    'Sup',
    'Daging',
    'Manis',
  ];

  String _selectedCategory = 'All';
  List<Recipe> _searchResults = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();

    // Initialize the RecipeCubit if it's in the initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeCubit = context.read<RecipeCubit>();
      if (recipeCubit.state.status == RecipeStatus.initial) {
        recipeCubit.initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).scaffoldBackgroundColor, // Use theme-aware background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildHomeContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          Row(
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
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: _handleImageSearch,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _handleSearch,
                    onChanged: (value) {
                      if (value.isEmpty && _isSearching) {
                        setState(() {
                          _isSearching = false;
                          _searchResults = [];
                        });
                      }
                    },
                  ),
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
                  onPressed: () {
                    // Navigate to notifications screen
                    GoRouter.of(context).push('/notifications');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.marginM),

          // Category slider
          CategorySlider(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _handleCategoryFilter(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshHomeData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recommended Recipes (new section)
            _buildSectionTitle('Rekomendasi Menu Untuk Anda'),
            const SizedBox(height: AppSizes.marginS),
            BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                // Use the state to determine what to show
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

            // Top Highlights Carousel
            _buildSectionTitle('Hidangan Populer'),
            const SizedBox(height: AppSizes.marginS),
            BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                // Use the state to determine what to show
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
              },
            ),

            const SizedBox(height: AppSizes.marginL),
            // From Your Pantry Carousel
            _buildSectionTitle('Dari Dapur Anda'),
            const SizedBox(height: AppSizes.marginS),
            BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                // Use the state to determine what to show
                if (state.status == RecipeStatus.loading) {
                  return RecipeCarousel(recipes: const [], isLoading: true);
                } else if (state.status == RecipeStatus.error) {
                  return _buildErrorWidget(
                    state.errorMessage ?? 'Error loading recipes',
                  );
                }

                // In a real implementation, we would have pantryRecipes in the RecipeState
                // For now, we'll use a subset of recipes based on categories
                final pantryRecipes =
                    state.recipes
                        .where(
                          (recipe) =>
                              recipe.categories?.contains('Dari Dapur') == true,
                        )
                        .toList();

                return RecipeCarousel(recipes: pantryRecipes, isLoading: false);
              },
            ),

            const SizedBox(height: AppSizes.marginL),
            // What's Cooking Stream
            _buildSectionTitle('Masak Apa Hari Ini?'),
            const SizedBox(height: AppSizes.marginS),
            BlocBuilder<RecipeCubit, RecipeState>(
              builder: (context, state) {
                // Use the state to determine what to show
                if (state.status == RecipeStatus.loading) {
                  return WhatsCookingStream(recipes: const [], isLoading: true);
                } else if (state.status == RecipeStatus.error) {
                  return _buildErrorWidget(
                    state.errorMessage ?? 'Error loading recipes',
                  );
                }

                // In RecipeCubit, we'd normally have whatsNewRecipes directly,
                // but we can also filter from all recipes if needed
                return WhatsCookingStream(
                  recipes:
                      state.recipes
                          .take(5)
                          .toList(), // Take the first 5 recipes as "What's New"
                  isLoading: false,
                );
              },
            ),

            const SizedBox(height: AppSizes.marginL),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hasil Pencarian',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchResults = [];
                    _searchController.clear();
                  });
                },
                child: const Text('Bersihkan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.marginS),
        Expanded(
          child:
              _searchResults.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSizes.marginM),
                        Text(
                          'Tidak ada resep ditemukan',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final recipe = _searchResults[index];
                      return _buildSearchResultItem(recipe);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildSearchResultItem(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail
          GoRouter.of(context).push('/recipe/${recipe.id}');
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
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
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.labelLarge,
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
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              'Est. Rp ${recipe.estimatedCost}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
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

  Future<void> _refreshHomeData() async {
    try {
      // Use the RecipeCubit to initialize data instead of RecipeService
      await context.read<RecipeCubit>().initialize();
      debugPrint('✅ Home data refreshed successfully using RecipeCubit');
    } catch (e) {
      debugPrint('❌ Error refreshing home data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Use RecipeCubit instead of RecipeService directly
    await context.read<RecipeCubit>().searchRecipes(query);

    // Get results from the RecipeCubit state
    final state = context.read<RecipeCubit>().state;

    setState(() {
      _searchResults = state.recipes;
    });
  }

  void _handleCategoryFilter(String category) async {
    if (category == 'All') {
      await _refreshHomeData();
      setState(() {
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Use RecipeCubit to get recipes by category
    final recipeCubit = context.read<RecipeCubit>();
    final results = recipeCubit.getRecipesByCategory(category);

    setState(() {
      _searchResults = results;
    });
  }

  Future<void> _handleImageSearch() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final bytes = await image.readAsBytes();

      // Here we would call a method in the RecipeCubit to search by image
      // For now, we'll still use the RecipeService since we haven't implemented this in the Cubit yet
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final results = await recipeService.searchRecipesByImage(
        bytes,
        image.name,
      );

      // In a complete implementation, we'd do something like:
      // await context.read<RecipeCubit>().searchRecipesByImage(bytes, image.name);
      // final results = context.read<RecipeCubit>().state.recipes;

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses gambar. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );

      setState(() {
        _isSearching = false;
      });
    }
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Failed to load recipes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshHomeData, child: Text('Retry')),
        ],
      ),
    );
  }
}
