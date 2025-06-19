import 'package:bloc/bloc.dart';
import '../../models/community_post.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import 'dart:typed_data';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final DataService _dataService;
  final AuthService _authService;

  CommunityCubit(this._dataService, this._authService)
    : super(const CommunityState());

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
              ? state.posts
              : state.posts.where((post) => post.category == category).toList();

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
    // Find the post
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = state.posts[index];
    final isLiked = !post.isLiked;
    final newLikeCount = isLiked ? post.likeCount + 1 : post.likeCount - 1;

    // Update post locally first
    final updatedPost = post.copyWith(
      isLiked: isLiked,
      likeCount: newLikeCount,
    );

    final updatedPosts = List<CommunityPost>.from(state.posts);
    updatedPosts[index] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));

    // Update in database (would be implemented in a real app)
    try {
      // await dataService.likePost(postId, isLiked);
    } catch (e) {
      // If there was an error, revert the change
      final revertedPosts = List<CommunityPost>.from(state.posts);
      revertedPosts[index] = post;

      emit(
        state.copyWith(
          posts: revertedPosts,
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
      // Get current user data from AuthService
      final currentUserAuth = _authService.supabaseUser;
      final userProfile = _authService.currentUser;

      if (currentUserAuth == null || userProfile == null) {
        emit(
          state.copyWith(
            status: CommunityStatus.error,
            errorMessage: 'User must be logged in to create posts',
          ),
        );
        return;
      }

      // Create post in database using DataService
      final newPost = await _dataService.createCommunityPost(
        userId: currentUserAuth.id,
        userName: userProfile.name,
        userImageUrl: userProfile.imageUrl,
        content: content,
        imageUrl:
            imageBytes != null
                ? 'mock_image_url'
                : null, // TODO: implement image upload
        category: category,
        taggedIngredients: taggedIngredients,
      );

      if (newPost != null) {
        // Add the new post to the list
        final updatedPosts = [newPost, ...state.posts];
        emit(
          state.copyWith(posts: updatedPosts, status: CommunityStatus.loaded),
        );
      } else {
        emit(
          state.copyWith(
            status: CommunityStatus.error,
            errorMessage: 'Failed to create post',
          ),
        );
      }
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
