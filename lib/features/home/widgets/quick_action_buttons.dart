import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class QuickActionButtons extends StatefulWidget {
  const QuickActionButtons({super.key});

  @override
  State<QuickActionButtons> createState() => _QuickActionButtonsState();
}

class _QuickActionButtonsState extends State<QuickActionButtons>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _buttonControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    ); // Create individual controllers for each button
    _buttonControllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
    });

    // Create scale animations for each button
    _scaleAnimations =
        _buttonControllers.map((controller) {
          return Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList(); // Create slide animations for entrance
    _slideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: Offset(0, 0.5 + (index * 0.1)),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _buttonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onButtonPressed(int index) {
    _buttonControllers[index].forward().then((_) {
      _buttonControllers[index].reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      child: Column(
        children: [
          // Primary action row
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimations[0],
                child: Row(
                  children: [
                    // Upload Recipe Button - Full width
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _scaleAnimations[0],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimations[0].value,
                            child: _buildPrimaryActionCard(
                              context: context,
                              title: 'Upload Resep',
                              subtitle: 'Bagikan resep favoritmu',
                              icon: Icons.cloud_upload_rounded,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              ),
                              onTap: () {
                                _onButtonPressed(0);
                                context.push('/upload-recipe');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSizes.marginM),

          // Secondary actions row
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimations[1],
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _scaleAnimations[1],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimations[1].value,
                            child: _buildCompactActionCard(
                              context: context,
                                title: 'Dapur Saya',
                                icon: Icons.kitchen,
                                color: AppColors.primary,
                                onTap: () {
                                _onButtonPressed(1);
                                context.push('/pantry');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.marginS),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _scaleAnimations[2],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimations[2].value,
                            child: _buildCompactActionCard(
                              context: context,
                              title: 'Favorit',
                              icon: Icons.favorite_rounded,
                              color: AppColors.primary,
                              onTap: () {
                                _onButtonPressed(2);
                                context.push('/profile');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Further reduced to prevent overflow
        padding: const EdgeInsets.all(AppSizes.paddingS), // Reduced padding
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Added for better spacing
          children: [
            // Icon with animated background
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(
                    AppSizes.paddingS,
                  ), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2 + (value * 0.1)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24, // Reduced icon size
                  ),
                );
              },
            ),

            // Text content with proper spacing
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Added to prevent overflow
              children: [
                // Title with shader effect
                ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontSize: 14, // Further reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 1), // Reduced spacing
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 11, // Further reduced font size
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Container(
            height: 80,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, animValue, child) {
                    return Transform.scale(
                      scale: 0.8 + (animValue * 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSizes.marginM),
                // Text
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.6),
                  size: 14,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
