import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;

  UserProfile? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  AuthService() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((event) {
      _handleAuthStateChange(event);
    });

    // Check current session on initialization
    _checkCurrentSession();
  }
  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get supabaseUser => _supabase.auth.currentUser;
  // Handle auth state changes
  void _handleAuthStateChange(AuthState event) async {
    if (event.event == AuthChangeEvent.signedIn) {
      await _loadUserProfile(event.session?.user.id);
    } else if (event.event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Check current session
  Future<void> _checkCurrentSession() async {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      await _loadUserProfile(session!.user.id);
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String? userId) async {
    if (userId == null) return;

    try {
      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .single();

      _currentUser = UserProfile.fromJson(response);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // If profile doesn't exist, user might be newly registered
      // but profile creation failed, try to create it
      if (_supabase.auth.currentUser != null) {
        await _createUserProfile(_supabase.auth.currentUser!);
      }
    }
  }

  // Create user profile in database
  Future<void> _createUserProfile(User user) async {
    try {
      final profileData = {
        'id': user.id,
        'name':
            user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'image_url': user.userMetadata?['avatar_url'],
        'saved_recipes_count': 0,
        'posts_count': 0,
        'is_notifications_enabled': true,
        'language': 'id',
        'is_dark_mode_enabled': false,
      };

      await _supabase.from('user_profiles').insert(profileData);

      // Load the newly created profile
      await _loadUserProfile(user.id);
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      _setError('Failed to create user profile: $e');
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user != null) {
        await _createUserProfile(res.user!);
        // Wait for auth state processing to complete
        await _waitForAuthStateProcessing();
      } else {
        _setError('Sign up failed: No user returned.');
      }
    } on AuthException catch (e) {
      _setError(e.message);
      rethrow;
    } catch (e) {
      _setError('An unexpected error occurred during sign up.');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        _setError('Sign in failed: No user returned.');
        return;
      }

      // Wait for auth state change to complete loading user profile
      await _waitForAuthStateProcessing();
    } on AuthException catch (e) {
      _setError(e.message);
      rethrow;
    } catch (e) {
      _setError('An unexpected error occurred during sign in.');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Wait for auth state processing to complete
  Future<void> _waitForAuthStateProcessing() async {
    // Give some time for the auth state change listener to process
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait
    const delayMs = 100;

    while (attempts < maxAttempts) {
      if (_isAuthenticated && _currentUser != null) {
        return; // Auth processing complete
      }
      await Future.delayed(const Duration(milliseconds: delayMs));
      attempts++;
    }

    // If we reach here, force load profile if user exists but profile not loaded
    final user = _supabase.auth.currentUser;
    if (user != null && _currentUser == null) {
      await _loadUserProfile(user.id);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('An unexpected error occurred during sign out.');
    } finally {
      _setLoading(false);
    }
  }

  // Check if user is authenticated
  Future<bool> checkAuth() async {
    _setLoading(true);
    await _checkCurrentSession();
    _setLoading(false);
    return _isAuthenticated;
  }

  // Login (alias signInWithEmail)
  Future<bool> login(String email, String password) async {
    try {
      await signInWithEmail(email, password);

      // Double check authentication state after sign in
      return _isAuthenticated && _currentUser != null;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Register (alias signUpWithEmail)
  Future<bool> register(String name, String email, String password) async {
    try {
      await signUpWithEmail(email, password);
      // Optionally update name after registration
      if (currentUser != null && name.isNotEmpty) {
        await updateProfile(currentUser!.copyWith(name: name));
      }

      // Double check authentication state after sign up
      return _isAuthenticated && _currentUser != null;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  // Logout (alias signOut)
  Future<void> logout() async {
    await signOut();
  }

  // Update profile
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', updatedProfile.id);
      await _loadUserProfile(updatedProfile.id);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _setError('Failed to reset password: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      _setError('Failed to change password: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      // Optionally, re-authenticate user here
      await _supabase.from('user_profiles').delete().eq('id', user.id);
      await _supabase.auth.signOut();
      return true;
    } catch (e) {
      _setError('Failed to delete account: $e');
      return false;
    }
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
