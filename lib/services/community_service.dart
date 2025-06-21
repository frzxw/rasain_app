import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../models/post_comment.dart';
import 'supabase_service.dart';
import 'dart:typed_data';

/// Dedicated service for community-related operations
/// Handles posts, comments, likes, and community-specific business logic
class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;

  // Constants
  static const String _defaultUserName = 'Community User';
  static const int _maxPostContentLength = 5000;
  static const int _maxCommentContentLength = 1000;

  // ===== POST OPERATIONS =====

  /// Get all community posts with user profile information
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

  /// Create a new community post
  Future<bool> createPost({
    required String content,
    String? category,
    String? title,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // Validate input
      if (content.trim().isEmpty) {
        debugPrint('❌ Post content cannot be empty');
        return false;
      }

      if (content.length > _maxPostContentLength) {
        debugPrint('❌ Post content exceeds maximum length');
        return false;
      }

      String? imageUrl;          // Upload image if provided
          if (imageBytes != null && imageFileName != null) {
            try {
              final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}_$imageFileName';
              await _supabaseService.client.storage
                  .from('community-images')
                  .uploadBinary(fileName, imageBytes);

              imageUrl = _supabaseService.client.storage
                  .from('community-images')
                  .getPublicUrl(fileName);
              
              debugPrint('✅ Image uploaded successfully: $imageUrl');
            } catch (uploadError) {
              debugPrint('⚠️ Image upload failed: $uploadError');
              // Continue without image
            }
          }

      // Create post data
      final postData = {
        'user_id': currentUser.id,
        'title': title?.trim(),
        'content': content.trim(),
        'image_url': imageUrl,
        'category': category?.trim(),
        'like_count': 0,
        'comment_count': 0,
        'is_featured': false,
      };

      // Insert post into database
      await _supabaseService.client
          .from('community_posts')
          .insert(postData);

      debugPrint('✅ Community post created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating community post: $e');
      return false;
    }
  }

  /// Toggle like status for a post
  Future<bool> togglePostLike(String postId) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // Check if user has already liked this post
      final existingLike = await _supabaseService.client
          .from('post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the post
        await _supabaseService.client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUser.id);        // Decrement like count
        await _supabaseService.client.rpc('decrement_post_likes', 
          params: {'post_id': postId});

        debugPrint('✅ Post unliked successfully');
      } else {
        // Like the post
        await _supabaseService.client
            .from('post_likes')
            .insert({
              'post_id': postId,
              'user_id': currentUser.id,
            });        // Increment like count
        await _supabaseService.client.rpc('increment_post_likes', 
          params: {'post_id': postId});

        debugPrint('✅ Post liked successfully');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error toggling post like: $e');
      return false;
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

  /// Create a new comment for a post
  Future<bool> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final currentUser = _supabaseService.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ User not authenticated');
        return false;
      }

      // Validate input
      if (content.trim().isEmpty) {
        debugPrint('❌ Comment content cannot be empty');
        return false;
      }

      if (content.length > _maxCommentContentLength) {
        debugPrint('❌ Comment content exceeds maximum length');
        return false;
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

      debugPrint('✅ Comment created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating comment: $e');
      return false;
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

      // Check if user has already liked this comment
      final existingLike = await _supabaseService.client
          .from('comment_likes')
          .select('id')
          .eq('comment_id', commentId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the comment
        await _supabaseService.client
            .from('comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', currentUser.id);        // Decrement like count
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
            });        // Increment like count
        await _supabaseService.client.rpc('increment_comment_likes', 
          params: {'comment_id': commentId});

        debugPrint('✅ Comment liked successfully');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error toggling comment like: $e');
      return false;
    }
  }

  // ===== UTILITY METHODS =====
  /// Get all unique categories from community posts
  Future<List<String>> getPostCategories() async {
    try {
      final response = await _supabaseService.client
          .from('community_posts')
          .select('category')
          .not('category', 'is', null);

      final categories = <String>{'Semua'}; // Default category
      
      for (final row in response) {
        final category = row['category']?.toString();
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      debugPrint('❌ Error fetching post categories: $e');
      return ['Semua'];
    }
  }
}
