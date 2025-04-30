import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/custom_button.dart';
import '../../services/mock_api_service.dart';
import '../../models/community_post.dart';
import 'widgets/post_card.dart';
import 'widgets/filter_tags.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Updated with Indonesian cuisine categories
  final List<String> _tags = [
    'Semua', 'Makanan Utama', 'Pedas', 'Tradisional', 'Sup', 
    'Daging', 'Manis', 'Minuman'
  ];
  
  String _selectedTag = 'Semua';
  bool _isLoading = false;
  List<CommunityPost> _posts = [];
  String? _error;
  
  // Mock API service for post loading
  final MockApiService _apiService = MockApiService();

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final response = await _apiService.get(
        'community/posts',
        queryParams: _selectedTag != 'All' ? {'tag': _selectedTag} : null,
      );
      
      final posts = (response['posts'] as List)
          .map((post) => CommunityPost.fromJson(post))
          .toList();
      
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load posts. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Community',
      ),
      body: Column(
        children: [
          // Filter Tags
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            child: FilterTags(
              tags: _tags,
              selectedTag: _selectedTag,
              onTagSelected: (tag) {
                setState(() {
                  _selectedTag = tag;
                });
                _loadPosts();
              },
            ),
          ),
          
          // Post List
          Expanded(
            child: _isLoading && _posts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : _error != null
                    ? _buildErrorState()
                    : _posts.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadPosts,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSizes.paddingM),
                              itemCount: _posts.length,
                              itemBuilder: (context, index) {
                                return PostCard(
                                  post: _posts[index],
                                  onLike: () => _handleLikePost(_posts[index]),
                                  onComment: () => _showComments(_posts[index]),
                                  onShare: () => _sharePost(_posts[index]),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppSizes.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Oops! Terjadi kesalahan',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              _error ?? 'Gagal memuat postingan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            CustomButton(
              label: 'Coba Lagi',
              icon: Icons.refresh,
              onPressed: _loadPosts,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: AppSizes.iconXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              _selectedTag == 'Semua'
                  ? 'Belum ada postingan'
                  : 'Belum ada postingan di $_selectedTag',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              _selectedTag == 'Semua'
                  ? 'Jadilah yang pertama berbagi pengalaman memasak Anda!'
                  : 'Coba kategori lain atau jadilah yang pertama posting di sini',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.marginL),
            CustomButton(
              label: 'Buat Postingan',
              icon: Icons.add,
              onPressed: _showCreatePostDialog,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLikePost(CommunityPost post) async {
    try {
      await _apiService.post(
        'community/posts/${post.id}/like',
        body: {'is_liked': !post.isLiked},
      );
      
      // Optimistically update the post in the UI
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        final updatedPost = post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
        setState(() {
          _posts[index] = updatedPost;
        });
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui suka. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showComments(CommunityPost post) {
    // Implementation for showing comments would go here
    // This could be a bottom sheet or a new screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Komentar (${post.commentCount})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    itemCount: 0, // This would be replaced with actual comments
                    itemBuilder: (context, index) {
                      return const Center(
                        child: Text('Comments functionality coming soon'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.paddingM,
                    right: AppSizes.paddingM,
                    top: AppSizes.paddingM,
                    bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingM,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tambahkan komentar...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusL),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                              vertical: AppSizes.paddingS,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.marginM),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          // Send comment logic would go here
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _sharePost(CommunityPost post) {
    // Implementation for sharing a post would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membagikan postingan dari ${post.userName}...'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _showCreatePostDialog() async {
    final TextEditingController contentController = TextEditingController();
    String? selectedCategory;
    List<String> selectedIngredients = [];
    XFile? selectedImage;
    
    // Updated with Indonesian ingredients
    final availableIngredients = [
      'Beras', 'Cabai Merah', 'Cabai Rawit', 'Bawang Merah', 'Bawang Putih',
      'Daging Sapi', 'Ayam', 'Telur', 'Kecap Manis', 'Santan', 'Tempe', 'Terasi'
    ];
    
    // Updated with Indonesian cuisine categories
    final availableCategories = [
      'Makanan Utama', 'Pedas', 'Tradisional', 'Sup', 
      'Daging', 'Manis', 'Minuman'
    ];
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Buat Postingan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.marginM),
                    
                    // Post content
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Bagikan pengalaman masak Anda...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.marginM),
                    
                    // Image Selection
                    Row(
                      children: [
                        selectedImage != null
                            ? Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                      color: AppColors.surface,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                                      child: Image.asset(
                                        'path_to_placeholder', // This would be a FutureBuilder with Image.memory in a real app
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.image,
                                          size: AppSizes.iconL,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: AppColors.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : OutlinedButton.icon(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1000,
                                    maxHeight: 1000,
                                    imageQuality: 85,
                                  );
                                  
                                  if (image != null) {
                                    setState(() {
                                      selectedImage = image;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.image),
                                label: const Text('Tambah Foto'),
                              ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.marginM),
                    
                    // Category selection
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      hint: const Text('Pilih Kategori'),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      items: availableCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: AppSizes.marginM),
                    
                    // Ingredient Tags
                    Text(
                      'Tag Bahan-bahan',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSizes.marginS),
                    Wrap(
                      spacing: AppSizes.marginS,
                      runSpacing: AppSizes.marginS,
                      children: availableIngredients.map((ingredient) {
                        final isSelected = selectedIngredients.contains(ingredient);
                        return FilterChip(
                          label: Text(ingredient),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedIngredients.add(ingredient);
                              } else {
                                selectedIngredients.remove(ingredient);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: AppSizes.marginL),
                    
                    // Post Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'Kirim',
                        onPressed: () async {
                          // Validate form
                          if (contentController.text.trim().isEmpty &&
                              selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mohon tambahkan teks atau gambar pada postingan Anda'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          
                          // Create post logic would go here
                          
                          Navigator.pop(context, true);
                        },
                        variant: ButtonVariant.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    
    // Refresh posts after creating a new one
    _loadPosts();
  }
}
