import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/post_comment.dart';
import '../../cubits/community/community_cubit.dart';
import '../../core/theme/colors.dart';
import '../../core/constants/sizes.dart';
import '../../services/data_service.dart';

class CommentsOverlay extends StatefulWidget {
  final String postId;
  final String postContent;
  final int currentCommentCount;

  const CommentsOverlay({
    super.key,
    required this.postId,
    required this.postContent,
    required this.currentCommentCount,
  });

  @override
  State<CommentsOverlay> createState() => _CommentsOverlayState();
}

class _CommentsOverlayState extends State<CommentsOverlay> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  List<PostComment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }
  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('🔄 Loading comments for post: ${widget.postId}');
      final comments = await context.read<CommunityCubit>().getPostComments(widget.postId);
      debugPrint('📥 Received ${comments.length} comments');
      
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading comments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load comments: $e'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadComments,
            ),
          ),
        );
      }
    }
  }
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      debugPrint('📝 Submitting comment: ${_commentController.text.trim()}');
      debugPrint('📍 Post ID: ${widget.postId}');
      
      await context.read<CommunityCubit>().addComment(
        widget.postId,
        _commentController.text.trim(),
      );
      
      _commentController.clear();
      _commentFocusNode.unfocus();
      
      debugPrint('✅ Comment submitted, reloading comments...');
      await _loadComments(); // Refresh comments
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error submitting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitComment,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments (${_comments.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Debug button (remove in production)
                    if (true) // Set to false in production
                      IconButton(
                        icon: const Icon(Icons.bug_report, size: 20),
                        onPressed: () async {
                          final dataService = DataService();
                          await dataService.testCommentConnection();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Check debug console for test results')),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Post content preview
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              widget.postContent,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const Divider(height: 20),
          
          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _comments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentItem(comment);
                        },
                      ),
          ),
          
          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: AppSizes.paddingM,
              right: AppSizes.paddingM,
              top: AppSizes.paddingS,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isSubmitting
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(PostComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: comment.authorAvatar != null
                ? NetworkImage(comment.authorAvatar!)
                : null,
            child: comment.authorAvatar == null
                ? Text(
                    comment.authorName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author name and time
                  Row(
                    children: [
                      Text(
                        comment.authorName ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(comment.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Comment text
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Like button
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement comment like functionality
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likeCount.toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
