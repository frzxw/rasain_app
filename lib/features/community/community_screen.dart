import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/community_post.dart';
import '../../cubits/community/community_cubit.dart';
import '../../cubits/community/community_state.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'widgets/post_card.dart';
import 'widgets/filter_tags.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize community posts using CommunityCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BlocConsumer<CommunityCubit, CommunityState>(
        listener: (context, state) {
          // Handle any errors with snackbar or dialog if needed
          if (state.status == CommunityStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Enhanced Filter Tags with background
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FilterTags(
                  tags: state.categories,
                  selectedTag: state.selectedCategory ?? 'Semua',
                  onTagSelected: (tag) {
                    context.read<CommunityCubit>().filterByCategory(tag);
                  },
                ),
              ),

              // Post List with enhanced spacing
              Expanded(
                child:
                    state.status == CommunityStatus.loading &&
                            state.posts.isEmpty
                        ? _buildLoadingState()
                        : state.status == CommunityStatus.error
                        ? _buildErrorState(state.errorMessage)
                        : state.posts.isEmpty
                        ? _buildEmptyState(state.selectedCategory ?? 'Semua')
                        : RefreshIndicator(
                          onRefresh: () async {
                            return context.read<CommunityCubit>().initialize();
                          },
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.posts.length,
                            itemBuilder: (context, index) {
                              final post = state.posts[index];                              return PostCard(
                                post: post,
                                onLike: () => _handleLikePost(post.id),
                                onComment: () => _handleCommentPost(post),
                                onShare: () => _sharePost(post),
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showCreatePostDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat postingan...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Terjadi kesalahan',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Gagal memuat postingan komunitas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomButton(
                  label: 'Coba Lagi',
                  icon: Icons.refresh,
                  onPressed: () => context.read<CommunityCubit>().initialize(),
                  variant: ButtonVariant.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String selectedCategory) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                selectedCategory == 'Semua'
                    ? 'Belum ada postingan'
                    : 'Belum ada postingan di $selectedCategory',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                selectedCategory == 'Semua'
                    ? 'Jadilah yang pertama berbagi pengalaman memasak Anda!'
                    : 'Coba kategori lain atau jadilah yang pertama posting di sini',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomButton(
                  label: 'Buat Postingan',
                  icon: Icons.add,
                  onPressed: _showCreatePostDialog,
                  variant: ButtonVariant.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Like functionality is now handled directly by CommunityCubit.toggleLikePost

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
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                        AppSizes.paddingM,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tambahkan komentar...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusL,
                              ),
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
                        icon: const Icon(Icons.send, color: AppColors.primary),
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
    // Check if user is authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState.status != AuthStatus.authenticated) {
      // Show login dialog if user is not authenticated
      _showLoginPrompt();
      return;
    }

    final TextEditingController contentController = TextEditingController();
    String? selectedCategory;
    List<String> selectedIngredients = [];
    XFile? selectedImage;

    // Updated with Indonesian ingredients
    final availableIngredients = [
      'Beras',
      'Cabai Merah',
      'Cabai Rawit',
      'Bawang Merah',
      'Bawang Putih',
      'Daging Sapi',
      'Ayam',
      'Telur',
      'Kecap Manis',
      'Santan',
      'Tempe',
      'Terasi',
    ];

    // Updated with Indonesian cuisine categories
    final availableCategories = [
      'Makanan Utama',
      'Pedas',
      'Tradisional',
      'Sup',
      'Daging',
      'Manis',
      'Minuman',
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
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusS,
                                    ),
                                    color: AppColors.surface,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusS,
                                    ),
                                    child: Image.asset(
                                      'path_to_placeholder', // This would be a FutureBuilder with Image.memory in a real app
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => const Icon(
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
                      items:
                          availableCategories.map((category) {
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
                      children:
                          availableIngredients.map((ingredient) {
                            final isSelected = selectedIngredients.contains(
                              ingredient,
                            );
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
                                content: Text(
                                  'Mohon tambahkan teks atau gambar pada postingan Anda',
                                ),
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
    ); // Refresh posts after creating a new one
    context.read<CommunityCubit>().initialize();
  }  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        title: Row(
          children: [
            Icon(
              Icons.login,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Login Diperlukan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Anda perlu masuk terlebih dahulu untuk membuat postingan di komunitas.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Nanti',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog first
              // Navigate using GoRouter
              context.go('/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Masuk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle like post with authentication check
  void _handleLikePost(String postId) {
    final authState = context.read<AuthCubit>().state;
    if (authState.status != AuthStatus.authenticated) {
      _showLoginPrompt();
      return;
    }
    
    // User is authenticated, proceed with like
    context.read<CommunityCubit>().toggleLikePost(postId);
  }

  // Handle comment post with authentication check
  void _handleCommentPost(CommunityPost post) {
    final authState = context.read<AuthCubit>().state;
    if (authState.status != AuthStatus.authenticated) {
      _showLoginPrompt();
      return;
    }
    
    // User is authenticated, proceed with showing comments
    _showComments(post);
  }
}
