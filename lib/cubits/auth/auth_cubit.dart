import 'package:bloc/bloc.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState()) {
    // Listen to auth service changes
    _authService.addListener(_onAuthServiceChange);
  }

  @override
  Future<void> close() {
    _authService.removeListener(_onAuthServiceChange);
    return super.close();
  }

  // Handle auth service state changes (like email verification)
  void _onAuthServiceChange() {
    if (_authService.isAuthenticated && _authService.currentUser != null) {
      // User just got authenticated (likely from email verification)
      emit(
        state.copyWith(
          user: _authService.currentUser,
          status: AuthStatus.authenticated,
          errorMessage: null,
        ),
      );
    } else if (!_authService.isAuthenticated) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  // Initialize and check current authentication status
  Future<void> initialize() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      // Check if user is already logged in
      final isLoggedIn = await _authService.checkAuth();

      if (isLoggedIn && _authService.currentUser != null) {
        emit(
          state.copyWith(
            user: _authService.currentUser,
            status: AuthStatus.authenticated,
          ),
        );
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.login(email, password);

      if (success && _authService.isAuthenticated) {
        emit(
          state.copyWith(
            user: _authService.currentUser,
            status: AuthStatus.authenticated,
          ),
        );
        return true;
      } else {
        // Wait a bit more for the auth state to propagate
        await Future.delayed(const Duration(milliseconds: 200));

        if (_authService.isAuthenticated) {
          emit(
            state.copyWith(
              user: _authService.currentUser,
              status: AuthStatus.authenticated,
            ),
          );
          return true;
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.error,
              errorMessage: _authService.error ?? "Login failed",
            ),
          );
          return false;
        }
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUp(String name, String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.register(name, email, password);
      if (success) {
        // For Supabase, after successful signup but before email confirmation,
        // currentUser will be null. This is expected behavior.
        // We should set emailVerificationPending state regardless of currentUser status
        print(
          'AuthCubit: Registration successful, setting email verification pending state',
        );

        // Add a small delay to ensure the state change is properly detected
        await Future.delayed(const Duration(milliseconds: 100));

        emit(
          state.copyWith(
            status: AuthStatus.emailVerificationPending,
            errorMessage: null, // Clear any previous errors
          ),
        );

        print('AuthCubit: State emitted - Status: ${state.status}');
        return true;
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: _authService.error ?? "Registration failed",
          ),
        );
        return false;
      }
    } catch (e) {
      print('AuthCubit: Registration error: $e');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authService.logout();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.updateProfile(updatedProfile);

      if (success) {
        emit(
          state.copyWith(
            user: _authService.currentUser,
            status: AuthStatus.authenticated,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: _authService.error ?? "Profile update failed",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Reset password with email
  Future<bool> resetPassword(String email) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.resetPassword(email);

      if (success) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return true;
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: _authService.error ?? "Password reset failed",
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.changePassword(
        currentPassword,
        newPassword,
      );

      if (success) {
        emit(state.copyWith(status: AuthStatus.authenticated));
        return true;
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: _authService.error ?? "Password change failed",
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  // Delete account - updated version to handle both cases
  Future<bool> deleteAccount({String? password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      print('AuthCubit: Deleting account');

      if (password != null) {
        // If password provided, use it
        final success = await _authService.deleteAccount(password);

        if (success) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
          return true;
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.error,
              errorMessage: _authService.error ?? "Failed to delete account",
            ),
          );
          return false;
        }
      } else {
        // If no password provided, just sign out
        await _authService.signOut();
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return true;
      }
    } catch (e) {
      print('AuthCubit: Error deleting account: $e');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  // Update user settings
  Future<bool> updateSettings(
    bool notificationsEnabled,
    String language,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    if (state.user == null) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: "User is not authenticated",
        ),
      );
      return false;
    }

    try {
      final updatedUser = state.user!.copyWith(
        isNotificationsEnabled: notificationsEnabled,
        language: language,
      );

      final success = await _authService.updateProfile(updatedUser);

      if (success) {
        emit(
          state.copyWith(user: updatedUser, status: AuthStatus.authenticated),
        );
        return true;
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: _authService.error ?? "Settings update failed",
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  // Handle authentication state changes (e.g., after email confirmation)
  Future<void> handleAuthStateChange() async {
    try {
      print('AuthCubit: Handling auth state change');

      // Check if user is now authenticated
      final isLoggedIn = await _authService.checkAuth();

      if (isLoggedIn && _authService.currentUser != null) {
        print('AuthCubit: User is now authenticated after email confirmation');

        emit(
          state.copyWith(
            user: _authService.currentUser,
            status: AuthStatus.authenticated,
            errorMessage: null,
          ),
        );
      } else {
        print('AuthCubit: User is not authenticated');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      print('AuthCubit: Error handling auth state change: $e');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
