import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../services/recipe_service.dart';
import '../../models/recipe.dart';
import 'widgets/ingredient_list.dart';
import 'widgets/instruction_steps.dart';
import 'widgets/review_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final String? recipeSlug; // Added support for recipe slug
  
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.recipeSlug,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _currentStep = 0; // For tracking current instruction step
  bool _cookingMode = false; // Flag for step-by-step cooking mode
  
  @override
  void initState() {
    super.initState();
    // Load recipe details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      recipeService.fetchRecipeById(widget.recipeId);
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
          
          return _cookingMode && recipe.instructions != null && recipe.instructions!.isNotEmpty
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
        // App Bar with Recipe Image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              ),
              child: const Icon(Icons.arrow_back_ios, size: AppSizes.iconS),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Share Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
                ),
                child: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: AppSizes.iconM,
                ),
              ),
              onPressed: () {
                // Share functionality would be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membagikan resep: ${recipe.name}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            
            // Bookmark Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
                ),
                child: Icon(
                  recipe.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: recipe.isSaved ? AppColors.highlight : Colors.white,
                  size: AppSizes.iconM,
                ),
              ),
              onPressed: () => recipeService.toggleSaveRecipe(recipe.id),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Recipe Image
                recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primary,
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                
                // Gradient Overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                      stops: [0.7, 1.0],
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
                
                // Ingredients Section
                Text(
                  'Bahan-bahan',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.marginM),
                if (recipe.ingredients != null)
                  IngredientList(ingredients: recipe.ingredients!),
                
                const SizedBox(height: AppSizes.marginL),
                
                // Instructions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Langkah-langkah',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (recipe.instructions != null && recipe.instructions!.isNotEmpty)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Mode Memasak'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _cookingMode = true;
                            _currentStep = 0;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.marginM),
                if (recipe.instructions != null)
                  InstructionSteps(instructions: recipe.instructions!),
                
                const SizedBox(height: AppSizes.marginL),
                
                // Review Section
                Text(
                  'Ulasan & Rating',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.marginM),
                ReviewSection(
                  recipe: recipe,
                  onRateRecipe: (rating, comment) => recipeService.rateRecipe(recipe.id, rating),
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
                              builder: (context) => AlertDialog(
                                title: const Text('Selamat!'),
                                content: const Text(
                                  'Anda telah berhasil menyelesaikan resep ini. Bagaimana hasilnya? Beri rating untuk resep ini?'
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
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        Scrollable.ensureVisible(
                                          context,
                                          duration: const Duration(milliseconds: 300),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (recipe.description != null && recipe.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
            child: Text(
              recipe.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        
        // Recipe Info Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Cook Time
            if (recipe.cookTime != null)
              _buildInfoItem(
                context,
                icon: Icons.access_time,
                label: 'Waktu Masak',
                value: recipe.cookTime!,
              ),
            
            // Servings
            if (recipe.servings != null)
              _buildInfoItem(
                context,
                icon: Icons.people_outline,
                label: 'Porsi',
                value: '${recipe.servings}',
              ),
            
            // Estimated Cost
            if (recipe.estimatedCost != null)
              _buildInfoItem(
                context,
                icon: Icons.currency_exchange,
                label: 'Estimasi Biaya',
                value: recipe.estimatedCost!,
              ),
          ],
        ),
        
        // Categories
        if (recipe.categories != null && recipe.categories!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.paddingM),
            child: Wrap(
              spacing: AppSizes.marginS,
              runSpacing: AppSizes.marginS,
              children: recipe.categories!.map((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor: AppColors.surface,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: AppSizes.iconM,
        ),
        const SizedBox(height: AppSizes.marginS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
