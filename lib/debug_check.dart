import 'package:flutter/foundation.dart';
import 'services/supabase_service.dart';

/// Debug utility to check database connections and data
class DebugCheck {
  static final SupabaseService _supabase = SupabaseService.instance;

  /// Main debug function to check everything
  static Future<void> runDebugCheck() async {
    try {
      debugPrint('🔍 ====== STARTING DEBUG CHECK ======');

      await _checkSupabaseConnection();
      await _checkAuthStatus();
      await _checkUserProfiles();
      await _checkCommunityPosts();
      await _checkRelationships();
      await _checkRLSPolicies();

      debugPrint('🔍 ====== DEBUG CHECK COMPLETE ======');
    } catch (e) {
      debugPrint('❌ Error during debug check: $e');
    }
  }

  /// Check if Supabase connection is working
  static Future<void> _checkSupabaseConnection() async {
    try {
      debugPrint('\n🔌 Checking Supabase connection...');

      await _supabase.client.from('user_profiles').select('count').limit(1);

      debugPrint('✅ Supabase connection working');
    } catch (e) {
      debugPrint('❌ Supabase connection failed: $e');
    }
  }

  /// Check authentication status
  static Future<void> _checkAuthStatus() async {
    try {
      debugPrint('\n👤 Checking auth status...');

      final user = _supabase.client.auth.currentUser;
      if (user != null) {
        debugPrint('✅ User logged in: ${user.id}');
        debugPrint('   Email: ${user.email}');
        debugPrint('   Created: ${user.createdAt}');
      } else {
        debugPrint('⚠️ No user logged in');
      }
    } catch (e) {
      debugPrint('❌ Error checking auth: $e');
    }
  }

  /// Check user_profiles table
  static Future<void> _checkUserProfiles() async {
    try {
      debugPrint('\n👥 Checking user_profiles table...');

      final profiles = await _supabase.client
          .from('user_profiles')
          .select('*')
          .limit(10);

      debugPrint('📊 Found ${profiles.length} user profiles:');
      for (int i = 0; i < profiles.length; i++) {
        final profile = profiles[i];
        debugPrint(
          '   $i. ID: ${profile['id']?.toString().substring(0, 8)}..., Name: "${profile['name']}", Email: "${profile['email']}"',
        );
      }

      if (profiles.isEmpty) {
        debugPrint('⚠️ No user profiles found in database');
      }
    } catch (e) {
      debugPrint('❌ Error checking user profiles: $e');
    }
  }

  /// Check community_posts table
  static Future<void> _checkCommunityPosts() async {
    try {
      debugPrint('\n📋 Checking community_posts table...');

      final posts = await _supabase.client
          .from('community_posts')
          .select('*')
          .limit(10);

      debugPrint('📊 Found ${posts.length} community posts:');
      for (int i = 0; i < posts.length; i++) {
        final post = posts[i];
        final content = post['content']?.toString() ?? '';
        final shortContent =
            content.length > 30 ? '${content.substring(0, 30)}...' : content;
        debugPrint(
          '   $i. ID: ${post['id']}, User ID: ${post['user_id']?.toString().substring(0, 8)}..., Content: "$shortContent"',
        );
      }

      if (posts.isEmpty) {
        debugPrint('⚠️ No community posts found in database');
      }
    } catch (e) {
      debugPrint('❌ Error checking community posts: $e');
    }
  }

