import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final UserProfile? user;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    UserProfile? user,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, status, errorMessage];
}
