import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../models/community_post.dart';
import '../../models/post_comment.dart';
import '../../services/community_service.dart';
import '../../services/supabase_service.dart';
import 'dart:typed_data';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityService _communityService = CommunityService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Constants for better maintainability
  static const Duration _databaseSyncDelay = Duration(milliseconds: 500);
  static const int _maxTitleLength = 50;
  static const String _defaultCategory = 'Semua';
  static const int _maxContentLength = 5000;
  
  // Track ongoing operations to prevent race conditions
  final Map<String, Future<void>> _ongoingLikeOperations = {};
  final Map<String, Future<void>> _ongoingCommentOperations = {};

  CommunityCubit() : super(const CommunityState());  // Initialize and fetch community posts
  Future<void> initialize() async {
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      // Fetch community posts using the dedicated community service
      List<CommunityPost> posts = await _communityService.getCommunityPosts();

      // Update like status for current user
      posts = await _updatePostsWithLikeStatus(posts);

      // Extract all unique categories
      final categories = [_defaultCategory];
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
      // Get current user
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'Please log in to like posts',
        ));
        return;
      }

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

      // Database operation
      try {
        if (newIsLiked) {
          // Add like
          await _supabaseService.client
              .from('post_likes')
              .insert({
                'user_id': currentUser.id,
                'post_id': postId,
              });
        } else {
          // Remove like
          await _supabaseService.client
              .from('post_likes')
              .delete()
              .eq('user_id', currentUser.id)
              .eq('post_id', postId);
        }

        // Wait for database triggers to update the like count
        await Future.delayed(_databaseSyncDelay);
        
        // Refresh the actual like count from database to ensure consistency
        await _refreshPostLikeCount(postId);
        
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
    }
  }// Helper method to refresh post like count from database
  Future<void> _refreshPostLikeCount(String postId) async {
    try {
      // Get current user
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) return;

      // Get updated post data with like count
      final updatedPostData = await _supabaseService.client
          .from('community_posts')
          .select('like_count')
          .eq('id', postId)
          .single();

      // Check if current user has liked this post
      final userLikeData = await _supabaseService.client
          .from('post_likes')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('post_id', postId);      final newLikeCount = updatedPostData['like_count']?.toInt() ?? 0;
      final isLiked = userLikeData.isNotEmpty;
      
      // Update the like count and status in local state using helper method
      _updatePostInBothLists(postId, (post) => post.copyWith(
        likeCount: newLikeCount,
        isLiked: isLiked,
      ));
    } catch (e) {
      // Silently fail if refresh doesn't work
      debugPrint('⚠️ Failed to refresh post like count: $e');
    }
  }
    // Create a new community post
  Future<void> createPost({
    required String content,
    Uint8List? imageBytes,
    String? fileName,
    String? category,
  }) async {
    // Input validation
    if (!_validatePostInput(content)) {
      return;
    }

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
      }      // Upload image to Supabase Storage if provided
      String? uploadedImageUrl;
      if (imageBytes != null && fileName != null) {
        try {
          final fileExt = fileName.split('.').last.toLowerCase();
          final uniqueFileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          
          // Upload to posts bucket
          await _supabaseService.client.storage
              .from('posts')
              .uploadBinary(uniqueFileName, imageBytes);
          
          // Get public URL
          uploadedImageUrl = _supabaseService.client.storage
              .from('posts')
              .getPublicUrl(uniqueFileName);
              
        } catch (uploadError) {
          debugPrint('❌ Failed to upload image: $uploadError');
          // Continue without image instead of complex fallback
          uploadedImageUrl = null;
        }
      }// Generate a title from content (take first 50 characters or use category)
      String title = '';
      if (content.isNotEmpty) {
        title = content.length > _maxTitleLength 
            ? '${content.substring(0, _maxTitleLength)}...' 
            : content;
      } else if (category != null) {
        title = 'Post tentang $category';
      } else {
        title = 'Post dari ${userName}';
      }

      // Insert post into database (matching DB schema with title)
      final postData = {
        'user_id': currentUser.id,
        'title': title,
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
          .single();      // Create CommunityPost object from inserted data
      final newPost = CommunityPost(
        id: insertedPost['id'].toString(),
        userId: currentUser.id,
        userName: userName,
        userImageUrl: userImageUrl,
        timestamp: DateTime.parse(insertedPost['created_at']),
        title: title,
        content: content,
        imageUrl: uploadedImageUrl,
        category: category,
        taggedIngredients: null, // No longer using tagged ingredients
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
    }  }  // Add a comment to a post
  Future<void> addComment(String postId, String comment) async {
    // Prevent race conditions
    if (_ongoingCommentOperations.containsKey(postId)) {
      debugPrint('⚠️ Comment operation already in progress for post: $postId');
      return;
    }

    // Input validation
    if (!_validateCommentInput(comment)) {
      return;
    }

    _ongoingCommentOperations[postId] = _performAddComment(postId, comment);
    
    try {
      await _ongoingCommentOperations[postId]!;
    } finally {
      _ongoingCommentOperations.remove(postId);
    }
  }
  /// Performs the actual comment addition with optimistic updates
  Future<void> _performAddComment(String postId, String comment) async {
    try {
      debugPrint('💬 Adding comment to post: $postId');
      
      // Optimistic UI update - increment comment count immediately using helper method
      _updatePostInBothLists(postId, (post) => post.copyWith(
        commentCount: post.commentCount + 1,
      ));
        // Create comment in database
      final success = await _communityService.createComment(
        postId: postId,
        content: comment,
      );

      if (success) {
        debugPrint('✅ Comment added successfully');
        
        // Wait for database trigger to update the count
        await Future.delayed(_databaseSyncDelay);
        
        // Refresh the specific post's comment count from database to ensure accuracy
        await _refreshPostCommentCount(postId);
        
      } else {
        // Revert optimistic update on failure
        _updatePostInBothLists(postId, (post) => post.copyWith(
          commentCount: post.commentCount - 1,
        ));

        emit(state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'Failed to add comment',
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

  // Helper method to refresh post comment count from database
  Future<void> _refreshPostCommentCount(String postId) async {
    try {
      // Get updated post data with comment count
      final updatedPostData = await _supabaseService.client
          .from('community_posts')
          .select('comment_count')
          .eq('id', postId)
          .single();      final newCommentCount = updatedPostData['comment_count']?.toInt() ?? 0;
      
      // Update the comment count in local state using helper method
      _updatePostInBothLists(postId, (post) => post.copyWith(
        commentCount: newCommentCount,
      ));
    } catch (e) {
      // Silently fail if refresh doesn't work
      debugPrint('⚠️ Failed to refresh post comment count: $e');
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
  }

  // Helper method to update posts with like status for current user
  Future<List<CommunityPost>> _updatePostsWithLikeStatus(List<CommunityPost> posts) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        return posts;
      }

      // Get all post IDs
      final postIds = posts.map((p) => p.id).toList();
      
      if (postIds.isEmpty) return posts;

      // Query which posts the current user has liked
      final likedPosts = await _supabaseService.client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', currentUser.id)
          .inFilter('post_id', postIds);

      // Create a set of liked post IDs for quick lookup
      final likedPostIds = likedPosts.map((like) => like['post_id'].toString()).toSet();

      // Update posts with like status
      final updatedPosts = posts.map((post) {
        final isLiked = likedPostIds.contains(post.id);
        return post.copyWith(isLiked: isLiked);
      }).toList();      return updatedPosts;    } catch (e) {
      return posts; // Return original posts if error occurs
    }
  }

  /// Validates post input content
  bool _validatePostInput(String content) {
    final trimmedContent = content.trim();
    
    if (trimmedContent.isEmpty) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Post content cannot be empty',
      ));
      return false;
    }
    
    if (trimmedContent.length > _maxContentLength) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Post content is too long (max $_maxContentLength characters)',
      ));
      return false;
    }
    
    return true;
  }

  /// Validates comment input content
  bool _validateCommentInput(String comment) {
    final trimmedComment = comment.trim();
    
    if (trimmedComment.isEmpty) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Comment cannot be empty',
      ));
      return false;
    }
    
    if (trimmedComment.length > 1000) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Comment is too long (max 1000 characters)',
      ));
      return false;
    }
    
    return true;
  }  @override
  Future<void> close() {
    // Clean up ongoing operations to prevent memory leaks
    _ongoingLikeOperations.clear();
    _ongoingCommentOperations.clear();
    return super.close();
  }
}
