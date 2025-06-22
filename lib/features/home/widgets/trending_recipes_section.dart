import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import 'trending_recipe_card.dart';

class TrendingRecipesSection extends StatefulWidget {
  const TrendingRecipesSection({super.key});

  @override
  State<TrendingRecipesSection> createState() => _TrendingRecipesSectionState();
}

class _TrendingRecipesSectionState extends State<TrendingRecipesSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _trendingRecipes = [
    {
      'id': 1,
      'name': 'Nasi Goreng Spesial',
      'chef': 'Sarah',
      'rating': 4.8,
      'time': 25,
      'image': null,
    },
    {
      'id': 2,
      'name': 'Ayam Bakar Bumbu Rujak',
      'chef': 'Ahmad',
      'rating': 4.9,
      'time': 45,
      'image': null,
    },
    {
      'id': 3,
      'name': 'Soto Ayam Lamongan',
      'chef': 'Budi',
      'rating': 4.7,
      'time': 60,
      'image': null,
    },
    {
      'id': 4,
      'name': 'Rendang Daging Sapi',
      'chef': 'Siti',
      'rating': 4.9,
      'time': 120,
      'image': null,
    },
    {
      'id': 5,
      'name': 'Gado-gado Jakarta',
      'chef': 'Rina',
      'rating': 4.6,
      'time': 20,
      'image': null,
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(),
                const SizedBox(height: AppSizes.marginM),
                _buildTrendingList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        // Fire icon with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF6B35), const Color(0xFFFF8A65)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: AppSizes.marginM),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [
                        const Color(0xFFFF6B35),
                        const Color(0xFFFF8A65),
                      ],
                    ).createShader(bounds),
                child: Text(
                  'Trending Sekarang',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Resep paling populer hari ini',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // See all button
        TextButton.icon(
          onPressed: () {
            // TODO: Navigate to trending page
          },
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          label: const Text('Lihat Semua'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children:
            _trendingRecipes.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> recipe = entry.value;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 500 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          TrendingRecipeCard(
                            recipe: Recipe.fromJson(recipe),
                            onTap: () {
                              // TODO: Navigate to recipe detail
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening ${recipe['name']}...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          if (index < _trendingRecipes.length - 1)
                            Divider(
                              height: 1,
                              color: AppColors.border.withOpacity(0.3),
                              indent: AppSizes.paddingL,
                              endIndent: AppSizes.paddingL,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }
}
