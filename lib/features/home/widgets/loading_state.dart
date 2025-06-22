import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import 'cooking_animation.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  final bool showAnimation;

  const LoadingState({super.key, this.message, this.showAnimation = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cooking Animation or Simple Loading
            if (showAnimation)
              const CookingAnimation(size: 150)
            else
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

            const SizedBox(height: AppSizes.marginL),

            // Loading Message
            Text(
              message ?? 'Sedang menyiapkan resep lezat...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSizes.marginS),

            // Loading dots animation
            _buildLoadingDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(value),
                shape: BoxShape.circle,
              ),
            );
          },
          onEnd: () {
            // Restart animation
          },
        );
      }),
    );
  }
}
