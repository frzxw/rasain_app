import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rasain_app/core/widgets/shimmer_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/config/supabase_config.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../cubits/recipe/recipe_state.dart';
import '../../models/recipe.dart';
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
    'All',
    'Makanan Utama',
    'Pedas',
    'Tradisional',
    'Sup',
    'Daging',
    'Manis',
  ];
  String _selectedCategory = 'All';
  bool _isSearching = false;
  bool _isImageSearching = false;
  Timer? _searchTimer; // Add timer for debouncing

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeCubit = context.read<RecipeCubit>();
      if (recipeCubit.state.status == RecipeStatus.initial) {
        recipeCubit.initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel(); // Cancel timer
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return; // Add mounted check to prevent lifecycle errors

    // Cancel previous timer
    _searchTimer?.cancel();

    // Set timer for debouncing (500ms delay)
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (_searchController.text.trim().isNotEmpty) {
        if (!_isSearching) {
          setState(() {
            _isSearching = true;
          });
        }
        debugPrint('🔍 Searching for: "${_searchController.text}"');
        context.read<RecipeCubit>().searchRecipes(
          _searchController.text.trim(),
        );
      } else {
        if (_isSearching) {
          setState(() {
            _isSearching = false;
          });
        }
        context.read<RecipeCubit>().initialize();
      }
    });
  }

  Future<void> _testDatabaseDirectly() async {
    try {
      debugPrint('🧪 Testing direct database access...');
      final response = await SupabaseConfig.client
          .from('recipes')
          .select('id, name, description')
          .limit(3);

      debugPrint('✅ SUCCESS! Found ${response.length} recipes from database:');
      for (var recipe in response) {
        debugPrint('  • ${recipe['name']}: ${recipe['description']}');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Database test SUCCESS! Found ${response.length} recipes',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Database test FAILED: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Database test FAILED: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHomeData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              if (_isSearching) _buildSearchResults() else _buildHomeContent(),
            ],
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
      actions: [
        // Debug button untuk test database
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _testDatabaseDirectly(),
            tooltip: 'Test Database',
          ),
      ],
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
            debugPrint(
              '🏠 Home - Recommended section: status=${state.status}, recommended.length=${state.recommendedRecipes.length}',
            );

            if (state.status == RecipeStatus.loading) {
              return RecipeCarousel(recipes: const [], isLoading: true);
            } else if (state.status == RecipeStatus.error) {
              return _buildErrorWidget(
                state.errorMessage ?? 'Error loading recipes',
              );
            }

            // TEMPORARY FIX: Use featured recipes if recommended is empty
            final recipesToShow =
                state.recommendedRecipes.isNotEmpty
                    ? state.recommendedRecipes
                    : state.featuredRecipes;

            debugPrint(
              '🏠 Home - Using ${recipesToShow.length} recipes for recommendations',
            );

            return RecipeCarousel(recipes: recipesToShow, isLoading: false);
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
          },
        ),
        const SizedBox(height: AppSizes.marginL),
        _buildSectionTitle('Dari Dapur Anda'),
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
          return SliverToBoxAdapter(
            child: ShimmerWidget(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    height: (index % 2 + 1) * 100.0,
                    color: Colors.white,
                  );
                },
              ),
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
          sliver: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: state.recipes.length,
            itemBuilder: (context, index) {
              final recipe = state.recipes[index];
              return _buildSearchResultItem(recipe);
            },
          ),
        );
      },
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
      onTap: () => GoRouter.of(context).push('/recipe/${recipe.id}'),
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
    if (!mounted) return; // Add mounted check

    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      if (category == 'All') {
        _isSearching = false;
        context.read<RecipeCubit>().initialize();
      } else {
        _isSearching = true;
        context.read<RecipeCubit>().filterByCategory(category);
      }
    });
  }

  Future<void> _handleImageSearch() async {
    // Since searchRecipesByImage is commented out in the cubit, this feature is disabled.
    // I'll show a snackbar to inform the user.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur pencarian dengan gambar belum tersedia saat ini.'),
      ),
    );
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(
    //   source: ImageSource.camera,
    //   maxWidth: 1000,
    //   maxHeight: 1000,
    //   imageQuality: 85,
    // );

    // if (image == null) return;

    // setState(() {
    //   _isSearching = true;
    //   _isImageSearching = true;
    // });

    // try {
    //   final bytes = await image.readAsBytes();
    //   await context.read<RecipeCubit>().searchRecipesByImage(bytes, image.name);
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Gagal memproses gambar. Silakan coba lagi.'),
    //       backgroundColor: AppColors.error,
    //     ),
    //   );
    // } finally {
    //   setState(() {
    //     _isImageSearching = false;
    //   });
    // }
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
}
