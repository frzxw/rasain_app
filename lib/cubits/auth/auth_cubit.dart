import 'package:bloc/bloc.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState());
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
            errorMessage: _authService.error ?? "Registration failed",
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

  // Delete account
  Future<bool> deleteAccount(String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await _authService.deleteAccount(password);

      if (success) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return true;
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: _authService.error ?? "Account deletion failed",
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
}
