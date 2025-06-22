class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? imageUrl;
  final String? bio;
  final int savedRecipesCount;
  final int postsCount;
  final bool isNotificationsEnabled;
  final String? language;
  final bool isDarkModeEnabled;
  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.imageUrl,
    this.bio,
    this.savedRecipesCount = 0,
    this.postsCount = 0,
    this.isNotificationsEnabled = true,
    this.language = 'en',
    this.isDarkModeEnabled = false,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      imageUrl: json['image_url'],
      bio: json['bio'],
      savedRecipesCount: json['saved_recipes_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      isNotificationsEnabled: json['is_notifications_enabled'] ?? true,
      language: json['language'] ?? 'en',
      isDarkModeEnabled: json['is_dark_mode_enabled'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'bio': bio,
      'saved_recipes_count': savedRecipesCount,
      'posts_count': postsCount,
      'is_notifications_enabled': isNotificationsEnabled,
    };
  }

  // Create a copy of user profile with modifications
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? bio,
    int? savedRecipesCount,
    int? postsCount,
    bool? isNotificationsEnabled,
    String? language,
    bool? isDarkModeEnabled,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      savedRecipesCount: savedRecipesCount ?? this.savedRecipesCount,
      postsCount: postsCount ?? this.postsCount,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      language: language ?? this.language,
      isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
    );
  }
}
