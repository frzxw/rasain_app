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
  
  // Handle auth state changes
  void _handleAuthStateChange(AuthState event) {
    if (event.event == AuthChangeEvent.signedIn) {
      _loadUserProfile(event.session?.user.id);
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
      final response = await _supabase
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
        'name': user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
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
    // Check if user is authenticated
  Future<bool> checkAuth() async {
    _setLoading(true);
    _clearError();
    
    try {
      final session = _supabase.auth.currentSession;
      
      if (session?.user != null) {
        await _loadUserProfile(session!.user.id);
        return _isAuthenticated;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return false;
      }
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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return true;
      } else {
        _setError('Login failed: Invalid credentials');
        return false;
      }
    } on AuthException catch (e) {
      _setError('Login failed: ${e.message}');
      return false;
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
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        // Create user profile
        await _createUserProfile(response.user!);
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } on AuthException catch (e) {
      _setError('Registration failed: ${e.message}');
      return false;
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
      await _supabase.auth.signOut();
      
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
      final updateData = updatedProfile.toJson();
      updateData.remove('id'); // Don't update the ID
      
      await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', updatedProfile.id);
      
      _currentUser = updatedProfile;
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
        'is_notifications_enabled': notificationsEnabled ?? _currentUser!.isNotificationsEnabled,
        'language': language ?? _currentUser!.language,
        // We'll still store the preference in the database but won't use it in the app
        'is_dark_mode_enabled': false,
      };
      
      await _supabase
          .from('user_profiles')
          .update(updatedSettings)
          .eq('id', _currentUser!.id);
      
      // Update local user object
      _currentUser = _currentUser!.copyWith(
        isNotificationsEnabled: notificationsEnabled,
        language: language,
      );
      
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
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return true;
    } on AuthException catch (e) {
      _setError('Password change failed: ${e.message}');
      return false;
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
      // First delete the user profile
      if (_currentUser?.id != null) {
        await _supabase
            .from('user_profiles')
            .delete()
            .eq('id', _currentUser!.id);
      }
      
      // Note: Supabase doesn't provide a direct way to delete a user account from client
      // This would typically require server-side implementation or admin API
      // For now, we'll just sign out the user and clear local data
      await _supabase.auth.signOut();
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
      
      // In a real implementation, you'd call a server endpoint to delete the user
      // from auth.users table using admin privileges
      return true;
    } catch (e) {
      _setError('Account deletion failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
    // Request password reset
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      _setError('Password reset failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Resend email verification
  Future<bool> resendEmailVerification() async {
    if (_supabase.auth.currentUser?.email == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _supabase.auth.currentUser!.email!,
      );
      return true;
    } on AuthException catch (e) {
      _setError('Email verification resend failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Email verification resend failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Check if user email is verified
  bool get isEmailVerified {
    return _supabase.auth.currentUser?.emailConfirmedAt != null;
  }
  
  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

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
