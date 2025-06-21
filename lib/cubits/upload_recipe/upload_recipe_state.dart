enum UploadRecipeStatus { initial, loading, success, error }

class UploadRecipeState {
  final UploadRecipeStatus status;
  final String? errorMessage;

  const UploadRecipeState({
    this.status = UploadRecipeStatus.initial,
    this.errorMessage,
  });

  UploadRecipeState copyWith({
    UploadRecipeStatus? status,
    String? errorMessage,
  }) {
    return UploadRecipeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
