import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../services/recipe_service.dart';
import '../../cubits/notification/notification_cubit.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../models/recipe.dart';
import 'widgets/ingredient_list.dart';
import 'widgets/instruction_steps.dart';
import 'widgets/review_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String? recipeId;
  final String? recipeSlug;

  const RecipeDetailScreen({super.key, this.recipeId, this.recipeSlug})
    : assert(
        recipeId != null || recipeSlug != null,
        'Either recipeId or recipeSlug must be provided',
      );

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _currentStep = 0; // For tracking current instruction step
  bool _cookingMode = false; // Flag for step-by-step cooking mode
  @override
  void initState() {
    super.initState(); // Load recipe details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeService = Provider.of<RecipeService>(context, listen: false);

      // Use the combined fetch method that handles both slug and ID
      final identifier = widget.recipeSlug ?? widget.recipeId!;
      recipeService.fetchRecipeBySlug(identifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<RecipeService>(
        builder: (context, recipeService, _) {
          final recipe = recipeService.currentRecipe;
          final isLoading = recipeService.isLoading;

          // Debug print untuk melihat data instruksi
          if (recipe != null) {
            print('🍽️ Recipe loaded: ${recipe.name}');
            print('📋 Instructions count: ${recipe.instructions?.length ?? 0}');
            if (recipe.instructions != null &&
                recipe.instructions!.isNotEmpty) {
              print('📝 First instruction: ${recipe.instructions!.first}');
            } else {
              print('❌ No instructions found for recipe');
            }
          }

          if (isLoading && recipe == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (recipe == null) {
            return _buildErrorState();
          }

          return _cookingMode &&
                  recipe.instructions != null &&
                  recipe.instructions!.isNotEmpty
              ? _buildCookingMode(context, recipe, recipeService)
              : _buildRecipeContent(context, recipe, recipeService);
        },
      ),
    );
  }

  Widget _buildRecipeContent(
    BuildContext context,
    Recipe recipe,
    RecipeService recipeService,
  ) {
    return CustomScrollView(
      slivers: [
        // Enhanced App Bar with Recipe Image
        SliverAppBar(
          expandedHeight: 300,
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
                context.go('/welcome');
              }
            },
          ),
          actions: [
            // Enhanced Bookmark Button with Animation
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      recipe.isSaved
                          ? AppColors.highlight.withOpacity(0.2)
                          : Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: recipe.isSaved ? AppColors.highlight : Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () async {
                final wasSaved = recipe.isSaved;

                // Use RecipeCubit instead of calling service directly
                await context.read<RecipeCubit>().toggleSavedRecipe(recipe.id);

                // Refresh liked recipes to ensure profile page is updated
                await context.read<RecipeCubit>().getLikedRecipes();

                // Trigger notification
                final notificationCubit = context.read<NotificationCubit>();
                if (!wasSaved) {
                  await notificationCubit.notifyRecipeSaved(
                    recipe.name,
                    context: context,
                    recipeId: recipe.id,
                  );
                } else {
                  await notificationCubit.notifyRecipeRemoved(
                    recipe.name,
                    context: context,
                    recipeId: recipe.id,
                  );
                }
              },
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Enhanced Recipe Image with Hero Animation
                Hero(
                  tag: 'recipe-${recipe.id}',
                  child:
                      recipe.imageUrl != null
                          ? Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                ),
                          )
                          : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                ),

                // Enhanced Gradient Overlay
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black26,
                        Colors.black54,
                      ],
                      stops: [0.5, 0.8, 1.0],
                    ),
                  ),
                ),

                // Recipe Title at Bottom
                Positioned(
                  left: AppSizes.paddingM,
                  right: AppSizes.paddingM,
                  bottom: AppSizes.paddingM,
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Recipe Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Summary
                _buildRecipeSummary(context, recipe),
                const SizedBox(height: AppSizes.marginL),

                // Enhanced Ingredients Section
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSizes.marginM),
                          Text(
                            'Bahan-bahan',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (recipe.ingredients != null) ...[
                        const SizedBox(height: AppSizes.marginM),
                        IngredientList(ingredients: recipe.ingredients!),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.marginL),

                // Enhanced Instructions Section
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.format_list_numbered,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSizes.marginM),
                              Text(
                                'Langkah-langkah',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          if (recipe.instructions != null &&
                              recipe.instructions!.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Mode Memasak',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingL,
                                    vertical: AppSizes.paddingM,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _cookingMode = true;
                                    _currentStep = 0;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                      if (recipe.instructions != null) ...[
                        const SizedBox(height: AppSizes.marginM),
                        InstructionSteps(
                          instructions: recipe.instructions!,
                          onStartCooking: () {
                            setState(() {
                              _cookingMode = true;
                              _currentStep = 0;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.marginL),

                // Enhanced Review Section
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.star_outline,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSizes.marginM),
                          Text(
                            'Ulasan & Rating',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.marginM),
                      ReviewSection(
                        recipe: recipe,
                        onRateRecipe:
                            (rating, comment) =>
                                recipeService.rateRecipe(recipe.id, rating),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.marginXL),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCookingMode(
    BuildContext context,
    Recipe recipe,
    RecipeService recipeService,
  ) {
    final steps = recipe.instructions!;
    final currentStep = steps[_currentStep];
    final stepText = currentStep['text'] ?? '';
    final videoUrl = currentStep['videoUrl'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // Header with navigation
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _cookingMode = false;
                    });
                  },
                ),
                Text(
                  'Langkah ${_currentStep + 1}/${steps.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_currentStep > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                  ),
                if (_currentStep < steps.length - 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      setState(() {
                        _currentStep++;
                      });
                    },
                  ),
              ],
            ),

            const Divider(),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe name as reference
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSizes.marginM),

                    // Step number
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_currentStep + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.marginM),

                    // Step instruction
                    Text(
                      stepText,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: AppSizes.marginL),

                    // Video if available
                    if (videoUrl != null && videoUrl.isNotEmpty)
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: AppColors.surface,
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Putar Video'),
                            onPressed: () {
                              // Launch video in external player or expand in app
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Sebelumnya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                    )
                  else
                    const SizedBox.shrink(),

                  _currentStep < steps.length - 1
                      ? ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Selanjutnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentStep++;
                          });
                        },
                      )
                      : ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Selesai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _cookingMode = false;
                          });

                          // Show dialog inviting to rate the recipe
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Selamat!'),
                                  content: const Text(
                                    'Anda telah berhasil menyelesaikan resep ini. Bagaimana hasilnya? Beri rating untuk resep ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Nanti'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Scroll to review section
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              Scrollable.ensureVisible(
                                                context,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            });
                                      },
                                      child: const Text('Beri Rating'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSummary(BuildContext context, Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.primary.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Description with Icon
          if (recipe.description != null && recipe.description!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.marginM),
                  Expanded(
                    child: Text(
                      recipe.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSizes.marginL),

          // Enhanced Recipe Info Cards
          Row(
            children: [
              // Cook Time Card
              if (recipe.cookTime != null)
                Expanded(
                  child: _buildEnhancedInfoCard(
                    context,
                    icon: Icons.timer_outlined,
                    label: 'Waktu',
                    value: '${recipe.cookTime} menit',
                    color: Colors.orange,
                  ),
                ),

              if (recipe.cookTime != null && recipe.servings != null)
                const SizedBox(width: AppSizes.marginM),

              // Servings Card
              if (recipe.servings != null)
                Expanded(
                  child: _buildEnhancedInfoCard(
                    context,
                    icon: Icons.people_outline,
                    label: 'Porsi',
                    value: '${recipe.servings}',
                    color: Colors.blue,
                  ),
                ),

              if ((recipe.cookTime != null || recipe.servings != null) &&
                  recipe.estimatedCost != null)
                const SizedBox(width: AppSizes.marginM),

              // Estimated Cost Card
              if (recipe.estimatedCost != null)
                Expanded(
                  child: _buildEnhancedInfoCard(
                    context,
                    icon: Icons.attach_money,
                    label: 'Biaya',
                    value: 'Rp ${recipe.estimatedCost!}',
                    color: Colors.green,
                  ),
                ),
            ],
          ),

          // Difficulty Level Section
          if (recipe.difficultyLevel != null) ...[
            const SizedBox(height: AppSizes.marginL),
            Row(
              children: [
                Icon(Icons.speed_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSizes.marginS),
                Text(
                  'Tingkat Kesulitan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.marginM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: _getDifficultyColor(
                  recipe.difficultyLevel!,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getDifficultyColor(
                    recipe.difficultyLevel!,
                  ).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDifficultyIcon(recipe.difficultyLevel!),
                    color: _getDifficultyColor(recipe.difficultyLevel!),
                    size: 18,
                  ),
                  const SizedBox(width: AppSizes.marginS),
                  Text(
                    recipe.difficultyLevel!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getDifficultyColor(recipe.difficultyLevel!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Enhanced Categories Section
          if (recipe.categories != null && recipe.categories!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.marginL),
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.marginS),
                Text(
                  'Kategori',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.marginM),
            Wrap(
              spacing: AppSizes.marginS,
              runSpacing: AppSizes.marginS,
              children:
                  recipe.categories!.map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Resep tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              'Resep yang Anda cari mungkin telah dihapus atau tidak tersedia.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            ElevatedButton.icon(
              onPressed: () {
                // Check if we can go back in history
                try {
                  context.pop();
                } catch (e) {
                  // If we can't pop, try to explicitly navigate to welcome screen
                  context.go('/welcome');
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

  // Helper methods for difficulty level styling
  Color _getDifficultyColor(String difficultyLevel) {
    switch (difficultyLevel.toLowerCase()) {
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

  IconData _getDifficultyIcon(String difficultyLevel) {
    switch (difficultyLevel.toLowerCase()) {
      case 'mudah':
        return Icons.sentiment_satisfied;
      case 'sedang':
        return Icons.sentiment_neutral;
      case 'sulit':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.speed;
    }
  }
}
