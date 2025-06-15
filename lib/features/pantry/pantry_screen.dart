import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/ingredient_tile.dart';
import '../../services/pantry_service.dart';
import '../../services/data_service.dart';
import '../../models/pantry_item.dart';
import 'widgets/pantry_input_form.dart';
import 'widgets/pantry_suggestions.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final DataService _dataService = DataService();
  List<String> _allKitchenTools = [];

  bool _showInputForm = false;
  PantryItem? _editingItem;
  @override
  void initState() {
    super.initState();
    _loadKitchenTools();
    // Initialize pantry data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pantryService = Provider.of<PantryService>(context, listen: false);
      pantryService.initialize();
    });
  }

  Future<void> _loadKitchenTools() async {
    try {
      final tools = await _dataService.getKitchenTools();
      if (mounted) {
        setState(() {
          _allKitchenTools = tools;
        });
      }
    } catch (e) {
      debugPrint('Error loading kitchen tools: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Pantry'),
      body: Consumer<PantryService>(
        builder: (context, pantryService, _) {
          if (pantryService.isLoading && pantryService.pantryItems.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return _showInputForm
              ? _buildInputForm()
              : _buildPantryContent(pantryService);
        },
      ),
      floatingActionButton:
          !_showInputForm
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showInputForm = true;
                    _editingItem = null;
                  });
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildPantryContent(PantryService pantryService) {
    return RefreshIndicator(
      onRefresh: () async {
        await pantryService.initialize();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Add Buttons
              _buildQuickAddSection(),

              const SizedBox(height: AppSizes.marginL),

              // Ingredients List
              _buildIngredientsList(pantryService),

              const SizedBox(height: AppSizes.marginL),

              // Kitchen Tools
              _buildKitchenTools(pantryService),

              const SizedBox(height: AppSizes.marginL),

              // Pantry Suggestions
              Text(
                'Pantry AI Suggestions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.marginM),
              PantrySuggestions(
                recipes: pantryService.suggestedRecipes,
                isLoading: pantryService.isLoading,
              ),

              const SizedBox(height: AppSizes.marginXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Row(
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
            textStyle: TextStyle(
              color: const Color.fromARGB(255, 197, 49, 49),
            ), // Ubah teks menjadi putih
          ),
        ),
        const SizedBox(width: AppSizes.marginM),
        Expanded(
          child: CustomButton(
            label: 'Scan Item',
            icon: Icons.camera_alt_outlined,
            onPressed: _handleCameraInput,
            variant: ButtonVariant.primary,
            textStyle: TextStyle(
              color: Colors.white,
            ), // Ubah teks menjadi putih
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsList(PantryService pantryService) {
    final pantryItems = pantryService.pantryItems;

    if (pantryItems.isEmpty) {
      return _buildEmptyPantryState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Ingredients',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${pantryItems.length} items',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.marginM),
        ...pantryItems.map(
          (item) => IngredientTile(
            ingredient: item,
            onEdit: () {
              setState(() {
                _showInputForm = true;
                _editingItem = item;
              });
            },
            onDelete: () => _confirmDeleteItem(pantryService, item),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPantryState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingL,
        horizontal: AppSizes.paddingM,
      ),
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Add ingredients to get personalized recipe recommendations',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenTools(PantryService pantryService) {
    final selectedTools = pantryService.kitchenTools;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kitchen Tools', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSizes.marginS),
        Text(
          'Select the tools you have in your kitchen',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.marginM),
        Wrap(
          spacing: AppSizes.marginS,
          runSpacing: AppSizes.marginS,
          children:
              _allKitchenTools.map((tool) {
                final isSelected = selectedTools.contains(tool);
                return FilterChip(
                  label: Text(tool),
                  selected: isSelected,
                  onSelected: (selected) {
                    pantryService.toggleKitchenTool(tool, selected);
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.1),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
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
        final pantryService = Provider.of<PantryService>(
          context,
          listen: false,
        );

        if (_editingItem != null) {
          pantryService.updatePantryItem(item);
        } else {
          pantryService.addPantryItem(item);
        }

        setState(() {
          _showInputForm = false;
        });
      },
    );
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
      final pantryService = Provider.of<PantryService>(context, listen: false);
      await pantryService.addPantryItemFromImage(bytes, image.name);

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Items added to your pantry'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing image. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteItem(
    PantryService pantryService,
    PantryItem item,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  pantryService.deletePantryItem(item.id);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
