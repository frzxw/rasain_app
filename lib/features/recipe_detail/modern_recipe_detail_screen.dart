import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/colors.dart';
import '../../services/recipe_service.dart';
import '../../cubits/notification/notification_cubit.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import 'widgets/modern_ingredient_list.dart';
import 'widgets/modern_instruction_steps_fixed.dart' as fixed;
import 'widgets/review_section.dart';

class ModernRecipeDetailScreen extends StatefulWidget {
  final String? recipeId;
  final String? recipeSlug;
  const ModernRecipeDetailScreen({super.key, this.recipeId, this.recipeSlug});

  @override
  State<ModernRecipeDetailScreen> createState() =>
      _ModernRecipeDetailScreenState();
}

class _ModernRecipeDetailScreenState extends State<ModernRecipeDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentServings = 1; // Track current serving size

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final identifier = widget.recipeSlug ?? widget.recipeId!;
      recipeService.fetchRecipeBySlug(identifier).then((_) {
        // Initialize current servings with recipe's original servings
        if (recipeService.currentRecipe?.servings != null && mounted) {
          setState(() {
            _currentServings = recipeService.currentRecipe!.servings!;
          });
        }
      });
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<RecipeService>(
        builder: (context, recipeService, _) {
          final recipe = recipeService.currentRecipe;
          final isLoading = recipeService.isLoading;

          if (isLoading && recipe == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (recipe == null) {
            return _buildErrorState(context);
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      try {
                        context.pop();
                      } catch (e) {
                        context.go('/');
                      }
                    },
                  ),
                  actions: [
                    // Enhanced Bookmark Button with Animation
                    Consumer<RecipeService>(
                      builder: (context, recipeService, child) {
                        final currentRecipe = recipeService.currentRecipe;
                        final isSaved = currentRecipe?.isSaved ?? false;
                        
                        return IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSaved
                                  ? AppColors.highlight.withOpacity(0.2)
                                  : Colors.black38,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? AppColors.highlight : Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () async {
                            final wasSaved = isSaved;
                            await recipeService.toggleSaveRecipe(recipe.id);
                            
                            // Trigger notification
                            final notificationCubit = context.read<NotificationCubit>();
                            if (!wasSaved) {
                              await notificationCubit.notifyRecipeSaved(recipe.name, context: context, recipeId: recipe.id);
                            } else {
                              await notificationCubit.notifyRecipeRemoved(recipe.name, context: context, recipeId: recipe.id);
                            }
                            
                            // Refresh saved recipes in RecipeCubit to update profile page
                            context.read<RecipeCubit>().getLikedRecipes();
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'recipe-${recipe.id}',
                          child:
                              recipe.imageUrl != null
                                  ? Image.network(
                                    recipe.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => _buildFallbackImage(),
                                  )
                                  : _buildFallbackImage(),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          bottom: 32,
                          right: 24,
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick stats
                        Row(
                          children: [
                            _buildStatCard(
                              Icons.timer,
                              'Waktu',
                              recipe.cookTime != null
                                  ? '${recipe.cookTime} menit'
                                  : '-',
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              Icons.people,
                              'Porsi',
                              _currentServings.toString(),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              Icons.local_offer,
                              'Biaya',
                              recipe.estimatedCost != null
                                  ? 'Rp ${recipe.estimatedCost}'
                                  : '-',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Description
                        if (recipe.description != null &&
                            recipe.description!.isNotEmpty)
                          Text(
                            recipe.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ), // Ingredients
                        if (recipe.ingredients?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 32),
                          ModernIngredientList(
                            originalServings: recipe.servings ?? 1,
                            currentServings: _currentServings,
                            onServingChanged: (newServings) {
                              setState(() {
                                _currentServings = newServings;
                              });
                            },
                            ingredients:
                                recipe.ingredients!
                                    .map(
                                      (ingredient) => {
                                        'name': ingredient['name'],
                                        'quantity': ingredient['quantity'],
                                        'unit': ingredient['unit'],
                                        'image_url': ingredient['image_url'],
                                        'price': ingredient['price'],
                                      },
                                    )
                                    .toList(),
                          ),
                        ],
                        // Instructions
                        if (recipe.instructions?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 32),
                          fixed.ModernInstructionSteps(
                            recipe: recipe,
                            instructions:
                                recipe.instructions!
                                    .map(
                                      (instruction) => {
                                        'description':
                                            instruction['description'] ??
                                            instruction['text'],
                                        'duration': instruction['duration'],
                                        'timer_minutes':
                                            instruction['timer_minutes'],
                                        'image_url': instruction['image_url'],
                                        'text': instruction['text'],
                                      },
                                    )
                                    .toList(),
                          ),
                        ],
                        // Review section
                        const SizedBox(height: 32),
                        ReviewSection(
                          recipe: recipe,
                          onRateRecipe:
                              (rating, comment) =>
                                  recipeService.rateRecipe(recipe.id, rating),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 60),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Resep tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Resep yang Anda cari mungkin telah dihapus atau tidak tersedia.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                try {
                  context.pop();
                } catch (e) {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
