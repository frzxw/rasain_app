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
    this.isLiked = false,  });

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
