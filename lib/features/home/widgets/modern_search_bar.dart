import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class ModernSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;
  final VoidCallback? onCameraTap;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.onFilterTap,
    this.hasActiveFilters = false,
    this.onCameraTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ), // Added border for visibility
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.15,
            ), // Increased shadow for visibility
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search TextField
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Cari resep, bahan, atau chef...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color:
                      AppColors
                          .primary, // Changed to primary color for visibility
                  size: 24, // Increased size
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingM,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Camera Search Button
          if (onCameraTap != null)
            _buildActionButton(
              icon: Icons.camera_alt,
              onTap: onCameraTap!,
              color: AppColors.success,
            ),

          // Filter Button
          if (onFilterTap != null)
            _buildActionButton(
              icon: Icons.tune,
              onTap: onFilterTap!,
              color:
                  hasActiveFilters
                      ? AppColors.primary
                      : AppColors.textSecondary,
              isActive: hasActiveFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSizes.paddingS),
        padding: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Icon(icon, color: color, size: 20),
            if (isActive)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
