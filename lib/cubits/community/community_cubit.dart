import 'package:bloc/bloc.dart';
import '../../models/community_post.dart';
import '../../services/data_service.dart';
import '../../services/supabase_service.dart';
import 'dart:typed_data';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final DataService _dataService;
  final SupabaseService _supabaseService = SupabaseService.instance;

  CommunityCubit(this._dataService) : super(const CommunityState());  // Initialize and fetch community posts
  Future<void> initialize() async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      // Create test data if needed for debugging
      await _dataService.createTestDataIfNeeded();
      
      final posts = await _dataService.getCommunityPosts();

      // Extract all unique categories
      final categories = ['Semua'];
      for (var post in posts) {
        if (post.category != null && !categories.contains(post.category)) {
          categories.add(post.category!);
        }
      }

      emit(
        state.copyWith(
          posts: posts,
          allPosts: posts, // Store all posts for filtering
          categories: categories,
          selectedCategory: 'Semua',
          status: CommunityStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Filter posts by category
  void filterByCategory(String category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        status: CommunityStatus.loading,
      ),
    );

    try {
      final filteredPosts =
          category == 'Semua'
              ? state
                  .allPosts // Use allPosts instead of state.posts
              : state.allPosts
                  .where((post) => post.category == category)
                  .toList();

      emit(
        state.copyWith(
          selectedCategory: category,
          posts: filteredPosts,
          status: CommunityStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Like or unlike a post
  Future<void> toggleLikePost(String postId) async {
    // Find the post in both posts and allPosts
    final postsIndex = state.posts.indexWhere((p) => p.id == postId);
    final allPostsIndex = state.allPosts.indexWhere((p) => p.id == postId);

    if (postsIndex == -1 || allPostsIndex == -1) return;

    final post = state.posts[postsIndex];
    final isLiked = !post.isLiked;
    final newLikeCount = isLiked ? post.likeCount + 1 : post.likeCount - 1;

    // Update post locally first
    final updatedPost = post.copyWith(
      isLiked: isLiked,
      likeCount: newLikeCount,
    );

    final updatedPosts = List<CommunityPost>.from(state.posts);
    updatedPosts[postsIndex] = updatedPost;

    final updatedAllPosts = List<CommunityPost>.from(state.allPosts);
    updatedAllPosts[allPostsIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts, allPosts: updatedAllPosts));

    // Update in database (would be implemented in a real app)
    try {
      // await dataService.likePost(postId, isLiked);
    } catch (e) {
      // If there was an error, revert the change
      final revertedPosts = List<CommunityPost>.from(state.posts);
      revertedPosts[postsIndex] = post;

      final revertedAllPosts = List<CommunityPost>.from(state.allPosts);
      revertedAllPosts[allPostsIndex] = post;

      emit(
        state.copyWith(
          posts: revertedPosts,
          allPosts: revertedAllPosts,
          status: CommunityStatus.error,
          errorMessage: 'Failed to update like status: ${e.toString()}',
        ),
      );
    }
  }
  // Create a new community post
  Future<void> createPost({
    required String content,
    Uint8List? imageBytes,
    String? fileName,
    String? category,
    List<String>? taggedIngredients,
  }) async {
    emit(state.copyWith(status: CommunityStatus.posting));

    try {
      // Get current user
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to create posts');
      }

      // Get user profile for display name
      String userName = 'User';
      String? userImageUrl;
      
      try {
        final userProfile = await _supabaseService.client
            .from('user_profiles')
            .select('name, image_url')
            .eq('id', currentUser.id)
            .single();
        
        userName = userProfile['name'] ?? 'User';
        userImageUrl = userProfile['image_url'];
      } catch (e) {
        // Fallback to email or default name if profile not found
        userName = currentUser.email?.split('@')[0] ?? 'User';
      }

      // TODO: Upload image to storage if imageBytes is provided
      String? uploadedImageUrl;
      if (imageBytes != null) {
        // For now, we'll skip image upload and just use null
        // In a real app, you would upload to Supabase Storage here
        uploadedImageUrl = null;
      }

      // Insert post into database
      final postData = {
        'user_id': currentUser.id,
        'content': content,
        'image_url': uploadedImageUrl,
        'category': category,
        'like_count': 0,
        'comment_count': 0,
        'is_featured': false,
      };

      final insertedPost = await _supabaseService.client
          .from('community_posts')
          .insert(postData)
          .select()
          .single();

      // Create CommunityPost object from inserted data
      final newPost = CommunityPost(
        id: insertedPost['id'].toString(),
        userId: currentUser.id,
        userName: userName,
        userImageUrl: userImageUrl,
        timestamp: DateTime.parse(insertedPost['created_at']),
        content: content,
        imageUrl: uploadedImageUrl,
        category: category,
        taggedIngredients: taggedIngredients,
        likeCount: 0,
        commentCount: 0,
      );

      // Add the new post to the list (at the beginning since it's newest)
      final updatedPosts = [newPost, ...state.posts];
      final updatedAllPosts = [newPost, ...state.allPosts];

      emit(state.copyWith(
        posts: updatedPosts,
        allPosts: updatedAllPosts,
        status: CommunityStatus.loaded,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'Failed to create post: ${e.toString()}',
        ),
      );
    }
  }

  // Add a comment to a post
  Future<void> addComment(String postId, String comment) async {
    // Find the post
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = state.posts[index];

    // Update post locally first
    final updatedPost = post.copyWith(commentCount: post.commentCount + 1);

    final updatedPosts = List<CommunityPost>.from(state.posts);
    updatedPosts[index] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));

    // Add comment in database (would be implemented in a real app)
    try {
      // await dataService.addComment(postId, comment);
    } catch (e) {
      // If there was an error, revert the change
      final revertedPosts = List<CommunityPost>.from(state.posts);
      revertedPosts[index] = post;

      emit(
        state.copyWith(
          posts: revertedPosts,
          status: CommunityStatus.error,
          errorMessage: 'Failed to add comment: ${e.toString()}',
        ),
      );
    }
  }
}
