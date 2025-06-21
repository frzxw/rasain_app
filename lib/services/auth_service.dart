import 'dart:typed_data';
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
    _initializeAuth();
  }

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    debugPrint('🚀 Initializing AuthService...');
    await _checkCurrentSession();
  }

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Handle auth state changes
  void _handleAuthStateChange(AuthState event) {
    debugPrint('🔄 Auth state changed: ${event.event}');
    if (event.event == AuthChangeEvent.signedIn) {
      debugPrint(
        '✅ User signed in, loading profile for: ${event.session?.user.id}',
      );
      _loadUserProfile(event.session?.user.id);
    } else if (event.event == AuthChangeEvent.signedOut) {
      debugPrint('❌ User signed out');
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Check current session
  Future<void> _checkCurrentSession() async {
    debugPrint('🔍 Checking current session...');
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      debugPrint('📋 Found existing session for user: ${session!.user.id}');
      await _loadUserProfile(session.user.id);
    } else {
      debugPrint('❌ No existing session found');
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String? userId) async {
    if (userId == null) return;

    try {
      debugPrint('📥 Loading user profile for: $userId');
      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .single();

      _currentUser = UserProfile.fromJson(response);
      _isAuthenticated = true;
      debugPrint('✅ User profile loaded successfully: ${_currentUser?.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user profile: $e');
      // If profile doesn't exist, user might be newly registered
      // but profile creation failed, try to create it
      if (_supabase.auth.currentUser != null) {
        debugPrint('🔧 Attempting to create user profile...');
        await _createUserProfile(_supabase.auth.currentUser!);
      }
    }
  }

  // Create user profile in database
  Future<void> _createUserProfile(User user) async {
    try {
      debugPrint('🔧 Creating user profile for: ${user.id}');
      final profileData = {
        'id': user.id,
        'name':
            user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'image_url': user.userMetadata?['avatar_url'],
        'bio': null,
        'saved_recipes_count': 0,
        'posts_count': 0,
        'is_notifications_enabled': true,
        'language': 'id',
        'is_dark_mode_enabled': false,
      };

      debugPrint('📝 Profile data: $profileData');

      // Use upsert to handle potential conflicts
      final response =
          await _supabase
              .from('user_profiles')
              .upsert(profileData)
              .select()
              .single();

      debugPrint('✅ User profile created successfully: $response');

      // Load the newly created profile
      await _loadUserProfile(user.id);
    } catch (e) {
      debugPrint(
        '❌ Error creating user profile: $e',
      ); // If it's an RLS error, try to handle it gracefully
      if (e.toString().contains('row-level security policy')) {
        debugPrint(
          '🔒 RLS policy violation detected - this is expected for unverified users',
        ); // Set a temporary user profile with limited data
        _currentUser = UserProfile(
          id: user.id,
          name:
              user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          bio: null,
          savedRecipesCount: 0,
          postsCount: 0,
          isNotificationsEnabled: true,
          language: 'id',
          isDarkModeEnabled: false,
        );
        debugPrint(
          '📝 Created temporary profile in memory: ${_currentUser?.name}',
        );
        // Don't set error or authentication status - let the email verification flow handle it
        notifyListeners();
      } else {
        _setError('Failed to create user profile: $e');
        rethrow;
      }
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    _setLoading(true);
    _setError(null); // Clear previous errors
    try {
      debugPrint('📝 Attempting to sign up with email: $email');

      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (res.user != null) {
        debugPrint('✅ User signed up successfully: ${res.user!.id}');

        // Wait a moment for the auth session to be established
        await Future.delayed(const Duration(milliseconds: 500));

        // Try to create user profile
        await _createUserProfile(res.user!);

        debugPrint('🎉 Sign up process completed successfully');
      } else {
        _setError('Sign up failed: No user returned.');
        debugPrint('❌ Sign up failed: No user returned');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Auth exception during sign up: ${e.message}');
      _setError(e.message);
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error during sign up: $e');
      _setError('An unexpected error occurred during sign up: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null); // Clear previous errors
    try {
      debugPrint('🔑 Attempting to sign in with email: $email');
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        _setError('Sign in failed: No user returned.');
        debugPrint('❌ Sign in failed: No user returned');
      } else {
        debugPrint('🎉 Sign in successful, user ID: ${res.user!.id}');
        // Wait a bit for the auth state change to be processed
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // The onAuthStateChange listener will handle loading the profile
    } on AuthException catch (e) {
      debugPrint('❌ Auth exception during sign in: ${e.message}');
      _setError(e.message);
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error during sign in: $e');
      _setError('An unexpected error occurred during sign in.');
      rethrow;
    } finally {
      _setLoading(false);
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
    debugPrint('🔐 Checking authentication status...');
    _setLoading(true);
    await _checkCurrentSession();
    _setLoading(false);
    debugPrint('🎯 Authentication check result: $_isAuthenticated');
    return _isAuthenticated;
  }

  // Login (alias signInWithEmail)
  Future<bool> login(String email, String password) async {
    try {
      await signInWithEmail(email, password);
      // Wait for authentication state to update
      int attempts = 0;
      while (!isAuthenticated && attempts < 50) {
        // Max 5 seconds wait
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      debugPrint(
        '🔍 Login result after wait: isAuthenticated=$isAuthenticated, attempts=$attempts',
      );
      return isAuthenticated;
    } catch (e) {
      debugPrint('❌ Login method caught error: $e');
      return false;
    }
  }

  // Register (alias signUpWithEmail)
  Future<bool> register(String name, String email, String password) async {
    debugPrint('📝 Registering user: $email with name: $name');
    try {
      await signUpWithEmail(email, password, name: name);

      // Even if profile creation fails due to RLS, signup was successful
      // The user just needs to verify email first
      debugPrint('✅ Registration completed - email verification required');
      return true;
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      return false;
    }
  }

  // Logout (alias signOut)
  Future<void> logout() async {
    await signOut();
  }

  // Update profile with image upload support
  Future<bool> updateProfile({
    String? name,
    String? bio,
    List<int>? avatarBytes,
    String? avatarFileName,
    UserProfile? updatedProfile, // For backward compatibility
  }) async {
    if (!_isAuthenticated || _currentUser == null) {
      _setError('User not authenticated');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final userId = _currentUser!.id;
      String? imageUrl = _currentUser!.imageUrl; // Upload avatar if provided
      if (avatarBytes != null && avatarFileName != null) {
        try {
          // Use a more generic path structure
          final avatarPath =
              '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Try uploading to a public bucket first, fallback to avatars
          String bucketName = 'avatars';

          await _supabase.storage
              .from(bucketName)
              .uploadBinary(avatarPath, Uint8List.fromList(avatarBytes));

          imageUrl = _supabase.storage
              .from(bucketName)
              .getPublicUrl(avatarPath);

          debugPrint(
            '✅ Avatar uploaded successfully to $bucketName: $imageUrl',
          );
        } catch (e) {
          debugPrint('❌ Error uploading avatar to avatars bucket: $e');

          // Fallback: try uploading to a different bucket or handle differently
          try {
            // Alternative: Upload to public bucket with different name
            final avatarPath =
                'user_avatars/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

            await _supabase.storage
                .from('public')
                .uploadBinary(avatarPath, Uint8List.fromList(avatarBytes));

            imageUrl = _supabase.storage
                .from('public')
                .getPublicUrl(avatarPath);

            debugPrint(
              '✅ Avatar uploaded successfully to public bucket: $imageUrl',
            );
          } catch (e2) {
            debugPrint('❌ Error uploading avatar to public bucket: $e2');
            _setError(
              'Failed to upload avatar. Please check storage permissions.',
            );
            return false;
          }
        }
      }

      // Handle backward compatibility or use individual params
      if (updatedProfile != null) {
        await _supabase
            .from('user_profiles')
            .update(updatedProfile.toJson())
            .eq('id', updatedProfile.id);
        await _loadUserProfile(updatedProfile.id);
      } else {
        // Update profile data with individual params
        final updateData = <String, dynamic>{};
        if (name != null) updateData['name'] = name;
        if (bio != null) updateData['bio'] = bio;
        if (imageUrl != null) updateData['image_url'] = imageUrl;

        if (updateData.isNotEmpty) {
          await _supabase
              .from('user_profiles')
              .update(updateData)
              .eq('id', userId);

          // Update local user profile
          _currentUser = _currentUser!.copyWith(
            name: name,
            bio: bio,
            imageUrl: imageUrl,
          );

          debugPrint('✅ Profile updated successfully');
          notifyListeners();
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
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

  // Method to manually retry profile creation
  Future<void> retryProfileCreation() async {
    final user = _supabase.auth.currentUser;
    if (user != null && _currentUser == null) {
      debugPrint('🔄 Retrying profile creation for user: ${user.id}');
      await _createUserProfile(user);
    } else if (_currentUser != null) {
      debugPrint('ℹ️ User profile already exists');
    } else {
      debugPrint('❌ No authenticated user found');
    }
  }

  // Method to check if user needs profile setup
  bool get needsProfileSetup {
    return _isAuthenticated && _currentUser == null;
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
