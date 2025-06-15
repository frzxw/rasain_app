import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  UserProfile? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Check if user is authenticated
  Future<bool> checkAuth() async {
    _setLoading(true);
    _clearError();

    try {
      final user = _supabaseService.client.auth.currentUser;

      if (user != null) {
        // Fetch user profile from database
        final response =
            await _supabaseService.client
                .from('user_profiles')
                .select()
                .eq('id', user.id)
                .single();

        _currentUser = UserProfile.fromJson(response);
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }

      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _setError('Authentication check failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch user profile from database
        final profileResponse =
            await _supabaseService.client
                .from('user_profiles')
                .select()
                .eq('id', response.user!.id)
                .single();

        _currentUser = UserProfile.fromJson(profileResponse);
        _isAuthenticated = true;

        notifyListeners();
        return true;
      } else {
        _setError('Login failed: Invalid credentials');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register new account
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in database
        final profileData = {
          'id': response.user!.id,
          'name': name,
          'email': email,
          'saved_recipes_count': 0,
          'posts_count': 0,
          'is_notifications_enabled': true,
          'language': 'id',
          'is_dark_mode_enabled': false,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabaseService.client.from('user_profiles').insert(profileData);

        _currentUser = UserProfile.fromJson(profileData);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _supabaseService.client.auth.signOut();

      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        _setError('No user authenticated');
        return false;
      }

      final response =
          await _supabaseService.client
              .from('user_profiles')
              .update(updatedProfile.toJson())
              .eq('id', _currentUser!.id)
              .select()
              .single();

      _currentUser = UserProfile.fromJson(response);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user settings
  Future<bool> updateSettings({
    bool? notificationsEnabled,
    String? language,
    bool? darkModeEnabled,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedSettings = {
        'is_notifications_enabled':
            notificationsEnabled ?? _currentUser!.isNotificationsEnabled,
        'language': language ?? _currentUser!.language,
        'is_dark_mode_enabled':
            darkModeEnabled ?? _currentUser!.isDarkModeEnabled,
      };

      final response =
          await _supabaseService.client
              .from('user_profiles')
              .update(updatedSettings)
              .eq('id', _currentUser!.id)
              .select()
              .single();

      _currentUser = UserProfile.fromJson(response);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Settings update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return true;
    } catch (e) {
      _setError('Password change failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        _setError('No user authenticated');
        return false;
      }

      // Delete user profile from database
      await _supabaseService.client
          .from('user_profiles')
          .delete()
          .eq('id', _currentUser!.id);

      // Sign out user
      await _supabaseService.client.auth.signOut();

      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Account deletion failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    debugPrint(errorMessage);
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
