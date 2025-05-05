import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme/theme_service.dart';
import '../models/user_profile.dart';
import 'mock_api_service.dart';

class AuthService extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  
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
      final response = await _apiService.get('auth/me');
      
      if (response['user'] != null) {
        _currentUser = UserProfile.fromJson(response['user']);
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
      final response = await _apiService.post(
        'auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response['user'] != null) {
        _currentUser = UserProfile.fromJson(response['user']);
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
      final response = await _apiService.post(
        'auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      
      if (response['user'] != null) {
        _currentUser = UserProfile.fromJson(response['user']);
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
      await _apiService.post('auth/logout');
      
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
      final response = await _apiService.put(
        'auth/profile',
        body: updatedProfile.toJson(),
      );
      
      if (response['user'] != null) {
        _currentUser = UserProfile.fromJson(response['user']);
        notifyListeners();
        return true;
      } else {
        _setError('Profile update failed');
        return false;
      }
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
        // We'll still store the preference in the API but won't use it in the app
        'is_dark_mode_enabled': false,
      };
      
      final response = await _apiService.put(
        'auth/settings',
        body: updatedSettings,
      );
      
      if (response['user'] != null) {
        _currentUser = UserProfile.fromJson(response['user']);
        notifyListeners();
        return true;
      } else {
        _setError('Settings update failed');
        return false;
      }
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
      final response = await _apiService.post(
        'auth/password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      
      if (response['success'] == true) {
        return true;
      } else {
        _setError('Password change failed: ${response['message']}');
        return false;
      }
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
      final response = await _apiService.post(
        'auth/delete',
        body: {'password': password},
      );
      
      if (response['success'] == true) {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
        return true;
      } else {
        _setError('Account deletion failed: ${response['message']}');
        return false;
      }
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
