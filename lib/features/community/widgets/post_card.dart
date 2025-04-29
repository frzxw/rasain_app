import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/community_post.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  
  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    image: post.userImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(post.userImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: post.userImageUrl == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                
                const SizedBox(width: AppSizes.marginM),
                
                // User Name and Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDateTime(post.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // More Options
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),
          
          // Post Content
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              child: Text(
                post.content!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          
          // Post Image
          if (post.imageUrl != null)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconL,
                    ),
                  ),
                ),
              ),
            ),
          
          // Tagged Ingredients
          if (post.taggedIngredients != null && post.taggedIngredients!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Wrap(
                spacing: AppSizes.marginS,
                runSpacing: AppSizes.marginS,
                children: post.taggedIngredients!.map((ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ),
          
          // Post Category
          if (post.category != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: Chip(
                label: Text(post.category!),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          
          const Divider(),
          
          // Interactions (Like, Comment, Share)
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like Button
                _buildInteractionButton(
                  context,
                  icon: post.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: '${post.likeCount}',
                  onPressed: onLike,
                  isActive: post.isLiked,
                ),
                
                // Comment Button
                _buildInteractionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: '${post.commentCount}',
                  onPressed: onComment,
                ),
                
                // Share Button
                _buildInteractionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onPressed: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingS,
          horizontal: AppSizes.paddingM,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.marginS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
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
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
