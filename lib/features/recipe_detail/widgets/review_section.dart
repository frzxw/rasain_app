import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/auth_dialog.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_service.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../cubits/auth/auth_state.dart';

class ReviewSection extends StatefulWidget {
  final Recipe recipe;
  final Function(double, String) onRateRecipe;

  const ReviewSection({
    super.key,
    required this.recipe,
    required this.onRateRecipe,
  });

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  double _userRating = 0;
  bool _hasRated = false;
  bool _showAllReviews = false;
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;
  final RecipeService _recipeService = RecipeService();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }
  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });    try {
      final reviews = await _recipeService.getRecipeReviews(widget.recipe.id);      // Check if current user has already reviewed this recipe
      final authState = context.read<AuthCubit>().state;
      bool userHasReviewed = false;

      if (authState.status == AuthStatus.authenticated) {
        final currentUserId = authState.user?.id;
        userHasReviewed = reviews.any(
          (review) => review['user_id'] == currentUserId,
        );
      }

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _hasRated = userHasReviewed;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState.status == AuthStatus.authenticated;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary
            _buildRatingSummary(context),

            const SizedBox(height: AppSizes.marginL),

            // Add Review Section
            if (isAuthenticated && !_hasRated)
              _buildAddReviewSection(context)
            else if (!isAuthenticated)
              _buildLoginPromptSection(context),

            const SizedBox(height: AppSizes.marginL),

            // Review List with real or sample review data
            _buildReviewsList(context),
          ],
        );
      },
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
              '${widget.recipe.reviewCount} ${widget.recipe.reviewCount == 1 ? 'ulasan' : 'ulasan'}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),

        const Spacer(),

        // Rating Distribution
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
          'Tambahkan Ulasan Anda',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXS,
                  ),
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

        // Rating description text based on selected rating
        if (_userRating > 0)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.paddingS),
              child: Text(
                _getRatingDescription(_userRating),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

        const SizedBox(height: AppSizes.marginM),

        // Review Text Input
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Bagikan pendapat Anda tentang resep ini...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: AppSizes.marginS),

        // Photo attachment option
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('Tambahkan Foto'),
              onPressed: () {
                // Add photo functionality would be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur tambah foto akan segera hadir'),
                  ),
                );
              },
            ),
            const Spacer(),
            Text(
              'Foto membantu pengguna lain!',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
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
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Kirim Ulasan'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPromptSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Masuk untuk Memberikan Ulasan',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Bagikan pengalaman Anda dengan resep ini dan bantu pengguna lain.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginM),
          ElevatedButton(
            onPressed: () {
              // Show login dialog instead of navigating to profile
              AuthDialog.showLoginDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
                vertical: AppSizes.paddingM,
              ),
            ),
            child: const Text('Masuk'),
          ),
        ],
      ),
    );
  }

  String _getRatingDescription(double rating) {
    if (rating == 5) return 'Sangat Bagus!';
    if (rating == 4) return 'Bagus';
    if (rating == 3) return 'Biasa Saja';
    if (rating == 2) return 'Kurang Bagus';
    return 'Kecewa';
  }

  Widget _buildReviewsList(BuildContext context) {
    if (_isLoadingReviews) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ulasan Terbaru',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.marginM),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      );
    }

    final reviews = _reviews;
    final displayReviews = _showAllReviews ? reviews : reviews.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ulasan Terbaru',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (reviews.isNotEmpty)
              Text(
                '${reviews.length} ulasan',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.marginM),

        reviews.isNotEmpty
            ? Column(
              children: [
                ...displayReviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.marginM),
                    child: _buildReviewItem(review),
                  ),
                ),

                // Show More Reviews Button
                if (reviews.length > 2 && !_showAllReviews)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.paddingS),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showAllReviews = true;
                          });
                        },
                        child: Text('Lihat Semua ${reviews.length} Ulasan'),
                      ),
                    ),
                  )
                else if (_showAllReviews && reviews.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.paddingS),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showAllReviews = false;
                          });
                        },
                        child: const Text('Sembunyikan'),
                      ),
                    ),
                  ),
              ],
            )
            : _buildEmptyReviewsState(context),
      ],
    );
  }  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = review['rating']?.toDouble() ?? 0.0;
    final reviewText =
        review['comment'] ?? review['review_text'] ?? 'Tidak ada komentar';
    final createdAt = review['date'] ?? review['created_at'] ?? '';    final userId = review['user_id'] ?? '';
    final userName = review['user_name'] ?? 'User ${userId.length > 8 ? userId.substring(0, 8) : userId}';
    final userImage = review['user_image'];

    // Format date
    String formattedDate = 'Tidak diketahui';
    if (createdAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(dateTime);

        if (difference.inDays > 0) {
          formattedDate = '${difference.inDays} hari yang lalu';
        } else if (difference.inHours > 0) {
          formattedDate = '${difference.inHours} jam yang lalu';
        } else if (difference.inMinutes > 0) {
          formattedDate = '${difference.inMinutes} menit yang lalu';
        } else {
          formattedDate = 'Baru saja';
        }
      } catch (e) {
        formattedDate = createdAt;
      }
    }

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
            children: [              // User Avatar with profile image
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: userImage != null && userImage.isNotEmpty 
                    ? NetworkImage(userImage) 
                    : null,
                child: userImage == null || userImage.isEmpty
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: AppSizes.marginM),

              // User Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        _buildStarRating(rating),
                        const SizedBox(width: AppSizes.marginS),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (reviewText.isNotEmpty && reviewText != 'Tidak ada komentar') ...[
            const SizedBox(height: AppSizes.marginM),
            // Review Comment
            Text(reviewText, style: Theme.of(context).textTheme.bodyMedium),
          ],
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
            'Belum ada ulasan',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Jadilah yang pertama mengulas resep ini',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _submitReview() async {
    // Check if user is authenticated first
    final authState = context.read<AuthCubit>().state;
    if (authState.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus masuk untuk memberikan ulasan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty && _userRating <= 0) {
      // Show error for empty submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon berikan rating dan ulasan Anda'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_userRating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon berikan rating untuk resep ini'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Submit review to Supabase
      final success = await _recipeService.submitRecipeReview(
        widget.recipe.id,
        _userRating,
        _reviewController.text.trim(),
      );

      if (!success) {
        throw Exception('Gagal mengirim ulasan');
      } // Call the callback to rate the recipe (for updating local state)
      widget.onRateRecipe(_userRating, _reviewController.text.trim());

      // Reload reviews to show the new/updated one
      await _loadReviews();

      // Don't set _hasRated = true if we want to allow review updates
      // Instead, check if current user has reviewed after reloading
      final authState = context.read<AuthCubit>().state;
      if (authState.status == AuthStatus.authenticated) {
        final currentUserId = authState.user?.id;
        final userHasReviewed = _reviews.any(
          (review) => review['user_id'] == currentUserId,
        );

        setState(() {
          _hasRated = userHasReviewed;
          _reviewController.clear();
          _userRating = 0;
        });
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _hasRated
                  ? 'Ulasan Anda telah diperbarui!'
                  : 'Terima kasih atas ulasan Anda!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
