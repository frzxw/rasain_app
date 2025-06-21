class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final DateTime timestamp;
  final String? title;
  final String? content;
  final String? imageUrl;
  final List<String>? taggedIngredients;
  final String? category;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.timestamp,
    this.title,
    this.content,
    this.imageUrl,
    this.taggedIngredients,
    this.category,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userImageUrl: json['user_image_url'],
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      taggedIngredients: json['tagged_ingredients'] != null
          ? List<String>.from(json['tagged_ingredients'])
          : null,
      category: json['category'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'tagged_ingredients': taggedIngredients,
      'category': category,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
    };
  }
  // Create a copy of community post with modifications
  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    DateTime? timestamp,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? taggedIngredients,
    String? category,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      taggedIngredients: taggedIngredients ?? this.taggedIngredients,
      category: category ?? this.category,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
