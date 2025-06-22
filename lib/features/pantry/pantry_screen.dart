import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/auth_dialog.dart';
import '../../models/pantry_item.dart';
import '../../cubits/pantry/pantry_cubit.dart';
import '../../cubits/pantry/pantry_state.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../cubits/recipe/recipe_state.dart';
import 'widgets/pantry_input_form.dart';
import 'widgets/advanced_pantry_item_card.dart';
import 'widgets/pantry_search_filter.dart';
import 'widgets/pantry_statistics.dart';
import 'widgets/smart_recipe_recommendations.dart';
import 'widgets/quick_add_ingredients.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  bool _showInputForm = false;
  PantryItem? _editingItem;
  
  // Filter states
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLocation;
  bool _showExpiring = false;
  bool _showLowStock = false;  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize pantry data which will check authentication internally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PantryCubit>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryCubit, PantryState>(
      builder: (context, pantryState) {
        // Check loading state
        if (pantryState.status == PantryStatus.loading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(title: 'Pantry Pintar'),
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        // Check if user is unauthenticated
        if (pantryState.status == PantryStatus.unauthenticated || !pantryState.isAuthenticated) {
          return _buildUnauthenticatedView(context);
        }

        // User is authenticated, show normal pantry content
        return _buildAuthenticatedView(context);
      },
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Pantry Pintar'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Login required illustration
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSizes.marginXL),              // Title
              Text(
                'Login Diperlukan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.marginM),

              // Description
              Text(
                'Silakan masuk untuk mengakses pantry pintar Anda dan mendapatkan rekomendasi resep yang dipersonalisasi.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.marginXL),

              // Benefits list
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,                  children: [
                    Text(
                      'Dengan Smart Pantry, Anda dapat:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.marginM),
                    _buildBenefitItem(
                      icon: Icons.inventory_2_outlined,
                      text: 'Melacak bahan makanan dan tanggal kedaluwarsa',
                    ),
                    _buildBenefitItem(
                      icon: Icons.restaurant_menu_outlined,
                      text: 'Mendapatkan rekomendasi resep berdasarkan pantry Anda',
                    ),                    _buildBenefitItem(
                      icon: Icons.analytics_outlined,
                      text: 'Melihat statistik penggunaan dan wawasan',
                    ),
                    _buildBenefitItem(
                      icon: Icons.camera_alt_outlined,
                      text: 'Memindai bahan makanan dengan kamera',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.marginXL),              // Login button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Masuk / Daftar',
                  icon: Icons.login,
                  onPressed: () => _showAuthDialog(context),
                  variant: ButtonVariant.primary,
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.marginM),              // Alternative action
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.marginS),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSizes.marginM),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }  void _showAuthDialog(BuildContext context) {
    AuthDialog.showLoginDialog(
      context,
      redirectMessage: 'Silakan masuk untuk mengakses fitur pantry pintar Anda.',
      onLoginSuccess: () {
        // Refresh pantry data after successful login
        context.read<PantryCubit>().initialize();
      },
    );
  }

  Widget _buildAuthenticatedView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Pantry Pintar',        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _tabController.animateTo(2),
            tooltip: 'Statistik',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,            tabs: const [
              Tab(icon: Icon(Icons.inventory_2), text: 'Bahan'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Resep'),
              Tab(icon: Icon(Icons.analytics), text: 'Statistik'),
            ],
          ),
          // Tab content
          Expanded(
            child: BlocBuilder<PantryCubit, PantryState>(
              builder: (context, state) {
                if (state.status == PantryStatus.loading && state.items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                return _showInputForm
                    ? _buildInputForm()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPantryTab(state),
                          _buildRecipesTab(state),
                          _buildStatisticsTab(state),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !_showInputForm
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "scan",
                  onPressed: _handleCameraInput,
                  backgroundColor: AppColors.primary.withOpacity(0.9),
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(height: AppSizes.marginS),
                FloatingActionButton(
                  heroTag: "add",
                  onPressed: () {
                    setState(() {
                      _showInputForm = true;
                      _editingItem = null;
                    });
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildPantryTab(PantryState state) {
    final filteredItems = _getFilteredItems(state.items);

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PantryCubit>().initialize();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter
              PantrySearchFilter(
                searchQuery: _searchQuery,
                selectedCategory: _selectedCategory,
                selectedLocation: _selectedLocation,
                showExpiring: _showExpiring,
                showLowStock: _showLowStock,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                onLocationChanged: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
                onExpiringToggled: (show) {
                  setState(() {
                    _showExpiring = show;
                  });
                },
                onLowStockToggled: (show) {
                  setState(() {
                    _showLowStock = show;
                  });
                },
                onClearFilters: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = null;
                    _selectedLocation = null;
                    _showExpiring = false;
                    _showLowStock = false;
                  });
                },
              ),

              const SizedBox(height: AppSizes.marginL),

              // Quick alerts for expiring and low stock items
              if (state.expiringItems.isNotEmpty || state.lowStockItems.isNotEmpty)
                _buildQuickAlerts(state),

              const SizedBox(height: AppSizes.marginL),

              // Quick add section for empty state
              if (filteredItems.isEmpty)
                QuickAddIngredients(
                  onQuickAdd: (itemName, category) {
                    context.read<PantryCubit>().quickAddIngredient(itemName, category: category);
                  },
                ),

              const SizedBox(height: AppSizes.marginL),

              // Items list
              if (filteredItems.isEmpty)
                _buildEmptyState()
              else
                _buildItemsList(filteredItems),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesTab(PantryState state) {
    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, recipeState) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<RecipeCubit>().fetchPantryBasedRecipes();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: SmartRecipeRecommendations(
                pantryBasedRecipes: recipeState.pantryBasedRecipes,
                generalRecommendations: recipeState.recommendedRecipes,
                pantryItems: state.items,
                isLoading: state.isLoadingRecipes,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab(PantryState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PantryCubit>().initialize();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              PantryStatistics(
                items: state.items,
                expiringItems: state.expiringItems,
                lowStockItems: state.lowStockItems,
              ),
              
              const SizedBox(height: AppSizes.marginL),
              
              // Additional insights could go here
              _buildInsights(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAlerts(PantryState state) {
    return Column(
      children: [
        if (state.expiringItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: AppSizes.marginS),
                Expanded(                  child: Text(
                    '${state.expiringItems.length} bahan akan segera kedaluwarsa',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),                TextButton(
                  onPressed: () {
                    setState(() {
                      _showExpiring = true;
                    });
                  },
                  child: const Text('Lihat'),
                ),
              ],
            ),
          ),
        
        if (state.expiringItems.isNotEmpty && state.lowStockItems.isNotEmpty)
          const SizedBox(height: AppSizes.marginS),
        
        if (state.lowStockItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_outlined, color: AppColors.error),
                const SizedBox(width: AppSizes.marginS),
                Expanded(                  child: Text(
                    '${state.lowStockItems.length} bahan stok menipis',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),                TextButton(
                  onPressed: () {
                    setState(() {
                      _showLowStock = true;
                    });
                  },
                  child: const Text('Lihat'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildItemsList(List<PantryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        Text(
          'Bahan (${items.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.marginM),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return AdvancedPantryItemCard(
              item: item,
              onEdit: () {
                setState(() {
                  _showInputForm = true;
                  _editingItem = item;
                });
              },
              onDelete: () => _confirmDeleteItem(item),
              onUse: () => _markItemAsUsed(item),
              onQuantityChanged: (newQuantity) {
                context.read<PantryCubit>().updateItemQuantity(item.id, newQuantity);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
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
          const SizedBox(height: AppSizes.marginM),          Text(
            'Pantry Anda kosong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Tambahkan bahan makanan untuk mendapatkan rekomendasi resep yang dipersonalisasi',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginL),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Tambah Manual',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    setState(() {
                      _showInputForm = true;
                      _editingItem = null;
                    });
                  },
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Expanded(
                child: CustomButton(
                  label: 'Pindai Bahan',
                  icon: Icons.camera_alt_outlined,
                  onPressed: _handleCameraInput,
                  variant: ButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(PantryState state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          Text(
            'Wawasan Pintar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),
          
          if (state.items.isNotEmpty) ...[            _buildInsightItem(
              icon: Icons.restaurant_menu,
              title: 'Potensi Resep',
              description: 'Anda dapat membuat ${state.pantryBasedRecipes.length} resep dengan pantry saat ini',
              color: AppColors.success,
            ),
            
            if (state.expiringItems.isNotEmpty)              _buildInsightItem(
                icon: Icons.schedule,
                title: 'Gunakan Segera',
                description: 'Pertimbangkan untuk menggunakan ${state.expiringItems.first.name} dan ${state.expiringItems.length - 1} bahan lainnya segera',
                color: Colors.orange,
              ),
          ] else            _buildInsightItem(
              icon: Icons.lightbulb_outline,
              title: 'Mulai',
              description: 'Tambahkan bahan pertama Anda untuk mulai mendapatkan rekomendasi pintar',
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.marginM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSizes.marginM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return PantryInputForm(
      item: _editingItem,
      onCancel: () {
        setState(() {
          _showInputForm = false;
        });
      },
      onSave: (PantryItem item) {
        final pantryCubit = context.read<PantryCubit>();

        if (_editingItem != null) {
          pantryCubit.updatePantryItem(item);
        } else {
          pantryCubit.addPantryItem(item);
        }

        setState(() {
          _showInputForm = false;
        });
      },
    );
  }

  List<PantryItem> _getFilteredItems(List<PantryItem> items) {
    var filteredItems = items;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
            (item.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filteredItems = filteredItems.where((item) {
        return item.category == _selectedCategory;
      }).toList();
    }

    // Apply location filter
    if (_selectedLocation != null) {
      filteredItems = filteredItems.where((item) {
        return item.storageLocation == _selectedLocation;
      }).toList();
    }

    // Apply expiring filter
    if (_showExpiring) {
      filteredItems = filteredItems.where((item) => item.isExpiringSoon).toList();
    }

    // Apply low stock filter
    if (_showLowStock) {
      filteredItems = filteredItems.where((item) => item.isLowStock).toList();
    }

    return filteredItems;
  }

  Future<void> _handleCameraInput() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      await context.read<PantryCubit>().addPantryItemFromImage(bytes, image.name);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(        const SnackBar(
          content: Text('Bahan berhasil terdeteksi dan ditambahkan ke pantry Anda'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses gambar. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteItem(PantryItem item) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(        title: const Text('Hapus Bahan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${item.name} dari pantry Anda?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PantryCubit>().deletePantryItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _markItemAsUsed(PantryItem item) {
    context.read<PantryCubit>().markItemAsUsed(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ditandai telah digunakan'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
