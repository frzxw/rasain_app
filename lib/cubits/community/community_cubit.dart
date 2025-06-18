import 'package:bloc/bloc.dart';
import '../../models/community_post.dart';
import '../../services/data_service.dart';
import 'dart:typed_data';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final DataService _dataService;

  CommunityCubit(this._dataService) : super(const CommunityState());
  // Initialize and fetch community posts
  Future<void> initialize() async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
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
      // In a real app, this would upload the image to storage
      // and create the post in the database

      // Mock post creation with local data only
      final newPost = CommunityPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // This would come from AuthService
        userName: 'Current User', // This would come from AuthService
        timestamp: DateTime.now(),
        content: content,
        imageUrl: imageBytes != null ? 'mock_image_url' : null,
        category: category,
        taggedIngredients: taggedIngredients,
        likeCount: 0,
        commentCount: 0,
      );

      // Add the new post to the list
      final updatedPosts = [newPost, ...state.posts];

      emit(state.copyWith(posts: updatedPosts, status: CommunityStatus.loaded));
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
