import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';

class ReviewSection extends StatefulWidget {
  final Recipe recipe;
  final Function(double) onRateRecipe;
  
  const ReviewSection({
    Key? key,
    required this.recipe,
    required this.onRateRecipe,
  }) : super(key: key);

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  double _userRating = 0;
  bool _hasRated = false;
  final TextEditingController _reviewController = TextEditingController();
  
  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        _buildRatingSummary(context),
        
        const SizedBox(height: AppSizes.marginL),
        
        // Add Review Section
        if (!_hasRated) _buildAddReviewSection(context),
        
        const SizedBox(height: AppSizes.marginL),
        
        // Review List (would be implemented with actual review data)
        _buildReviewsList(context),
      ],
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    return Row(
      children: [
        // Average Rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.recipe.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ 5.0',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.marginXS),
            _buildStarRating(widget.recipe.rating),
            const SizedBox(height: AppSizes.marginXS),
            Text(
              '${widget.recipe.reviewCount} ${widget.recipe.reviewCount == 1 ? 'review' : 'reviews'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Rating Distribution (simplified for this implementation)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildRatingBar(context, 5, 0.6),
            _buildRatingBar(context, 4, 0.2),
            _buildRatingBar(context, 3, 0.1),
            _buildRatingBar(context, 2, 0.05),
            _buildRatingBar(context, 1, 0.05),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBar(BuildContext context, int stars, double fraction) {
    return Row(
      children: [
        Text(
          '$stars',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.star,
          size: AppSizes.iconXS,
          color: AppColors.highlight,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 100,
          height: 6,
          child: Stack(
            children: [
              // Background
              Container(
                width: 100,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Fill
              Container(
                width: 100 * fraction,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.highlight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${(fraction * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            size: AppSizes.iconS,
            color: AppColors.highlight,
          );
        } else if (index == rating.floor() && rating % 1 != 0) {
          return const Icon(
            Icons.star_half,
            size: AppSizes.iconS,
            color: AppColors.highlight,
          );
        } else {
          return const Icon(
            Icons.star_border,
            size: AppSizes.iconS,
            color: AppColors.highlight,
          );
        }
      }),
    );
  }

  Widget _buildAddReviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Your Review',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.marginM),
        
        // Star Rating Selection
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _userRating = starValue.toDouble();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXS),
                  child: Icon(
                    starValue <= _userRating ? Icons.star : Icons.star_border,
                    size: 36,
                    color: AppColors.highlight,
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: AppSizes.marginM),
        
        // Review Text Input
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Write your review...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
          maxLines: 3,
        ),
        
        const SizedBox(height: AppSizes.marginM),
        
        // Submit Button
        Center(
          child: ElevatedButton(
            onPressed: _userRating > 0 ? _submitReview : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
            ),
            child: const Text('Submit Review'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList(BuildContext context) {
    // This would be replaced with actual review data in a real app
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reviews',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.marginM),
        
        widget.recipe.reviewCount > 0
            ? Column(
                children: [
                  _buildReviewItem(
                    userName: 'Sarah Johnson',
                    rating: 5.0,
                    date: '2 days ago',
                    comment: 'This recipe was absolutely amazing! The flavors were perfect and it was so easy to make. My family loved it and asked for seconds.',
                  ),
                  const SizedBox(height: AppSizes.marginM),
                  _buildReviewItem(
                    userName: 'Michael Lee',
                    rating: 4.0,
                    date: '1 week ago',
                    comment: 'Very good recipe overall. I added a bit more garlic and some chili flakes for extra flavor.',
                  ),
                  
                  // Show More Reviews Button
                  if (widget.recipe.reviewCount > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.paddingM),
                      child: TextButton(
                        onPressed: () {
                          // Show more reviews
                        },
                        child: Text('View All ${widget.recipe.reviewCount} Reviews'),
                      ),
                    ),
                ],
              )
            : _buildEmptyReviewsState(context),
      ],
    );
  }

  Widget _buildReviewItem({
    required String userName,
    required double rating,
    required String date,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.marginXS),
          
          // Star Rating
          _buildStarRating(rating),
          
          const SizedBox(height: AppSizes.marginS),
          
          // Review Comment
          Text(
            comment,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: AppSizes.iconL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Be the first to review this recipe',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _submitReview() {
    // Call the callback to rate the recipe
    widget.onRateRecipe(_userRating);
    
    // Reset form and update state
    setState(() {
      _hasRated = true;
      _reviewController.clear();
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your review!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
