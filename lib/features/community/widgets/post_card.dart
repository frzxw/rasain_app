import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/community_post.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  // Helper method untuk mendapatkan warna berdasarkan kategori
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kreasi':
        return Colors.purple;
      case 'tips & trik':
        return Colors.blue;
      case 'review':
        return Colors.orange;
      case 'resep':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.marginL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header with enhanced design
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Enhanced User Avatar with gradient border
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image:
                          post.userImageUrl != null
                              ? DecorationImage(
                                image: NetworkImage(post.userImageUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        post.userImageUrl == null
                            ? Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 24,
                            )
                            : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Enhanced User Name and Time with better typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userName,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (post.category != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(
                                  post.category!,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getCategoryColor(
                                    post.category!,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                post.category!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getCategoryColor(post.category!),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(post.timestamp),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Enhanced More Options with better design
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface.withOpacity(0.5),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      // Show options menu
                    },
                  ),
                ),
              ],
            ),
          ),
          // Enhanced Post Content with better spacing
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.content!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          // Enhanced Post Image with rounded corners
          if (post.imageUrl != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar tidak dapat dimuat',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ),
            ),
          // Enhanced Tagged Ingredients with better design
          if (post.taggedIngredients != null &&
              post.taggedIngredients!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_dining,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bahan:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        post.taggedIngredients!.map((ingredient) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

          // Enhanced Interactions with modern design
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Enhanced Like Button
                _buildInteractionButton(
                  context,
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _formatCount(post.likeCount),
                  onPressed: onLike,
                  isActive: post.isLiked,
                  activeColor: Colors.red,
                ),

                // Enhanced Comment Button
                _buildInteractionButton(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: _formatCount(post.commentCount),
                  onPressed: onComment,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk format angka
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildInteractionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? activeColor,
  }) {
    final color =
        isActive ? (activeColor ?? AppColors.primary) : AppColors.textSecondary;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('d MMM yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'hari' : 'hari'} lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'jam' : 'jam'} lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'menit' : 'menit'} lalu';
    } else {
      return 'Baru saja';
    }
  }
}
