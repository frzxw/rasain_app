import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../services/recipe_service.dart';
import '../../models/recipe.dart';
import 'widgets/category_slider.dart';
import 'widgets/recipe_carousel.dart';
import 'widgets/whats_cooking_stream.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    // Initialize recipe data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      recipeService.initialize();
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
      backgroundColor: AppColors.background,
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
                    // Show notifications
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
            Consumer<RecipeService>(
              builder: (context, recipeService, _) {
                final recommendedRecipes = recipeService.recommendedRecipes;
                return RecipeCarousel(
                  recipes: recommendedRecipes,
                  isLoading: recipeService.isLoading && recommendedRecipes.isEmpty,
                );
              },
            ),
            
            const SizedBox(height: AppSizes.marginL),
            
            // Top Highlights Carousel
            _buildSectionTitle('Hidangan Populer'),
            const SizedBox(height: AppSizes.marginS),
            Consumer<RecipeService>(
              builder: (context, recipeService, _) {
                final popularRecipes = recipeService.popularRecipes;
                return RecipeCarousel(
                  recipes: popularRecipes,
                  isLoading: recipeService.isLoading && popularRecipes.isEmpty,
                );
              },
            ),
            
            const SizedBox(height: AppSizes.marginL),
            
            // From Your Pantry Carousel
            _buildSectionTitle('Dari Dapur Anda'),
            const SizedBox(height: AppSizes.marginS),
            Consumer<RecipeService>(
              builder: (context, recipeService, _) {
                final pantryRecipes = recipeService.pantryRecipes;
                return RecipeCarousel(
                  recipes: pantryRecipes,
                  isLoading: recipeService.isLoading && pantryRecipes.isEmpty,
                );
              },
            ),
            
            const SizedBox(height: AppSizes.marginL),
            
            // What's Cooking Stream
            _buildSectionTitle('Masak Apa Hari Ini?'),
            const SizedBox(height: AppSizes.marginS),
            Consumer<RecipeService>(
              builder: (context, recipeService, _) {
                final recipes = recipeService.whatsNewRecipes;
                return WhatsCookingStream(
                  recipes: recipes,
                  isLoading: recipeService.isLoading && recipes.isEmpty,
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
          child: _searchResults.isEmpty
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
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
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
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
                            const Icon(
                              Icons.attach_money,
                              size: AppSizes.iconS,
                              color: AppColors.textSecondary,
                            ),
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
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    await Future.wait([
      recipeService.fetchPopularRecipes(),
      recipeService.fetchPantryRecipes(),
      recipeService.fetchWhatsNewRecipes(),
      recipeService.fetchRecommendedRecipes(),
    ]);
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
    
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final results = await recipeService.searchRecipes(query);
    
    setState(() {
      _searchResults = results;
    });
  }
  
  void _handleCategoryFilter(String category) async {
    if (category == 'All') {
      await _refreshHomeData();
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final results = await recipeService.filterRecipesByCategory(category);
    
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
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final results = await recipeService.searchRecipesByImage(bytes, image.name);
      
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
}
