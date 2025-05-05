import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../models/recipe.dart';
import '../../../core/widgets/custom_button.dart';

class Review {
  final String id;
  final String userName;
  final String userImage;
  final double rating;
  final String comment;
  final String date;
  final List<String>? images;
  
  Review({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
    this.images,
  });
}

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
  List<Review> _dummyReviews = [];
  
  @override
  void initState() {
    super.initState();
    _loadDummyReviews();
  }
  
  void _loadDummyReviews() {
    // Populate with sample reviews
    _dummyReviews = [
      Review(
        id: '1',
        userName: 'Sarah Johnson',
        userImage: 'https://randomuser.me/api/portraits/women/44.jpg',
        rating: 5.0,
        comment: 'Resep ini luar biasa enak! Rasanya sempurna dan sangat mudah dibuat. Keluarga saya menyukainya dan meminta tambahan.',
        date: '2 hari yang lalu',
        images: [
          'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8aW5kb25lc2lhbiUyMGZvb2R8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        ],
      ),
      Review(
        id: '2',
        userName: 'Michael Lee',
        userImage: 'https://randomuser.me/api/portraits/men/32.jpg',
        rating: 4.0,
        comment: 'Resep yang sangat baik secara keseluruhan. Saya menambahkan sedikit lebih banyak bawang putih dan cabai untuk rasa ekstra.',
        date: '1 minggu yang lalu',
      ),
      Review(
        id: '3',
        userName: 'Amanda Patel',
        userImage: 'https://randomuser.me/api/portraits/women/67.jpg',
        rating: 5.0,
        comment: 'Sempurna untuk makan malam keluarga! Semua orang menyukainya dan resepnya sangat mudah diikuti.',
        date: '2 minggu yang lalu',
        images: [
          'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8aW5kb25lc2lhbiUyMGZvb2R8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60'
        ],
      ),
      Review(
        id: '4',
        userName: 'David Wilson',
        userImage: 'https://randomuser.me/api/portraits/men/10.jpg',
        rating: 3.0,
        comment: 'Rasanya lumayan, tapi menurut saya butuh sedikit lebih banyak garam dan lada. Mungkin akan saya coba lagi dengan beberapa modifikasi.',
        date: '3 minggu yang lalu',
      ),
    ];
  }
  
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
        
        // Review List with real or sample review data
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
              '${widget.recipe.reviewCount} ${widget.recipe.reviewCount == 1 ? 'ulasan' : 'ulasan'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
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

  String _getRatingDescription(double rating) {
    if (rating == 5) return 'Sangat Bagus!';
    if (rating == 4) return 'Bagus';
    if (rating == 3) return 'Biasa Saja';
    if (rating == 2) return 'Kurang Bagus';
    return 'Kecewa';
  }

  Widget _buildReviewsList(BuildContext context) {
    final reviews = _dummyReviews;
    final displayReviews = _showAllReviews ? reviews : reviews.take(2).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ulasan Terbaru',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.marginM),
        
        reviews.isNotEmpty
            ? Column(
                children: [
                  ...displayReviews.map((review) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.marginM),
                    child: _buildReviewItem(review),
                  )),
                  
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
                  else if (_showAllReviews)
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
  }

  Widget _buildReviewItem(Review review) {
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
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.userImage),
                backgroundColor: AppColors.surface,
              ),
              
              const SizedBox(width: AppSizes.marginM),
              
              // User Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        _buildStarRating(review.rating),
                        const SizedBox(width: AppSizes.marginS),
                        Text(
                          review.date,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSizes.marginM),
          
          // Review Comment
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          // Review Images
          if (review.images != null && review.images!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.marginM),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: review.images!.map((imageUrl) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingS),
                      child: InkWell(
                        onTap: () {
                          // Show full-screen image
                          _showFullScreenImage(context, imageUrl);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          
          const SizedBox(height: AppSizes.marginS),
          
          // Helpful button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.thumb_up_outlined, size: AppSizes.iconS),
                label: const Text('Membantu'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terima kasih atas tanggapan Anda!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: 0,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Jadilah yang pertama mengulas resep ini',
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
    
    // Call the callback to rate the recipe
    widget.onRateRecipe(_userRating, _reviewController.text.trim());
    
    // Reset form and update state
    setState(() {
      _hasRated = true;
      _reviewController.clear();
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terima kasih atas ulasan Anda!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
