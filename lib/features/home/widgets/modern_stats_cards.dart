import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../services/supabase_service.dart';

class ModernStatsCards extends StatefulWidget {
  const ModernStatsCards({super.key});

  @override
  State<ModernStatsCards> createState() => _ModernStatsCardsState();
}

class _ModernStatsCardsState extends State<ModernStatsCards>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
  final SupabaseService _supabaseService = SupabaseService.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
        vsync: this,
      );
    });

    _scaleAnimations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          );
        }).toList();

    _fadeAnimations =
        _controllers.map((controller) {
          return Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
        }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Map<String, dynamic>> _getStatistics() async {
    try {
      // Get total recipe count
      final response = await _supabaseService.client
          .from('recipes')
          .select('rating')
          .order('created_at', ascending: false);

      final totalRecipes = response.length;

      // Calculate average rating
      double averageRating = 0.0;
      if (response.isNotEmpty) {
        final ratings =
            response
                .map<double>(
                  (recipe) => (recipe['rating'] as num?)?.toDouble() ?? 0.0,
                )
                .where((rating) => rating > 0)
                .toList();

        if (ratings.isNotEmpty) {
          averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
        }
      }

      // Get active chefs count (users who have created recipes)
      final chefsResponse = await _supabaseService.client
          .from('recipes')
          .select('created_by')
          .not('created_by', 'is', null);

      final activeChefs =
          chefsResponse.map((recipe) => recipe['created_by']).toSet().length;

      return {
        'totalRecipes': totalRecipes,
        'activeChefs': activeChefs,
        'averageRating': averageRating,
      };
    } catch (e) {
      print('❌ Error fetching statistics: $e');
      return {'totalRecipes': 0, 'activeChefs': 0, 'averageRating': 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Statistik Komunitas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.marginM),

          // Stats row with FutureBuilder for dynamic data
          FutureBuilder<Map<String, dynamic>>(
            future: _getStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              final stats =
                  snapshot.data ??
                  {'totalRecipes': 0, 'activeChefs': 0, 'averageRating': 0.0};

              final statsData = [
                {
                  'title': 'Total Resep',
                  'value': _formatNumber(stats['totalRecipes'] ?? 0),
                  'icon': Icons.restaurant_menu,
                  'color': const Color(0xFFE53E3E),
                  'gradient': [
                    const Color(0xFFE53E3E),
                    const Color(0xFFFC8181),
                  ],
                },
                {
                  'title': 'Chef Aktif',
                  'value': _formatNumber(stats['activeChefs'] ?? 0),
                  'icon': Icons.people,
                  'color': const Color(0xFFE53E3E),
                  'gradient': [
                    const Color(0xFFE53E3E),
                    const Color(0xFFFEB2B2),
                  ],
                },
                {
                  'title': 'Rating Rata-rata',
                  'value':
                      '${(stats['averageRating'] ?? 0.0).toStringAsFixed(1)}⭐',
                  'icon': Icons.star,
                  'color': const Color(0xFFE53E3E),
                  'gradient': [
                    const Color(0xFFE53E3E),
                    const Color(0xFFFED7D7),
                  ],
                },
              ];

              return Row(
                children:
                    statsData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> stat = entry.value;

                      return Expanded(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _scaleAnimations[index],
                            _fadeAnimations[index],
                          ]),
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimations[index],
                              child: ScaleTransition(
                                scale: _scaleAnimations[index],
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right:
                                        index < statsData.length - 1
                                            ? AppSizes.marginS
                                            : 0,
                                  ),
                                  child: _buildStatCard(stat),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? AppSizes.marginS : 0),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginM),
                  Container(
                    height: 20,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginXS),
                  Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 1),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(
              color: (stat['color'] as Color).withOpacity(0.2 + (value * 0.1)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (stat['color'] as Color).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.bounceOut,
                builder: (context, animValue, child) {
                  return Transform.scale(
                    scale: 0.8 + (animValue * 0.2),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.paddingS),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: stat['gradient']),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (stat['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(stat['icon'], color: Colors.white, size: 20),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSizes.marginM),

              // Value
              Text(
                stat['value'],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSizes.marginXS),

              // Title
              Text(
                stat['title'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
