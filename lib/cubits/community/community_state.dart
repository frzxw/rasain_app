import 'package:equatable/equatable.dart';
import '../../models/community_post.dart';

enum CommunityStatus { initial, loading, loaded, posting, error }

class CommunityState extends Equatable {
  final List<CommunityPost> posts;
  final List<String> categories;
  final String? selectedCategory;
  final CommunityStatus status;
  final String? errorMessage;

  const CommunityState({
    this.posts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.status = CommunityStatus.initial,
    this.errorMessage,
  });

  CommunityState copyWith({
    List<CommunityPost>? posts,
    List<String>? categories,
    String? selectedCategory,
    CommunityStatus? status,
    String? errorMessage,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    categories,
    selectedCategory,
    status,
    errorMessage,
  ];
}
