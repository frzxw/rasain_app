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
  
  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
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
      backgroundColor: AppColors.background,
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
          
          return _buildRecipeContent(context, recipe, recipeService);
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
                  'Ingredients',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.marginM),
                if (recipe.ingredients != null)
                  IngredientList(ingredients: recipe.ingredients!),
                
                const SizedBox(height: AppSizes.marginL),
                
                // Instructions Section
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.marginM),
                if (recipe.instructions != null)
                  InstructionSteps(instructions: recipe.instructions!),
                
                const SizedBox(height: AppSizes.marginL),
                
                // Review Section
                Text(
                  'Reviews & Ratings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.marginM),
                ReviewSection(
                  recipe: recipe,
                  onRateRecipe: (rating) => recipeService.rateRecipe(recipe.id, rating),
                ),
                
                const SizedBox(height: AppSizes.marginXL),
              ],
            ),
          ),
        ),
      ],
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
                label: 'Cook Time',
                value: recipe.cookTime!,
              ),
            
            // Servings
            if (recipe.servings != null)
              _buildInfoItem(
                context,
                icon: Icons.people_outline,
                label: 'Servings',
                value: '${recipe.servings}',
              ),
            
            // Estimated Cost
            if (recipe.estimatedCost != null)
              _buildInfoItem(
                context,
                icon: Icons.attach_money,
                label: 'Est. Cost',
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
              'Recipe not found',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              'The recipe you\'re looking for might have been removed or is unavailable.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
