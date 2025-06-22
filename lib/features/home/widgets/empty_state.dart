import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionTap;
  final String? actionText;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onActionTap,
    this.actionText,
    this.iconColor,
  });

  // Factory constructors for common empty states
  factory EmptyState.noRecipes({VoidCallback? onUploadTap}) {
    return EmptyState(
      title: 'Belum ada resep',
      subtitle: 'Mulai berbagi resep favoritmu dengan komunitas',
      icon: Icons.restaurant_menu,
      iconColor: AppColors.primary,
      onActionTap: onUploadTap,
      actionText: 'Upload Resep',
    );
  }

  factory EmptyState.noSearchResults({
    required String query,
    VoidCallback? onClearTap,
  }) {
    return EmptyState(
      title: 'Tidak ditemukan',
      subtitle: 'Tidak ada resep yang cocok dengan "$query"',
      icon: Icons.search_off,
      iconColor: AppColors.textSecondary,
      onActionTap: onClearTap,
      actionText: 'Coba kata kunci lain',
    );
  }

  factory EmptyState.noFavorites({VoidCallback? onExploreTap}) {
    return EmptyState(
      title: 'Belum ada favorit',
      subtitle: 'Tandai resep yang kamu suka untuk mudah ditemukan nanti',
      icon: Icons.favorite_border,
      iconColor: AppColors.highlight,
      onActionTap: onExploreTap,
      actionText: 'Jelajahi Resep',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSizes.marginL),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.marginS),

          // Subtitle
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Action Button
          if (onActionTap != null && actionText != null) ...[
            const SizedBox(height: AppSizes.marginXL),
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor ?? AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXL,
                  vertical: AppSizes.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                elevation: 0,
              ),
              child: Text(
                actionText!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
