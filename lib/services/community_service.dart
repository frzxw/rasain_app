import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../models/post_comment.dart';
import 'supabase_service.dart';
import 'dart:typed_data';

/// Result classes for better operation feedback
class LikeOperationResult {
  final bool success;
  final bool isLiked;
  final int likeCount;
  final String? error;

  const LikeOperationResult({
    required this.success,
    required this.isLiked,
    required this.likeCount,
    this.error,
  });
}

class PostCreationResult {
  final bool success;
  final CommunityPost? post;
  final String? error;

  const PostCreationResult({
    required this.success,
    this.post,
    this.error,
  });
}

class CommentOperationResult {
  final bool success;
  final int commentCount;
  final String? error;

  const CommentOperationResult({
    required this.success,
    required this.commentCount,
    this.error,
  });
}

/// Dedicated service for community-related operations
/// Handles posts, comments, likes, and community-specific business logic
/// Enhanced to support full cubit refactor with optimistic updates
class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;

  // Constants
  static const String _defaultUserName = 'Community User';
  static const int _maxPostContentLength = 5000;
  static const int _maxCommentContentLength = 1000;
  static const int _maxTitleLength = 50;
  static const Duration _databaseSyncDelay = Duration(milliseconds: 500);
  // ===== POST OPERATIONS =====

  /// Get all community posts with user profile information and like status
  Future<List<CommunityPost>> getCommunityPosts() async {
    try {
      // Get posts with basic data first
      final response = await _supabaseService.client
          .from('community_posts')
          .select('*')
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      // Get unique user IDs for batch fetching user profiles
      final userIds = response
          .map((post) => post['user_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      // Batch fetch user profiles for all unique user IDs
      Map<String, Map<String, dynamic>> userProfiles = {};
      if (userIds.isNotEmpty) {
        try {
          final profilesResponse = await _supabaseService.client
              .from('user_profiles')
              .select('id, name, image_url')
              .inFilter('id', userIds);

          for (final profile in profilesResponse) {
            final userId = profile['id']?.toString();
            if (userId != null) {
              userProfiles[userId] = profile;
            }
          }
        } catch (profileError) {
          debugPrint('⚠️ Error fetching user profiles: $profileError');
        }
      }

      // Map posts with user data
      final posts = response.map<CommunityPost>((post) {
        final userId = post['user_id']?.toString() ?? '';
        final userProfile = userProfiles[userId];
        
        return CommunityPost(
          id: post['id']?.toString() ?? '',
          userId: userId,
          userName: userProfile?['name']?.toString() ?? _defaultUserName,
          userImageUrl: userProfile?['image_url']?.toString(),
          timestamp: DateTime.parse(
            post['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          title: post['title']?.toString(),
          content: post['content']?.toString(),
          imageUrl: post['image_url']?.toString(),
          category: post['category']?.toString(),
          likeCount: post['like_count']?.toInt() ?? 0,
          commentCount: post['comment_count']?.toInt() ?? 0,
          isLiked: false, // Will be updated by like status check
          taggedIngredients: null,
        );
      }).toList();

      return posts;
    } catch (e) {
      debugPrint('❌ Error fetching community posts: $e');
      return [];
    }
  }

  /// Get community posts with like status for current user
  Future<List<CommunityPost>> getCommunityPostsWithLikeStatus() async {
    try {
      final posts = await getCommunityPosts();
      return await updatePostsWithLikeStatus(posts);
    } catch (e) {
      debugPrint('❌ Error fetching community posts with like status: $e');
      return [];
    }
  }

  /// Update posts with like status for current user (matches cubit functionality)
  Future<List<CommunityPost>> updatePostsWithLikeStatus(List<CommunityPost> posts) async {
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
      }).toList();

      return updatedPosts;
    } catch (e) {
      debugPrint('❌ Error updating posts with like status: $e');
      return posts; // Return original posts if error occurs
    }
  }
  /// Create a new community post (enhanced version matching cubit functionality)
  Future<PostCreationResult> createPostWithFullDetails({
    required String content,
    Uint8List? imageBytes,
    String? fileName,
    String? category,
  }) async {
    try {
      // Input validation
      if (content.trim().isEmpty) {
        return const PostCreationResult(
          success: false,
          error: 'Post content cannot be empty',
        );
      }

      if (content.length > _maxPostContentLength) {
        return const PostCreationResult(
          success: false,
          error: 'Post content is too long (max $_maxPostContentLength characters)',
        );
      }

      // Get current user
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        return const PostCreationResult(
          success: false,
          error: 'User must be logged in to create posts',
        );
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

      // Upload image to Supabase Storage if provided
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
      }

      // Generate a title from content (take first 50 characters or use category)
      String title = '';
      if (content.isNotEmpty) {
        title = content.length > _maxTitleLength 
            ? '${content.substring(0, _maxTitleLength)}...' 
            : content;
      } else if (category != null) {
        title = 'Post tentang $category';
      } else {
        title = 'Post dari $userName';
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
          .single();

      // Create CommunityPost object from inserted data
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

      return PostCreationResult(
        success: true,
        post: newPost,
      );
    } catch (e) {
      return PostCreationResult(
        success: false,
        error: 'Failed to create post: ${e.toString()}',
      );
    }
  }

  /// Create a new community post (legacy method for backward compatibility)
  Future<bool> createPost({
    required String content,
    String? category,
    String? title,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final result = await createPostWithFullDetails(
      content: content,
      imageBytes: imageBytes,
      fileName: imageFileName,
      category: category,
    );
    return result.success;
  }
  /// Toggle like status for a post with detailed result (enhanced version)
  Future<LikeOperationResult> togglePostLikeWithDetails(String postId) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        return const LikeOperationResult(
          success: false,
          isLiked: false,
          likeCount: 0,
          error: 'User not authenticated',
        );
      }      // Check if user has already liked this post
      final existingLike = await _supabaseService.client
          .from('post_likes')
          .select('user_id')
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .maybeSingle();      bool newLikedStatus;
      if (existingLike != null) {
        // Unlike the post
        await _supabaseService.client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUser.id);

        newLikedStatus = false;
        debugPrint('✅ Post unliked successfully');
      } else {
        // Like the post
        await _supabaseService.client
            .from('post_likes')
            .insert({
              'post_id': postId,
              'user_id': currentUser.id,
            });

        newLikedStatus = true;
        debugPrint('✅ Post liked successfully');
      }

      // Wait for database triggers to update the like count
      await Future.delayed(_databaseSyncDelay);

      // Get updated like count from database
      final updatedPost = await _supabaseService.client
          .from('community_posts')
          .select('like_count')
          .eq('id', postId)
          .single();

      final newLikeCount = updatedPost['like_count']?.toInt() ?? 0;

      return LikeOperationResult(
        success: true,
        isLiked: newLikedStatus,
        likeCount: newLikeCount,
      );
    } catch (e) {
      debugPrint('❌ Error toggling post like: $e');
      return LikeOperationResult(
        success: false,
        isLiked: false,
        likeCount: 0,
        error: e.toString(),
      );
    }
  }

  /// Toggle like status for a post (legacy method for backward compatibility)
  Future<bool> togglePostLike(String postId) async {
    final result = await togglePostLikeWithDetails(postId);
    return result.success;
  }

  /// Refresh post like count from database (matches cubit functionality)
  Future<LikeOperationResult> refreshPostLikeCount(String postId) async {
    try {
      // Get current user
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        return const LikeOperationResult(
          success: false,
          isLiked: false,
          likeCount: 0,
          error: 'User not authenticated',
        );
      }

      // Get updated post data with like count
      final updatedPostData = await _supabaseService.client
          .from('community_posts')
          .select('like_count')
          .eq('id', postId)
          .single();      // Check if current user has liked this post
      final userLikeData = await _supabaseService.client
          .from('post_likes')
          .select('user_id')
          .eq('user_id', currentUser.id)
          .eq('post_id', postId);

      final newLikeCount = updatedPostData['like_count']?.toInt() ?? 0;
      final isLiked = userLikeData.isNotEmpty;
      
      return LikeOperationResult(
        success: true,
        isLiked: isLiked,
        likeCount: newLikeCount,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to refresh post like count: $e');
      return LikeOperationResult(
        success: false,
        isLiked: false,
        likeCount: 0,
        error: e.toString(),
      );
    }
  }

  /// Check which posts are liked by the current user
  Future<Set<String>> getUserLikedPosts(List<String> postIds) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null || postIds.isEmpty) {
        return {};
      }

      final response = await _supabaseService.client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', currentUser.id)
          .inFilter('post_id', postIds);

      return response
          .map((like) => like['post_id']?.toString())
          .where((id) => id != null)
          .cast<String>()
          .toSet();
    } catch (e) {
      debugPrint('❌ Error fetching user liked posts: $e');
      return {};
    }
  }

  // ===== COMMENT OPERATIONS =====
  /// Get comments for a specific post
  Future<List<PostComment>> getPostComments(String postId) async {
    try {
      debugPrint('🔍 Fetching comments for post: $postId');
      
      // Try JOIN query first, fallback if it fails
      try {
        final response = await _supabaseService.client
            .from('post_comments')
            .select('''
              *,
              user_profiles!inner(
                name,
                image_url
              )
            ''')
            .eq('post_id', postId)
            .order('created_at', ascending: true);

        final comments = response.map<PostComment>((comment) {
          final userProfile = comment['user_profiles'];
          final userName = userProfile is List && userProfile.isNotEmpty 
              ? userProfile[0]['name']?.toString() ?? 'Unknown User'
              : userProfile is Map 
                  ? userProfile['name']?.toString() ?? 'Unknown User'
                  : 'Unknown User';
          
          final userImageUrl = userProfile is List && userProfile.isNotEmpty 
              ? userProfile[0]['image_url']?.toString()
              : userProfile is Map 
                  ? userProfile['image_url']?.toString()
                  : null;
          
          return PostComment(
            id: comment['id']?.toString() ?? '',
            postId: comment['post_id']?.toString() ?? '',
            userId: comment['user_id']?.toString() ?? '',
            parentCommentId: comment['parent_comment_id']?.toString(),
            content: comment['content']?.toString() ?? '',
            likeCount: comment['like_count']?.toInt() ?? 0,
            createdAt: DateTime.parse(
              comment['created_at'] ?? DateTime.now().toIso8601String(),
            ),
            updatedAt: DateTime.parse(
              comment['updated_at'] ?? DateTime.now().toIso8601String(),
            ),
            authorName: userName,
            authorAvatar: userImageUrl,
          );
        }).toList();

        debugPrint('✅ Successfully fetched ${comments.length} comments with JOIN');
        return comments;
      } catch (joinError) {
        debugPrint('⚠️ JOIN query failed: $joinError');
        debugPrint('🔄 Falling back to manual method...');
      }
      
      // Fallback: fetch comments without JOIN and get user profiles separately
      final response = await _supabaseService.client
          .from('post_comments')
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      if (response.isEmpty) {
        debugPrint('📋 No comments found for post: $postId');
        return [];
      }

      // Get unique user IDs for fetching user profiles
      final userIds = response
          .map((comment) => comment['user_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      // Batch fetch user profiles for all unique user IDs
      Map<String, Map<String, dynamic>> userProfiles = {};
      if (userIds.isNotEmpty) {
        try {
          final profilesResponse = await _supabaseService.client
              .from('user_profiles')
              .select('id, name, image_url')
              .inFilter('id', userIds);

          for (final profile in profilesResponse) {
            final userId = profile['id']?.toString();
            if (userId != null) {
              userProfiles[userId] = profile;
            }
          }
        } catch (profileError) {
          debugPrint('⚠️ Error fetching user profiles: $profileError');
        }
      }

      // Map comments with user data
      final comments = response.map<PostComment>((comment) {
        final userId = comment['user_id']?.toString() ?? '';
        final userProfile = userProfiles[userId];
        
        return PostComment(
          id: comment['id']?.toString() ?? '',
          postId: comment['post_id']?.toString() ?? '',
          userId: userId,
          parentCommentId: comment['parent_comment_id']?.toString(),
          content: comment['content']?.toString() ?? '',
          likeCount: comment['like_count']?.toInt() ?? 0,
          createdAt: DateTime.parse(
            comment['created_at'] ?? DateTime.now().toIso8601String(),
          ),
          updatedAt: DateTime.parse(
            comment['updated_at'] ?? DateTime.now().toIso8601String(),
          ),
          authorName: userProfile?['name']?.toString() ?? 'Unknown User',
          authorAvatar: userProfile?['image_url']?.toString(),
        );
      }).toList();

      debugPrint('✅ Successfully fetched ${comments.length} comments with fallback method');
      return comments;
    } catch (e) {
      debugPrint('❌ Error fetching comments: $e');
      return [];
    }
  }
  /// Create a new comment for a post with enhanced result
  Future<CommentOperationResult> createCommentWithCount({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        return const CommentOperationResult(
          success: false,
          commentCount: 0,
          error: 'User not authenticated',
        );
      }

      // Validate input
      if (content.trim().isEmpty) {
        return const CommentOperationResult(
          success: false,
          commentCount: 0,
          error: 'Comment content cannot be empty',
        );
      }

      if (content.length > _maxCommentContentLength) {
        return const CommentOperationResult(
          success: false,
          commentCount: 0,
          error: 'Comment content exceeds maximum length',
        );
      }

      final commentData = {
        'post_id': postId,
        'user_id': currentUser.id,
        'parent_comment_id': parentCommentId,
        'content': content.trim(),
        'like_count': 0,
      };

      await _supabaseService.client
          .from('post_comments')
          .insert(commentData);

      // Wait for database trigger to update the count
      await Future.delayed(_databaseSyncDelay);

      // Get updated comment count
      final updatedPost = await _supabaseService.client
          .from('community_posts')
          .select('comment_count')
          .eq('id', postId)
          .single();

      final newCommentCount = updatedPost['comment_count']?.toInt() ?? 0;

      debugPrint('✅ Comment created successfully');
      return CommentOperationResult(
        success: true,
        commentCount: newCommentCount,
      );
    } catch (e) {
      debugPrint('❌ Error creating comment: $e');
      return CommentOperationResult(
        success: false,
        commentCount: 0,
        error: e.toString(),
      );
    }
  }

  /// Create a new comment for a post (legacy method for backward compatibility)
  Future<bool> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final result = await createCommentWithCount(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );
    return result.success;
  }

  /// Refresh post comment count from database (matches cubit functionality)
  Future<int> refreshPostCommentCount(String postId) async {
    try {
      // Get updated post data with comment count
      final updatedPostData = await _supabaseService.client
          .from('community_posts')
          .select('comment_count')
          .eq('id', postId)
          .single();

      return updatedPostData['comment_count']?.toInt() ?? 0;
    } catch (e) {
      debugPrint('⚠️ Failed to refresh post comment count: $e');
      return 0;
    }
  }

  /// Delete a comment (only by the author)
  Future<bool> deleteComment(String commentId) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // Verify ownership
      final commentResponse = await _supabaseService.client
          .from('post_comments')
          .select('user_id')
          .eq('id', commentId)
          .single();

      if (commentResponse['user_id'] != currentUser.id) {
        debugPrint('❌ User not authorized to delete this comment');
        return false;
      }

      // Delete the comment
      await _supabaseService.client
          .from('post_comments')
          .delete()
          .eq('id', commentId);

      debugPrint('✅ Comment deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      return false;
    }
  }
  /// Toggle like status for a comment
  Future<bool> toggleCommentLike(String commentId) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // TODO: Implement comment likes functionality when database schema is ready
      // The comment_likes table and related RPC functions are not in the current schema
      debugPrint('⚠️ Comment likes functionality not implemented in database schema');
      return false;

      /* Comment likes implementation - uncomment when schema is ready:
      
      // Check if user has already liked this comment
      final existingLike = await _supabaseService.client
          .from('comment_likes')
          .select('user_id')
          .eq('comment_id', commentId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the comment
        await _supabaseService.client
            .from('comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', currentUser.id);
        
        // Decrement like count
        await _supabaseService.client.rpc('decrement_comment_likes', 
          params: {'comment_id': commentId});

        debugPrint('✅ Comment unliked successfully');
      } else {
        // Like the comment
        await _supabaseService.client
            .from('comment_likes')
            .insert({
              'comment_id': commentId,
              'user_id': currentUser.id,
            });
        
        // Increment like count
        await _supabaseService.client.rpc('increment_comment_likes', 
          params: {'comment_id': commentId});

        debugPrint('✅ Comment liked successfully');
      }

      return true;
      */
    } catch (e) {
      debugPrint('❌ Error toggling comment like: $e');
      return false;
    }
  }
  // ===== UTILITY METHODS =====

  /// Validates post input content (matches cubit functionality)
  bool validatePostInput(String content) {
    final trimmedContent = content.trim();
    
    if (trimmedContent.isEmpty) {
      debugPrint('❌ Post content cannot be empty');
      return false;
    }
    
    if (trimmedContent.length > _maxPostContentLength) {
      debugPrint('❌ Post content is too long (max $_maxPostContentLength characters)');
      return false;
    }
    
    return true;
  }

  /// Validates comment input content (matches cubit functionality)
  bool validateCommentInput(String comment) {
    final trimmedComment = comment.trim();
    
    if (trimmedComment.isEmpty) {
      debugPrint('❌ Comment cannot be empty');
      return false;
    }
    
    if (trimmedComment.length > _maxCommentContentLength) {
      debugPrint('❌ Comment is too long (max $_maxCommentContentLength characters)');
      return false;
    }
    
    return true;
  }
  /// Get all unique categories from community posts
  Future<List<String>> getPostCategories() async {
    try {
      final response = await _supabaseService.client
          .from('community_posts')
          .select('category')
          .not('category', 'is', null);

      // Get categories from database
      final dbCategories = <String>{};
      for (final row in response) {
        final category = row['category']?.toString();
        if (category != null && category.isNotEmpty) {
          dbCategories.add(category);
        }
      }

      // Create ordered category list
      final orderedCategories = <String>['Semua']; // Always first
      
      // Add predefined categories in specific order
      final predefinedCategories = ['Kreasi', 'Review', 'Tips dan Trik'];
      for (final category in predefinedCategories) {
        if (dbCategories.contains(category)) {
          orderedCategories.add(category);
          dbCategories.remove(category);
        }
      }
      
      // Add any remaining categories from database (sorted)
      final remainingCategories = dbCategories.toList()..sort();
      orderedCategories.addAll(remainingCategories);
      
      // Always ensure "Lainnya" is available and at the end if it exists
      if (!orderedCategories.contains('Lainnya')) {
        orderedCategories.add('Lainnya');
      } else {
        // Move "Lainnya" to the end if it was added from database
        orderedCategories.remove('Lainnya');
        orderedCategories.add('Lainnya');
      }

      return orderedCategories;
    } catch (e) {
      debugPrint('❌ Error fetching post categories: $e');
      return ['Semua'];
    }
  }

  /// Batch check like status for multiple posts (optimization for cubit)
  Future<Map<String, bool>> batchCheckLikeStatus(List<String> postIds) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null || postIds.isEmpty) {
        return {};
      }

      final response = await _supabaseService.client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', currentUser.id)
          .inFilter('post_id', postIds);

      final likedPostIds = response
          .map((like) => like['post_id']?.toString())
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      // Create a map with all post IDs and their like status
      final result = <String, bool>{};
      for (final postId in postIds) {
        result[postId] = likedPostIds.contains(postId);
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error batch checking like status: $e');
      return {};
    }
  }

  /// Get current user information for posts (utility method)
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final userProfile = await _supabaseService.client
          .from('user_profiles')
          .select('name, image_url')
          .eq('id', currentUser.id)
          .single();

      return {
        'id': currentUser.id,
        'name': userProfile['name'] ?? currentUser.email?.split('@')[0] ?? 'User',
        'image_url': userProfile['image_url'],
        'email': currentUser.email,
      };
    } catch (e) {
      debugPrint('❌ Error getting current user info: $e');
      return null;
    }
  }
}