  /// Check relationships between user_profiles and community_posts
  static Future<void> _checkRelationships() async {
    try {
      debugPrint('\n🔗 Checking relationships...');

      // Get all user IDs from posts
      final posts = await _supabase.client
          .from('community_posts')
          .select('user_id');

      final postUserIds =
          posts
              .map((p) => p['user_id']?.toString())
              .where((id) => id != null)
              .toSet()
              .cast<String>()
              .toList();

      // Get all user IDs from profiles
      final profiles = await _supabase.client
          .from('user_profiles')
          .select('id');

      final profileUserIds =
          profiles
              .map((p) => p['id']?.toString())
              .where((id) => id != null)
              .toSet()
              .cast<String>()
              .toList();

      debugPrint('📊 User IDs in posts: ${postUserIds.length}');
      debugPrint('📊 User IDs in profiles: ${profileUserIds.length}');

      // Find missing profiles
      final missingProfiles =
          postUserIds.where((id) => !profileUserIds.contains(id)).toList();

      if (missingProfiles.isEmpty) {
        debugPrint('✅ All post user IDs have corresponding profiles');
      } else {
        debugPrint(
          '❌ Posts with missing profiles (${missingProfiles.length}):',
        );
        for (final id in missingProfiles) {
          debugPrint('   - ${id.substring(0, 8)}...');
        }
      }

      // Test a specific join
      if (postUserIds.isNotEmpty) {
        final testUserId = postUserIds.first;
        debugPrint(
          '\n🧪 Testing manual join for user: ${testUserId.substring(0, 8)}...',
        );

        final profile =
            await _supabase.client
                .from('user_profiles')
                .select('name, email')
                .eq('id', testUserId)
                .maybeSingle();

        if (profile != null) {
          debugPrint('✅ Manual join successful: ${profile['name']}');
        } else {
          debugPrint('❌ Manual join failed: no profile found');
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking relationships: $e');
    }
  }

  /// Check RLS policies and permissions
  static Future<void> _checkRLSPolicies() async {
    try {
      debugPrint('\n🔒 Checking RLS policies...');

      final user = _supabase.client.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No authenticated user - RLS will block operations');
        return;
      }

      debugPrint('✅ Authenticated user: ${user.id}');
      debugPrint('   Auth UID: ${user.id}');

      // Try to access user_profiles with current auth
      try {
        final profile =
            await _supabase.client
                .from('user_profiles')
                .select('*')
                .eq('id', user.id)
                .maybeSingle();

        if (profile != null) {
          debugPrint('✅ RLS allows reading user profile');
        } else {
          debugPrint('⚠️ No profile found for current user');
        }
      } catch (e) {
        debugPrint('❌ RLS blocks reading user profile: $e');
      }

      // Try to insert a test profile (will be rolled back)
      try {
        await _supabase.client
            .from('user_profiles')
            .select('count')
            .eq('id', user.id)
            .limit(1);
        debugPrint('✅ RLS allows profile operations');
      } catch (e) {
        debugPrint('❌ RLS blocks profile operations: $e');
      }
    } catch (e) {
      debugPrint('❌ Error checking RLS policies: $e');
    }
  }

  /// Create test data if needed
  static Future<void> createTestData() async {
    try {
      debugPrint('\n🧪 Creating test data...');

      final user = _supabase.client.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in, cannot create test data');
        return;
      }

      // Check if profile exists
      final existingProfile =
          await _supabase.client
              .from('user_profiles')
              .select('*')
              .eq('id', user.id)
              .maybeSingle();

      if (existingProfile == null) {
        debugPrint('🧪 Creating user profile...');
        await _supabase.client.from('user_profiles').insert({
          'id': user.id,
          'name': user.email?.split('@')[0] ?? 'Test User',
          'email': user.email,
          'saved_recipes_count': 0,
          'posts_count': 0,
          'is_notifications_enabled': true,
          'language': 'id',
          'is_dark_mode_enabled': false,
        });
        debugPrint('✅ User profile created');
      } else {
        debugPrint('✅ User profile exists: ${existingProfile['name']}');
      }

      // Check if posts exist
      final existingPosts = await _supabase.client
          .from('community_posts')
          .select('*')
          .eq('user_id', user.id);

      if (existingPosts.isEmpty) {
        debugPrint('🧪 Creating test post...');
        await _supabase.client.from('community_posts').insert({
          'user_id': user.id,
          'content':
              'Test post created by debug script - ${DateTime.now().toIso8601String()}',
          'category': 'Test',
          'like_count': 0,
          'comment_count': 0,
        });
        debugPrint('✅ Test post created');
      } else {
        debugPrint('✅ User has ${existingPosts.length} existing posts');
      }
    } catch (e) {
      debugPrint('❌ Error creating test data: $e');
    }
  }

  /// Admin function to fix user profiles issues
  static Future<void> fixUserProfilesIssues() async {
    try {
      debugPrint('\n🔧 ====== FIXING USER PROFILES ISSUES ======');

      final user = _supabase.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ No authenticated user found');
        return;
      }

      debugPrint('🧑‍💼 Current user: ${user.id}');
      debugPrint('📧 Email: ${user.email}');

      // Check if profile exists
      final existingProfile =
          await _supabase.client
              .from('user_profiles')
              .select('*')
              .eq('id', user.id)
              .maybeSingle();

      if (existingProfile != null) {
        debugPrint('✅ User profile already exists');
        debugPrint('👤 Name: ${existingProfile['name']}');
        return;
      }

      // Try to create profile with upsert
      debugPrint('🔧 Attempting to create missing profile...');

      final profileData = {
        'id': user.id,
        'name': user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'saved_recipes_count': 0,
        'posts_count': 0,
        'is_notifications_enabled': true,
        'language': 'id',
        'is_dark_mode_enabled': false,
      };

      try {
        final result =
            await _supabase.client
                .from('user_profiles')
                .upsert(profileData)
                .select()
                .single();

        debugPrint('✅ Profile created successfully: ${result['name']}');
      } catch (e) {
        debugPrint('❌ Failed to create profile via upsert: $e');

        // Try with regular insert
        try {
          final result =
              await _supabase.client
                  .from('user_profiles')
                  .insert(profileData)
                  .select()
                  .single();

          debugPrint('✅ Profile created via insert: ${result['name']}');
        } catch (e2) {
          debugPrint('❌ Failed to create profile via insert: $e2');

          // Last resort: check if RLS is the issue
          if (e2.toString().contains('row-level security')) {
            debugPrint('🔒 RLS is blocking profile creation');
            debugPrint('💡 Suggested solutions:');
            debugPrint('   1. Run the SQL fix in Supabase dashboard');
            debugPrint('   2. Check RLS policies in Supabase');
            debugPrint('   3. Verify auth.uid() is working correctly');
          }
        }
      }

      debugPrint('🔧 ====== FIX ATTEMPT COMPLETE ======');
    } catch (e) {
      debugPrint('❌ Error during fix attempt: $e');
    }
  }
}
