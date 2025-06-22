import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/community_post.dart';
import '../../models/post_comment.dart';
import '../../services/community_service.dart';
import 'dart:typed_data';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityService _communityService = CommunityService();

  // Constants for better maintainability
  static const String _defaultCategory = 'Semua';
  
  // Track ongoing operations to prevent race conditions
  final Map<String, Future<void>> _ongoingLikeOperations = {};
  final Map<String, Future<void>> _ongoingCommentOperations = {};

  CommunityCubit() : super(const CommunityState());  // Initialize and fetch community posts
  Future<void> initialize() async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      // Fetch community posts with like status using the dedicated community service
      final posts = await _communityService.getCommunityPostsWithLikeStatus();

      // Get categories from service
      final categories = await _communityService.getPostCategories();

      emit(
        state.copyWith(
          posts: posts,
          allPosts: posts, // Store all posts for filtering
          categories: categories,
          selectedCategory: _defaultCategory,
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
    );    try {
      final filteredPosts =
          category == _defaultCategory
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
        ),      );
    }
  }

  // Like or unlike a post
  Future<void> toggleLikePost(String postId) async {
    // Prevent race conditions by checking if operation is already in progress
    if (_ongoingLikeOperations.containsKey(postId)) {
      return;
    }

    _ongoingLikeOperations[postId] = _performLikeOperation(postId);
    
    try {
      await _ongoingLikeOperations[postId]!;
    } finally {
      _ongoingLikeOperations.remove(postId);
    }
  }
  /// Performs the actual like operation with optimistic updates and error handling
  Future<void> _performLikeOperation(String postId) async {
    try {
      // Find the post in both posts and allPosts
      final postsIndex = state.posts.indexWhere((p) => p.id == postId);
      final allPostsIndex = state.allPosts.indexWhere((p) => p.id == postId);

      if (postsIndex == -1 || allPostsIndex == -1) {
        return;
      }

      final post = state.posts[postsIndex];
      final isCurrentlyLiked = post.isLiked;

      // Optimistic UI update using helper method
      final newIsLiked = !isCurrentlyLiked;
      final newLikeCount = newIsLiked ? post.likeCount + 1 : post.likeCount - 1;

      _updatePostInBothLists(postId, (post) => post.copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      ));

      // Database operation using service
      try {
        final result = await _communityService.togglePostLikeWithDetails(postId);
        
        if (result.success) {
          // Update with actual data from database
          _updatePostInBothLists(postId, (post) => post.copyWith(
            isLiked: result.isLiked,
            likeCount: result.likeCount,
          ));
        } else {
          // Revert the optimistic update on service error
          _updatePostInBothLists(postId, (post) => post.copyWith(
            isLiked: isCurrentlyLiked,
            likeCount: post.likeCount,
          ));

          emit(
            state.copyWith(
              status: CommunityStatus.error,
              errorMessage: result.error ?? 'Failed to update like',
            ),
          );
        }
      } catch (dbError) {
        // Revert the optimistic update on database error
        _updatePostInBothLists(postId, (post) => post.copyWith(
          isLiked: isCurrentlyLiked,
          likeCount: post.likeCount,
        ));

        emit(
          state.copyWith(
            status: CommunityStatus.error,
            errorMessage: 'Failed to update like: ${dbError.toString()}',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'Failed to toggle like: ${e.toString()}',
        ),
      );
    }
  }

  /// Helper method to reduce code duplication when updating posts in both lists
  void _updatePostInBothLists(String postId, CommunityPost Function(CommunityPost) updater) {
    final postsIndex = state.posts.indexWhere((p) => p.id == postId);
    final allPostsIndex = state.allPosts.indexWhere((p) => p.id == postId);
    
    if (postsIndex != -1 && allPostsIndex != -1) {
      final updatedPosts = List<CommunityPost>.from(state.posts);
      final updatedAllPosts = List<CommunityPost>.from(state.allPosts);
      
      updatedPosts[postsIndex] = updater(updatedPosts[postsIndex]);
      updatedAllPosts[allPostsIndex] = updater(updatedAllPosts[allPostsIndex]);
      
      emit(state.copyWith(posts: updatedPosts, allPosts: updatedAllPosts));
    }  }

  // Create a new community post
  Future<void> createPost({
    required String content,
    Uint8List? imageBytes,
    String? fileName,
    String? category,
  }) async {
    // Input validation using service
    if (!_communityService.validatePostInput(content)) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Invalid post content',
      ));
      return;
    }

    emit(state.copyWith(status: CommunityStatus.posting));

    try {
      // Create post using service
      final result = await _communityService.createPostWithFullDetails(
        content: content,
        imageBytes: imageBytes,
        fileName: fileName,
        category: category,
      );

      if (result.success && result.post != null) {
        // Add the new post to the list (at the beginning since it's newest)
        final updatedPosts = [result.post!, ...state.posts];
        final updatedAllPosts = [result.post!, ...state.allPosts];

        emit(state.copyWith(
          posts: updatedPosts,
          allPosts: updatedAllPosts,
          status: CommunityStatus.loaded,
        ));
      } else {
        emit(
          state.copyWith(
            status: CommunityStatus.error,
            errorMessage: result.error ?? 'Failed to create post',
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
  }  // Add a comment to a post
  Future<void> addComment(String postId, String comment) async {
    // Prevent race conditions
    if (_ongoingCommentOperations.containsKey(postId)) {
      debugPrint('⚠️ Comment operation already in progress for post: $postId');
      return;
    }

    // Input validation using service
    if (!_communityService.validateCommentInput(comment)) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Invalid comment input',
      ));
      return;
    }

    _ongoingCommentOperations[postId] = _performAddComment(postId, comment);
    
    try {
      await _ongoingCommentOperations[postId]!;
    } finally {
      _ongoingCommentOperations.remove(postId);
    }
  }  /// Performs the actual comment addition with optimistic updates
  Future<void> _performAddComment(String postId, String comment) async {
    try {
      debugPrint('💬 Adding comment to post: $postId');
      
      // Optimistic UI update - increment comment count immediately using helper method
      _updatePostInBothLists(postId, (post) => post.copyWith(
        commentCount: post.commentCount + 1,
      ));

      // Create comment in database using service with detailed result
      final result = await _communityService.createCommentWithCount(
        postId: postId,
        content: comment,
      );

      if (result.success) {
        debugPrint('✅ Comment added successfully');
        
        // Update with actual comment count from database
        _updatePostInBothLists(postId, (post) => post.copyWith(
          commentCount: result.commentCount,
        ));
        
      } else {
        // Revert optimistic update on failure
        _updatePostInBothLists(postId, (post) => post.copyWith(
          commentCount: post.commentCount - 1,
        ));

        emit(state.copyWith(
          status: CommunityStatus.error,
          errorMessage: result.error ?? 'Failed to add comment',
        ));
      }
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      
      // Revert optimistic update on error
      _updatePostInBothLists(postId, (post) => post.copyWith(
        commentCount: post.commentCount - 1,
      ));
      
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Failed to add comment: ${e.toString()}',
      ));
    }
  }
  // Get comments for a specific post
  Future<List<PostComment>> getPostComments(String postId) async {
    try {
      debugPrint('📋 Getting comments for post: $postId');
      return await _communityService.getPostComments(postId);
    } catch (e) {
      debugPrint('❌ Error getting comments: $e');
      return [];
    }
  }  @override
  Future<void> close() {
    // Clean up ongoing operations to prevent memory leaks
    _ongoingLikeOperations.clear();
    _ongoingCommentOperations.clear();
    return super.close();
  }
}
