import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/custom_button.dart';
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
  bool _showLowStock = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize pantry data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PantryCubit>().initialize();
      context.read<RecipeCubit>().fetchPantryBasedRecipes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Smart Pantry',
        showNotification: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _tabController.animateTo(2),
            tooltip: 'Statistics',
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
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2), text: 'Items'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Recipes'),
              Tab(icon: Icon(Icons.analytics), text: 'Stats'),
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
                Expanded(
                  child: Text(
                    '${state.expiringItems.length} item${state.expiringItems.length > 1 ? 's' : ''} expiring soon',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showExpiring = true;
                    });
                  },
                  child: const Text('View'),
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
                Expanded(
                  child: Text(
                    '${state.lowStockItems.length} item${state.lowStockItems.length > 1 ? 's' : ''} running low',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showLowStock = true;
                    });
                  },
                  child: const Text('View'),
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
      children: [
        Text(
          'Items (${items.length})',
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
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Your pantry is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Add ingredients to get personalized recipe recommendations',
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
                  label: 'Add Manually',
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
                  label: 'Scan Item',
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
        children: [
          Text(
            'Smart Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),
          
          if (state.items.isNotEmpty) ...[
            _buildInsightItem(
              icon: Icons.restaurant_menu,
              title: 'Recipe Potential',
              description: 'You can make ${state.pantryBasedRecipes.length} recipes with your current pantry',
              color: AppColors.success,
            ),
            
            if (state.expiringItems.isNotEmpty)
              _buildInsightItem(
                icon: Icons.schedule,
                title: 'Use Soon',
                description: 'Consider using ${state.expiringItems.first.name} and ${state.expiringItems.length - 1} other items soon',
                color: Colors.orange,
              ),
          ] else
            _buildInsightItem(
              icon: Icons.lightbulb_outline,
              title: 'Get Started',
              description: 'Add your first ingredient to start getting smart recommendations',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item detected and added to your pantry'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing image. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteItem(PantryItem item) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to remove ${item.name} from your pantry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PantryCubit>().deletePantryItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markItemAsUsed(PantryItem item) {
    context.read<PantryCubit>().markItemAsUsed(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} marked as used'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
