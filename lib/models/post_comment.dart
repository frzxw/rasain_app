class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId;
  final String content;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for UI display
  final String? authorName;
  final String? authorAvatar;
  final List<PostComment>? replies; // For nested comments

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
    this.replies,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => PostComment.fromJson(reply))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
    };
  }

  PostComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentCommentId,
    String? content,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatar,
    List<PostComment>? replies,
  }) {
    return PostComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      replies: replies ?? this.replies,
    );
  }
}
